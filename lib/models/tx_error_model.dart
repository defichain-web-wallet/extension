import 'package:defi_wallet/models/utxo_model.dart';

class TxErrorModel {
  bool isError;
  String? error;
  String? txid;
  UtxoModel? utxo;
  TxErrorModel({required this.isError, this.error, this.txid, this.utxo});
}
