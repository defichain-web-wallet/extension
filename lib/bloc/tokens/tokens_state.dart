part of 'tokens_cubit.dart';

enum TokensStatusList { initial, loading, success, failure }

class TokensState extends Equatable {
  final TokensStatusList status;
  final List<TokensModel>? tokens;
  final List<dynamic>? foundTokens;
  final Map<dynamic, dynamic>? tokensForSwap;
  final List<AssetPairModel>? tokensPairs;
  final double? eurRate;

  TokensState({
    this.status = TokensStatusList.initial,
    this.tokens,
    this.foundTokens,
    this.tokensForSwap,
    this.tokensPairs,
    this.eurRate,
  });

  @override
  List<Object?> get props => [
        status,
        tokens,
        foundTokens,
        tokensForSwap,
        tokensPairs,
        eurRate,
      ];

  TokensState copyWith({
    TokensStatusList? status,
    List<TokensModel>? tokens,
    List<dynamic>? foundTokens,
    Map<dynamic, dynamic>? tokensForSwap,
    List<AssetPairModel>? tokensPairs,
    double? eurRate,
  }) {
    return TokensState(
      status: status ?? this.status,
      tokens: tokens ?? this.tokens,
      foundTokens: foundTokens ?? this.foundTokens,
      tokensForSwap: tokensForSwap ?? this.tokensForSwap,
      tokensPairs: tokensPairs ?? this.tokensPairs,
      eurRate: eurRate ?? this.eurRate,
    );
  }
}