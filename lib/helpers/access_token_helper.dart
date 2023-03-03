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
    bool isDfx = true,
    bool isLock = true,
  }) async {
    LockCubit lockCubit = BlocProvider.of<LockCubit>(context);
    FiatCubit fiatCubit = BlocProvider.of<FiatCubit>(context);
    AccountCubit accountCubit = BlocProvider.of<AccountCubit>(context);

    showDialog(
      barrierColor: Color(0x0f180245),
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context1) {
        return PassConfirmDialog(
          message: 'Please entering your password for create account',
          onSubmit: (password) async {
            var keyPair = await HDWalletService().getKeypairFromStorage(
              password,
              accountCubit.state.accounts!.first.index!,
            );
            if (isLock) {
              String? lockAccessToken = await lockCubit.createLockAccount(
                accountCubit.state.accounts!.first,
                keyPair,
              );
              accountCubit.state.accounts!.first.lockAccessToken = lockAccessToken;
            }

            if (isDfx) {
              String? accessToken = await fiatCubit.signUp(
                accountCubit.state.accounts!.first,
                keyPair,
              );
              accountCubit.state.accounts!.first.accessToken = accessToken;
            }

            await accountCubit.saveAccountsToStorage(
              accountsMainnet: accountCubit.state.accounts!,
            );

            callback();
          },
          context: context,
        );
      },
    );
  }
}