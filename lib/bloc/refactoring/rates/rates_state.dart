part of 'rates_cubit.dart';

enum RatesStatusList { initial, loading, success, failure }

class RatesState extends Equatable {
  final RatesStatusList status;
  final RatesModel? ratesModel;
  final List<TokenModel>? tokens;
  final List<AssetPairModel>? poolPairs;

  RatesState({
    this.status = RatesStatusList.initial,
    this.ratesModel,
    this.tokens,
    this.poolPairs,
  });

  @override
  List<Object?> get props => [
        status,
        ratesModel,
        tokens,
        poolPairs,
      ];

  double convertAmountBalance(
    AbstractNetworkModel networkModel,
    BalanceModel balanceModel, {
    String convertToken = 'USDT',
  }) {
    double amount = networkModel.fromSatoshi(balanceModel.balance);
    if (balanceModel.token != null) {
      return getAmountByToken(amount, balanceModel.token!);
    } else {
      return getPoolPairsByToken(balanceModel.balance, balanceModel.lmPool!);
    }
  }

  double getTotalAmount(
    AbstractNetworkModel networkModel,
    List<BalanceModel> balances, {
    String convertToken = 'USDT',
  }) {
    return balances.map<double>((e) {
      if (e.token != null) {
        return getAmountByToken(
          networkModel.fromSatoshi(e.balance),
          e.token!,
          convertToken: convertToken,
        );
      } else {
        return getPoolPairsByToken(
          e.balance,
          e.lmPool!,
          convertToken: convertToken,
        );
      }
    }).reduce((value, element) => value + element);
  }

  double getAmountByToken(
    double amount,
    TokenModel token, {
    String convertToken = 'USDT',
  }) {
    String symbol = '$convertToken-DFI';
    String testnetSymbol = 'DFI-$convertToken';

    try {
      AssetPairModel assetPair = this.poolPairs!.firstWhere((element) =>
          element.symbol! == symbol || element.symbol! == testnetSymbol);
      if (token.symbol == 'DFI') {
        return assetPair.reserveADivReserveB! * amount;
      }

      // TODO: convert to DUSD doesn't work correctly. Need to check later
      AssetPairModel targetPair = this.poolPairs!.firstWhere((item) {
        return item.tokenA == token.symbol &&
            (item.tokenB == 'DFI' || item.tokenB == 'DUSD');
      });

      double dfiByConvertToken = assetPair.reserveADivReserveB!;
      double dfiByToken = targetPair.reserveBDivReserveA!;

      double result;
      if (targetPair.tokenB == 'DUSD') {
        result = (dfiByConvertToken * amount);
        return result;
      } else {
        double result = (dfiByToken * amount) * dfiByConvertToken;
        return result;
      }
    } catch (err) {
      return 0.00;
    }
  }

  double getPoolPairsByToken(
    int satoshi,
    LmPoolModel lmPoolModel, {
    String convertToken = 'USDT',
  }) {
    try {
      AssetPairModel assetPair = this
          .poolPairs!
          .firstWhere((element) => element.symbol! == lmPoolModel.symbol);
      double baseBalance =
          satoshi * (1 / assetPair.totalLiquidityRaw!) * assetPair.reserveA!;
      double quoteBalance =
          satoshi * (1 / assetPair.totalLiquidityRaw!) * assetPair.reserveB!;
      double baseBalanceByAsset;
      double quoteBalanceByAsset;

      TokenModel baseAsset = lmPoolModel.tokens[0];
      TokenModel quoteAsset = lmPoolModel.tokens[1];

      baseBalanceByAsset = getAmountByToken(
        baseBalance,
        baseAsset,
        convertToken: convertToken,
      );
      quoteBalanceByAsset = getAmountByToken(
        quoteBalance,
        quoteAsset,
        convertToken: convertToken,
      );

      return baseBalanceByAsset + quoteBalanceByAsset;
    } catch (_) {
      return 0.00;
    }
  }

  RatesState copyWith({
    RatesStatusList? status,
    RatesModel? ratesModel,
    List<TokenModel>? tokens,
    List<AssetPairModel>? poolPairs,
  }) {
    return RatesState(
      status: status ?? this.status,
      ratesModel: ratesModel ?? this.ratesModel,
      tokens: tokens ?? this.tokens,
      poolPairs: poolPairs ?? this.poolPairs,
    );
  }
}
