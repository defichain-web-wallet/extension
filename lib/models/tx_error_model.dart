import 'package:defi_wallet/models/tx_loader_model.dart';

class TxErrorModel {
  bool isError;
  String? error;
  List<TxLoaderModel>? txLoaderList;

  TxErrorModel({required this.isError, this.error, this.txLoaderList});
}
