import 'package:defi_wallet/models/network/network_name.dart';
import 'package:defi_wallet/models/token/token_model.dart';

class ExchangePairModel {
  TokenModel token1;
  TokenModel token2;
  double ratio;
  bool isBidirectional;

  ExchangePairModel(
      {required this.token1,
      required this.token2,
      required this.ratio,
      this.isBidirectional = true});

  factory ExchangePairModel.fromJSON(
      Map<String, dynamic> json, NetworkName? networkName) {
    return ExchangePairModel(
      token1: TokenModel.fromJSON(json['tokenA'], networkName),
      token2: TokenModel.fromJSON(json['tokenB'], networkName),
      ratio: double.parse(json['tokenA']['reserve']) /
          double.parse(json['tokenB']['reserve']),
    );
  }

  static List<ExchangePairModel> fromJSONList(List<dynamic> jsonList, NetworkName? networkName) {
    List<ExchangePairModel> pairs = [];

    jsonList.forEach((json) {
      ExchangePairModel pair = ExchangePairModel.fromJSON(json, networkName);
      pairs.add(pair);
    });

    return pairs;
  }
}
