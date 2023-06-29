part of 'rates_cubit.dart';

enum RatesStatusList { initial, loading, success, failure }

class RatesState extends Equatable {
  final RatesStatusList status;
  final RatesModel? ratesModel;
  final List<TokenModel> tokens;

  RatesState({
    this.status = RatesStatusList.initial,
    this.ratesModel,
    this.tokens = const [],
  });

  List<TokenModel> get foundTokens {
    try {
      final tokens =
          this.tokens.isNotEmpty ? this.tokens : this.ratesModel!.tokens!;

      return tokens
          .where((element) => !element.isPair && !element.symbol.contains('v1'))
          .toList();
    } catch (err) {
      return [];
    }
  }

  @override
  List<Object?> get props => [
        status,
        ratesModel,
        tokens,
      ];

  RatesState copyWith({
    RatesStatusList? status,
    RatesModel? ratesModel,
    List<TokenModel>? tokens = const [],
  }) {
    return RatesState(
      status: status ?? this.status,
      ratesModel: ratesModel ?? this.ratesModel,
      tokens: tokens ?? this.tokens,
    );
  }
}
