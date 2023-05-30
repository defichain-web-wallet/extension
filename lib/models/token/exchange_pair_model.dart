import 'package:defi_wallet/models/network/network_name.dart';
import 'package:defi_wallet/models/token/token_model.dart';

class ExchangePairModel {
  TokenModel base;
  TokenModel quote;
  double ratio;
  double ratioReverse;
  bool isBidirectional;

  ExchangePairModel({
    required this.base,
    required this.quote,
    required this.ratio,
    required this.ratioReverse,
    this.isBidirectional = true,
  });

  factory ExchangePairModel.fromJSON(
    Map<String, dynamic> json,
    NetworkName? networkName,
  ) {
    return ExchangePairModel(
      base: TokenModel.fromJSON(json['tokenA'], networkName: networkName),
      quote: TokenModel.fromJSON(json['tokenB'], networkName: networkName),
      ratio: double.parse(json['tokenA']['reserve']) /
          double.parse(json['tokenB']['reserve']),
      ratioReverse: double.parse(json['tokenB']['reserve']) /
          double.parse(json['tokenA']['reserve']),
    );
  }

  static List<ExchangePairModel> fromJSONList(
    List<dynamic> jsonList,
    NetworkName? networkName,
  ) {
    List<ExchangePairModel> pairs = List.generate(
      jsonList.length,
      (index) => ExchangePairModel.fromJSON(
        jsonList[index],
        networkName,
      ),
    );

    return pairs;
  }
}
