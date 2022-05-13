import 'dart:developer';

import 'package:defi_wallet/helpers/tokens_helper.dart';
import 'package:defi_wallet/models/token_model.dart';
import 'package:defi_wallet/requests/dex_requests.dart';
import 'package:defi_wallet/requests/token_requests.dart';
import 'package:bloc/bloc.dart';
import 'tokens_state.dart';

class TokensCubit extends Cubit<TokensState> {
  TokensCubit() : super(TokensInitialState());
  var tokensHelper = TokensHelper();

  void loadTokens() async {
    emit(TokensLoadingState());
    final tokens = await TokenRequests().getTokenList();
    final tokensDex = await DexRequests().getPoolPairs();
    final eurRate = await TokenRequests().getEurByUsdRate();

    try {
      emit(TokensLoadedState(tokens, List.from(tokens), tokensDex[0],
          List.from(tokensDex[1]), eurRate));
    } catch (err) {
      emit(TokensLoadedState(tokens, List.from(tokens), null, null, eurRate));
    }
  }

  void search(tokens, value) {
    List<TokensModel> search = [];
    if (value == '') {
      emit(TokensLoadedState(tokens, List.from(tokens), [], [], 1));
    } else {
      tokens.forEach((element) {
        if (element.symbol.contains(value.toUpperCase())){
          search.add(element);
        } else if (element.symbol.contains(value.replaceAll('d', '').toUpperCase())){
          search.add(element);
        }
      });
      emit(TokensLoadedState(tokens, search, [], [], 1));
    }
  }
}
