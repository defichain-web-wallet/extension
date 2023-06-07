import 'package:defi_wallet/models/network/network_name.dart';
import 'package:defi_wallet/models/token/token_model.dart';

class LmPoolModel extends TokenModel {
  List<TokenModel> tokens;
  List<double>? percentages;
  List<double>? reserves;
  double? totalLiquidityRaw;
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
    this.reserves,
    this.totalLiquidityRaw,
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

  double get reserveADivReserveB {
    try {
      return this.reserves!.first / this.reserves!.last;
    } catch (_) {
      return 0.00;
    }
  }

  double get reserveBDivReserveA {
    try {
      return this.reserves!.last / this.reserves!.first;
    } catch (_) {
      return 0.00;
    }
  }

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
    if (this.reserves != null) {
      data['reserves'] = this.reserves;
    }
    if (this.totalLiquidityRaw != null) {
      data['totalLiquidityRaw'] = this.totalLiquidityRaw;
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
      List<String> symbols = json['symbol'].split('-');

      double reserveA = 0;
      double reserveB = 0;
      double totalLiquidity = 0;

      try {
        totalLiquidity = double.parse(json["totalLiquidity"]['token']);
      } catch (_) {
      }

      try {
        reserveA = double.parse(json["tokenA"]['reserve']);
        reserveB = double.parse(json["tokenB"]['reserve']);
      } catch (_) {
        reserveA = 0;
        reserveB = 0;
      }

      late TokenModel tokenA;
      late TokenModel tokenB;

      try {
        tokenA = tokens.firstWhere((element) => element.symbol == symbols[0]);
        tokenB = tokens.firstWhere((element) => element.symbol == symbols[1]);
      } catch (err) {
        tokenA = tokens[0];
        tokenB = tokens[1];
      }

      return LmPoolModel(
        id: json['id'],
        symbol: json['symbol'],
        name: json['name'],
        displaySymbol: json['displaySymbol'],
        networkName: networkName,
        tokens: [tokenA, tokenB],
        reserves: [
          reserveA,
          reserveB,
        ],
        totalLiquidityRaw: totalLiquidity,
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

  static List<LmPoolModel> fromJSONList(
    List<dynamic> jsonList,
    NetworkName? networkName,
    List<TokenModel> tokens,
  ) {
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
