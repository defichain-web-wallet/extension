import 'package:defi_wallet/models/network/network_name.dart';
import 'package:defi_wallet/models/token/token_model.dart';

class LmPoolModel extends TokenModel {
  List<TokenModel> tokens;
  List<double>? percentages;
  double? apr;
  double? apy;

  LmPoolModel({
    required String id,
    required String symbol,
    required String name,
    required String displaySymbol,
    required NetworkName networkName,
    bool isUTXO = false,
    required this.tokens,
    this.percentages,
    this.apr,
    this.apy,
  }) : super(
    id: id,
    symbol: symbol,
    name: name,
    displaySymbol: displaySymbol,
    networkName: networkName,
    isUTXO: isUTXO,
  );

  Map<String, dynamic> toJSON() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['symbol'] = this.symbol;
    data['displaySymbol'] = this.displaySymbol;
    data['name'] = this.name;
    data['networkName'] = this.networkName.toString();
    data['tokens'] = this.tokens.map((token) => token.toJSON()).toList();
    if (this.percentages != null) {
      data['percentages'] = this.percentages;
    }
    if (this.apr != null) {
      data['apr'] = this.apr;
    }
    if (this.apy != null) {
      data['apy'] = this.apy;
    }
    return data;
  }

  factory LmPoolModel.fromJSON(
    Map<String, dynamic> json, {
    NetworkName? networkName,
    List<TokenModel>? tokens,
  }) {
    if (networkName != null && tokens != null) {
      var symbols = json['symbol'].split('-');
      var tokenA = tokens.firstWhere((element) => element.symbol == symbols[0]);
      var tokenB = tokens.firstWhere((element) => element.symbol == symbols[1]);
      return LmPoolModel(
        id: json['id'],
        symbol: json['symbol'],
        name: json['name'],
        displaySymbol: json['displaySymbol'],
        networkName: networkName,
        tokens: [tokenA, tokenB],
//TODO: add percentages
      );
    } else {
      return LmPoolModel(
        id: json['id'],
        symbol: json['symbol'],
        name: json['name'],
        displaySymbol: json['displaySymbol'],
        networkName: NetworkName.values.firstWhere(
          (value) => value.toString() == json['networkName'],
        ),
        tokens: List.generate(
          json['tokens'].length,
          (index) => TokenModel.fromJSON(
            json['tokens'][index],
          ),
        ),
      );
    }
  }

  static List<LmPoolModel> fromJSONList(List<dynamic> jsonList,
      NetworkName? networkName, List<TokenModel> tokens) {
    List<LmPoolModel> lmTokens = List.generate(
      jsonList.length,
      (index) => LmPoolModel.fromJSON(
        jsonList[index],
        networkName: networkName,
        tokens: tokens,
      ),
    );

    return lmTokens;
  }
}
