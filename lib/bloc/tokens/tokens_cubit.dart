import 'dart:convert';

import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/refactoring/wallet/wallet_cubit.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/helpers/tokens_helper.dart';
import 'package:defi_wallet/models/balance/balance_model.dart';
import 'package:defi_wallet/models/token/token_model.dart';
import 'package:defi_wallet/models/token_model.dart';
import 'package:bloc/bloc.dart';
import 'package:defi_wallet/services/storage/storage_service.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'tokens_state.dart';

class TokensCubit extends Cubit<TokensState> {
  TokensCubit() : super(TokensState());
  var tokensHelper = TokensHelper();

  init(context) async {
    emit(state.copyWith(
      status: TokensStatusList.loading,
    ));

    final walletCubit = BlocProvider.of<WalletCubit>(context);
    var account = walletCubit.state.applicationModel!.activeAccount!;
    var network = walletCubit.state.applicationModel!.activeNetwork!;
    var tokens = await network.getAvailableTokens();
    var balances = account.getPinnedBalances(network, mergeCoin: true);

    tokens.removeWhere((token) => token.isPair);
    balances.forEach((balance) {
      tokens.removeWhere((token) => balance.token!.compare(token));
    });


    emit(state.copyWith(
      status: TokensStatusList.success,
      tokens: tokens,
      foundTokens: List.from(tokens),
    ));

  }

  addTokens(context, List<TokenModel> tokens) {
    final walletCubit = BlocProvider.of<WalletCubit>(context);
    var account = walletCubit.state.applicationModel!.activeAccount!;
    var network = walletCubit.state.applicationModel!.activeNetwork!;
    tokens.forEach((token) {
      account.pinToken(BalanceModel(balance: 0, token: token), network);
    });

    StorageService.saveApplication(walletCubit.state.applicationModel!);
  }

  void search(tokens, value) {
    List<TokenModel> search = [];
    if (value == '') {
      emit(state.copyWith(
        status: TokensStatusList.success,
        tokens: state.tokens,
        foundTokens: List.from(tokens),
      ));
    } else {
      tokens.forEach((element) {
        if (element.symbol.contains(value.toUpperCase())) {
          search.add(element);
        } else if (element.symbol
            .contains(value.replaceAll('d', '').toUpperCase())) {
          search.add(element);
        }
      });
      emit(state.copyWith(
        status: TokensStatusList.success,
        tokens: state.tokens,
        foundTokens: search,
      ));
    }
  }
}
