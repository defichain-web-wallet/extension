import 'package:defi_wallet/models/network_fee_model.dart';

class EthereumNetworkFeeModel extends NetworkFeeModel {
  int? gasPrice;
  int? gasLimit;

  EthereumNetworkFeeModel({this.gasPrice, this.gasLimit});
}
