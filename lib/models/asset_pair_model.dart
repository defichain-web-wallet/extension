import 'package:defi_wallet/utils/convert.dart';

class AssetPairModel {
  int? id;
  String? symbol;
  String? tokenA;
  String? tokenB;
  bool? status;
  double? reserveA;
  double? reserveB;
  double? reserveADivReserveB;
  double? reserveBDivReserveA;
  int? totalLiquidityRaw;
  double? totalLiquidity;
  double? totalLiquidityUsd;
  double? apr;

  AssetPairModel(
      {this.id,
      this.symbol,
      this.tokenA,
      this.tokenB,
      this.status,
      this.reserveA,
      this.reserveB,
      this.reserveADivReserveB,
      this.reserveBDivReserveA,
      this.totalLiquidityRaw,
      this.totalLiquidityUsd,
      this.totalLiquidity,
      this.apr});

  AssetPairModel.fromJson(Map<String, dynamic> json) {
    this.id = int.parse(json["id"]);
    this.symbol = json["symbol"];
    this.tokenA = json["symbol"].split('-')[0];
    this.tokenB = json["symbol"].split('-')[1];
    this.status = json["status"];
    this.reserveA = double.parse(json["tokenA"]['reserve']);
    this.reserveB = double.parse(json["tokenB"]['reserve']);
    this.reserveADivReserveB = double.parse(json["tokenA"]['reserve']) /
        double.parse(json["tokenB"]['reserve']);
    this.reserveBDivReserveA = double.parse(json["tokenB"]['reserve']) /
        double.parse(json["tokenA"]['reserve']);
    this.totalLiquidityRaw =
        convertToSatoshi(double.parse(json["totalLiquidity"]['token']));
    this.totalLiquidity = double.parse(json["totalLiquidity"]['token']);
    this.totalLiquidityUsd = double.parse(json["totalLiquidity"]['usd']);

    var _apr = json["apr"]['total'];

    if (_apr is int) {
      this.apr = _apr + .0;
    } else {
      this.apr = _apr ?? 0;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["id"] = this.id;
    data["symbol"] = this.symbol;
    data["tokenA"] = this.tokenA;
    data["tokenB"] = this.tokenB;
    data["status"] = this.status;
    data["reserveA"] = this.reserveA;
    data["reserveB"] = this.reserveB;
    data["reserveADivReserveB"] = this.reserveADivReserveB;
    data["reserveBDivReserveA"] = this.reserveBDivReserveA;
    data["totalLiquidityRaw"] = this.totalLiquidityRaw;
    data["totalLiquidity"] = this.totalLiquidity;
    data["totalLiquidityUsd"] = this.totalLiquidityUsd;
    data["apr"] = this.apr;
    return data;
  }
}