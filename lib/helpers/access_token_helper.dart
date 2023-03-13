import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/fiat/fiat_cubit.dart';
import 'package:defi_wallet/bloc/lock/lock_cubit.dart';
import 'package:defi_wallet/services/hd_wallet_service.dart';
import 'package:defi_wallet/widgets/dialogs/pass_confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AccessTokenHelper {
  static setupLockAccessToken(
    BuildContext context,
    Function callback, {
    String dialogMessage = '',
    bool needUpdateDfx = true,
    bool needUpdateLock = true,
    bool isExistingAccount = false,
  }) async {


    showDialog(
      barrierColor: Color(0x0f180245),
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context1) {
        return PassConfirmDialog(
          message: dialogMessage,
          onSubmit: (password) async {
            await _onSubmitAccessTokenDialog(
              context,
              password,
              needUpdateDfx: needUpdateDfx,
              needUpdateLock: needUpdateLock,
              isExistingAccount: isExistingAccount,
            );
            callback();
          },
          context: context,
        );
      },
    );
  }

  static _onSubmitAccessTokenDialog(
    BuildContext context,
    String password, {
    bool needUpdateDfx = true,
    bool needUpdateLock = true,
    bool isExistingAccount = false,
  }) async {
    LockCubit lockCubit = BlocProvider.of<LockCubit>(context);
    FiatCubit fiatCubit = BlocProvider.of<FiatCubit>(context);
    AccountCubit accountCubit = BlocProvider.of<AccountCubit>(context);

    var keyPair = await HDWalletService().getKeypairFromStorage(
      password,
      accountCubit.state.accounts!.first.index!,
    );
    if (needUpdateLock) {
      String? lockAccessToken;
      if (isExistingAccount) {
        lockAccessToken = await lockCubit.signIn(
          accountCubit.state.accounts!.first,
          keyPair,
        );
      } else {
        lockAccessToken = await lockCubit.createLockAccount(
          accountCubit.state.accounts!.first,
          keyPair,
        );
      }
      accountCubit.state.accounts!.first.lockAccessToken = lockAccessToken;
    }

    if (needUpdateDfx) {
      String? dfxAccessToken;
      if (isExistingAccount) {
        dfxAccessToken = await fiatCubit.signIn(
          accountCubit.state.accounts!.first,
          keyPair,
        );
      } else {
        dfxAccessToken = await fiatCubit.signUp(
          accountCubit.state.accounts!.first,
          keyPair,
        );
      }
      accountCubit.state.accounts!.first.accessToken = dfxAccessToken;
    }

    await accountCubit.saveAccountsToStorage(
      accountsMainnet: accountCubit.state.accounts!,
    );
  }
}