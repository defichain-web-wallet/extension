import 'package:defi_wallet/utils/convert.dart';

class CryptoRouteModel {
  String? blockchainFrom;
  String? blockchainTo;
  String? assetFrom;
  String? assetTo;
  String? address;
  int? minDeposit;
  double? fee;

  CryptoRouteModel(
      {this.blockchainFrom,
        this.blockchainTo,
        this.assetFrom = 'BTC',
        this.assetTo,
        this.address,
        this.minDeposit,
        this.fee});

  CryptoRouteModel.fromJson(Map<String, dynamic> json) {
    this.blockchainFrom = json["deposit"]['blockchain'];
    this.blockchainTo = json["asset"]['blockchain'];
    this.assetFrom = 'BTC';
    this.assetTo = json["asset"]['dBTC'];
    this.address = json["deposit"]['address'];
    this.minDeposit = convertToSatoshi(json["minDeposits"][0]['amount']);
    this.fee = json["fee"];

  }
}
