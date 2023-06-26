import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:defi_wallet/client/hive_names.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/models/network/network_name.dart';
import 'package:defi_wallet/models/tx_error_model.dart';
import 'package:defi_wallet/models/tx_loader_model.dart';
import 'package:defi_wallet/requests/history_requests.dart';
import 'package:defi_wallet/requests/transaction_requests.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'transaction_state.dart';

class TransactionCubit extends Cubit<TransactionState> {
  TransactionCubit() : super(TransactionInitialState(null));
  static const int lastTxIndex = 1;
  HistoryRequests historyRequests = HistoryRequests();
  Timer? timer;

  checkOngoingTransaction(NetworkTypeModel networkType) async {
    var box = await Hive.openBox(HiveBoxes.client);
    var txId = await box.get(HiveNames.ongoingTransaction);
    await box.close();
    if (txId != null) {
      TxErrorModel txErrorModel = TxErrorModel.fromJson(txId);
      await onChangeTransactionState(txErrorModel, networkType);
      timer = Timer.periodic(Duration(seconds: 2), (timer) async {
        await onChangeTransactionState(txErrorModel, networkType, timer: timer);
      });
    }
  }

  onChangeTransactionState(
    TxErrorModel txErrorModel,
    NetworkTypeModel networkType, {
    dynamic timer,
  }) async {
    bool isOngoing;
    TxLoaderModel loadingTx;
    try {
      loadingTx = txErrorModel.txLoaderList!.firstWhere(
        (element) => element.status == TxStatus.waiting,
      );
      isOngoing = await historyRequests.getTxPresent(
        loadingTx.txId!,
        networkType.networkString,
      );
      if (isOngoing) {
        if (txErrorModel.txLoaderList!.length > 1 &&
            txErrorModel.txLoaderList!.indexOf(loadingTx) == 0 &&
            txErrorModel.txLoaderList![lastTxIndex].txHex != null) {
          TxErrorModel tempTxErrorModel = await TransactionRequests().sendTxHex(
            txErrorModel.txLoaderList![lastTxIndex].txHex!,
          );
          txErrorModel.txLoaderList![lastTxIndex].txId =
              tempTxErrorModel.txLoaderList![0].txId;
        }
        loadingTx.status = TxStatus.success;
        await setOngoingTransaction(txErrorModel);
      } else {
        emit(TransactionLoadingState(txErrorModel));
      }
    } catch (err) {
      print('transaction_bloc: $err');
      if (timer != null) {
        timer.cancel();
      }
      emit(TransactionLoadedState(txErrorModel));
    }
  }

  clearOngoingTransaction() async {
    var box = await Hive.openBox(HiveBoxes.client);
    await box.put(HiveNames.ongoingTransaction, null);
    await box.close();
  }

  confirmTransactionStatus() async {
    clearOngoingTransaction();
    emit(TransactionInitialState(null));
  }

  setOngoingTransaction(TxErrorModel txErrorModel) async {
    var box = await Hive.openBox(HiveBoxes.client);
    try {
      await box.put(
        HiveNames.ongoingTransaction,
        txErrorModel.toJson(),
      );
    } finally {
      emit(TransactionLoadingState(txErrorModel));
      await box.close();
    }
  }
}
