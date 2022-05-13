import 'package:defi_wallet/models/history_model.dart';

class TxListModel {
  final List<HistoryModel>? list;
  final String? transactionNext;
  final String? historyNext;

  TxListModel({this.list, this.transactionNext, this.historyNext});
}
