import 'package:defi_wallet/models/utxo_model.dart';

class TxResponseModel {
  List<UtxoModel> usingUTXO;
  List<UtxoModel> newUTXO;
  bool isError;
  String? error;
  String hex;
  int? amount;
  TxResponseModel({required this.usingUTXO, required this.newUTXO, required this.hex, required this.isError, this.error, this.amount});
}
