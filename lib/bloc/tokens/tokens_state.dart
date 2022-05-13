abstract class TokensState {}

class TokensInitialState extends TokensState {}

class TokensLoadingState extends TokensState {}

class TokensLoadedState extends TokensState {
  final tokens;
  final foundTokens;
  final tokensForSwap;
  final tokensPairs;
  final eurRate;

  TokensLoadedState(this.tokens, this.foundTokens, this.tokensForSwap,
      this.tokensPairs, this.eurRate);
}

class TokensErrorState extends TokensState {}
