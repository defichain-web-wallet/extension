part of 'tokens_cubit.dart';

enum TokensStatusList { initial, loading, success, failure }

class TokensState extends Equatable {
  final TokensStatusList status;
  final List<TokenModel>? tokens;
  final List<TokenModel>? foundTokens;
  TokensState({
    this.status = TokensStatusList.initial,
    this.tokens,
    this.foundTokens,
  });

  @override
  List<Object?> get props => [
        status,
        tokens,
        foundTokens,
      ];

  TokensState copyWith({
    TokensStatusList? status,
    List<TokenModel>? tokens,
    List<TokenModel>? foundTokens,
  }) {
    return TokensState(
      status: status ?? this.status,
      tokens: tokens ?? this.tokens,
      foundTokens: foundTokens ?? this.foundTokens,
    );
  }
}