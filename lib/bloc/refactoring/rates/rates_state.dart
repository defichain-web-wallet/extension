part of 'rates_cubit.dart';

enum RatesStatusList { initial, loading, success, failure }

class RatesState extends Equatable {
  final RatesStatusList status;
  final RatesModel? ratesModel;
  final EthereumRateModel? ethereumRateModel;
  final List<TokenModel> tokens;
  final List<String> items;
  final String activeAsset;

  RatesState({
    this.status = RatesStatusList.initial,
    this.ratesModel,
    this.ethereumRateModel,
    this.tokens = const [],
    this.items = const ['USD', 'EUR', 'BTC'],
    this.activeAsset = 'USD',
  });

  List<TokenModel> get foundTokens {
    try {
      final tokens =
          this.tokens.isNotEmpty ? this.tokens : this.ratesModel!.tokens!;

      return tokens
          .where((element) =>
              !element.isPair &&
              !element.symbol.contains('v1') &&
              !element.isLPS &&
              element.isDAT)
          .toList();
    } catch (err) {
      return [];
    }
  }

  @override
  List<Object?> get props => [
        status,
        ratesModel,
        ethereumRateModel,
        tokens,
        items,
        activeAsset,
      ];

  RatesState copyWith({
    RatesStatusList? status,
    RatesModel? ratesModel,
    EthereumRateModel? ethereumRateModel,
    List<TokenModel>? tokens = const [],
    List<String>? items = const ['USD', 'EUR', 'BTC'],
    String? activeAsset = 'USD',
  }) {
    return RatesState(
      status: status ?? this.status,
      ratesModel: ratesModel ?? this.ratesModel,
      ethereumRateModel: ethereumRateModel ?? this.ethereumRateModel,
      tokens: tokens ?? this.tokens,
      items: items ?? this.items,
      activeAsset: activeAsset ?? this.activeAsset,
    );
  }
}
