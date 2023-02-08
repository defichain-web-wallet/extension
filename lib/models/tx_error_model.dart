import 'package:defi_wallet/models/tx_loader_model.dart';

class TxErrorModel {
  bool? isError;
  String? error;
  List<TxLoaderModel>? txLoaderList;

  TxErrorModel({
    this.isError,
    this.error,
    this.txLoaderList,
  });

  TxErrorModel.fromJson(Map<dynamic, dynamic> json) {
    List<dynamic> txLoaderListJson = json["txLoaderList"];
    this.isError = json["isError"];
    this.error = json["error"];
    List<TxLoaderModel> txLoaderList = List<TxLoaderModel>.generate(
      txLoaderListJson.length,
      (index) => TxLoaderModel.fromJson(txLoaderListJson[index]),
    );
    this.txLoaderList = txLoaderList;
  }

  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> data = new Map<dynamic, dynamic>();
    data["isError"] = this.isError;
    data["error"] = this.error;
    data["txLoaderList"] = this.txLoaderList?.map((e) => e.toJson()).toList();
    return data;
  }
}
