import 'package:defi_wallet/models/network/network_name.dart';
import 'package:defi_wallet/models/token/token_model.dart';

class LmPoolModel {
  String id;
  String symbol;
  String displaySymbol;
  String name;
  List<TokenModel> tokens;
  List<double>? percentages;
  double? apr;
  double? apy;

  LmPoolModel({
    required this.tokens,
    this.percentages,
    this.apr,
    this.apy,
    required this.symbol,
    required this.displaySymbol,
    required this.name,
    required this.id,
  });

  factory LmPoolModel.fromJSON(
      Map<String, dynamic> json, NetworkName? networkName) {
    return LmPoolModel(
      id: json['id'],
      symbol: json['symbol'],
      name: json['name'],
      displaySymbol: json['displaySymbol'],
      tokens: TokenModel.fromJSONList([json['tokenA'], json['tokenB']], networkName)
//TODO: add percentages
    );
  }

  static List<LmPoolModel> fromJSONList(List<dynamic> jsonList, NetworkName? networkName) {
    List<LmPoolModel> tokens = [];

    jsonList.forEach((json) {
      LmPoolModel token = LmPoolModel.fromJSON(json, networkName);
      tokens.add(token);
    });

    return tokens;
  }
}
