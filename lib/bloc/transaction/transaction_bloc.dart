import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:defi_wallet/client/hive_names.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/models/tx_error_model.dart';
import 'package:defi_wallet/requests/history_requests.dart';
import 'package:defi_wallet/requests/transaction_requests.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'transaction_state.dart';

class TransactionCubit extends Cubit<TransactionState> {
  TransactionCubit() : super(TransactionInitialState(null));
  HistoryRequests historyRequests = HistoryRequests();
  Timer? timer;

  checkOngoingTransaction() async {
    var box = await Hive.openBox(HiveBoxes.client);
    var txId = await box.get(HiveNames.ongoingTransaction);
    await box.close();
    if (txId != null) {
      TxErrorModel txErrorModel = TxErrorModel.fromJson(txId);
      await onChangeTransactionState(txErrorModel);
      timer = Timer.periodic(Duration(seconds: 2), (timer) async {
        await onChangeTransactionState(txErrorModel, timer: timer);
      });
    }
  }

  onChangeTransactionState(TxErrorModel txErrorModel, {dynamic timer}) async {
    try {
      bool isOngoing = await historyRequests.getTxPresent(
        txErrorModel.txLoaderList![state.txIndex!].txId!,
        SettingsHelper.settings.network!,
      );
      if (isOngoing) {
        if (txErrorModel.txLoaderList!.length == 1 || state.txIndex! == 1) {
          if (timer != null) {
            timer.cancel();
          }
          await clearOngoingTransaction();
          emit(TransactionLoadedState(txErrorModel, txIndex: state.txIndex!));
        } else {
          TxErrorModel tempTxErrorModel = await TransactionRequests().sendTxHex(
            state.txErrorModel!.txLoaderList![1].txHex!,
          );
          state.txErrorModel!.txLoaderList![1].txId =
              tempTxErrorModel.txLoaderList![0].txId;
          emit(TransactionLoadingState(state.txErrorModel, txIndex: 1));
        }
      } else {
        emit(TransactionLoadingState(txErrorModel, txIndex: state.txIndex!));
      }
    } catch (err) {
      if (timer != null) {
        timer.cancel();
      }
      emit(TransactionErrorState(txErrorModel));
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
