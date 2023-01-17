import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:defi_wallet/client/hive_names.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/requests/history_requests.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'transaction_state.dart';

class TransactionCubit extends Cubit<TransactionState> {
  TransactionCubit() : super(TransactionInitialState(''));
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

  onChangeTransactionState(String txId, {dynamic timer}) async {
    try {
      bool isOngoing = await historyRequests.getTxPresent(
          txId, SettingsHelper.settings.network!);
      if (isOngoing) {
        if (timer != null) {
          timer.cancel();
        }
        emit(TransactionLoadedState(txId));
      } else {
        emit(TransactionLoadingState(txId));
      }
    } catch (err) {
      if (timer != null) {
        timer.cancel();
      }
      emit(TransactionErrorState(txId));
    }
  }

  clearOngoingTransaction() async {
    var box = await Hive.openBox(HiveBoxes.client);
    await box.put(HiveNames.ongoingTransaction, null);
    await box.close();
  }

  confirmTransactionStatus() async {
    clearOngoingTransaction();
    emit(TransactionInitialState(''));
  }

  setOngoingTransaction(String txId) async {
    emit(TransactionInitialState(''));
    var box = await Hive.openBox(HiveBoxes.client);
    await box.put(HiveNames.ongoingTransaction, txId);
    await box.close();
  }
}
