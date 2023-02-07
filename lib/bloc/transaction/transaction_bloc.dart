import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:defi_wallet/client/hive_names.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/models/tx_error_model.dart';
import 'package:defi_wallet/requests/history_requests.dart';
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
      await onChangeTransactionState(txId);
      timer = Timer.periodic(Duration(seconds: 2), (timer) async {
        await onChangeTransactionState(txId, timer: timer);
      });
    }
  }

  onChangeTransactionState(TxErrorModel txErrorModel, {dynamic timer}) async {
    try {
      bool isOngoing = await historyRequests.getTxPresent(
          txErrorModel, SettingsHelper.settings.network!);
      if (isOngoing) {
        if (timer != null) {
          timer.cancel();
        }
        emit(TransactionLoadedState(txErrorModel));
      } else {
        emit(TransactionLoadingState(txErrorModel));
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

  setOngoingTransaction(TxErrorModel txId) async {
    emit(TransactionLoadingState(txId));
    var box = await Hive.openBox(HiveBoxes.client);
    await box.put(HiveNames.ongoingTransaction, txId);
    await box.close();
  }
}
