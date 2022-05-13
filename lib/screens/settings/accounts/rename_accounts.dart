import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/account/account_state.dart';
import 'package:defi_wallet/bloc/transaction/transaction_bloc.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/screens/settings/accounts/account_name_text_form.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_constrained_box.dart';
import 'package:defi_wallet/widgets/toolbar/main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RenameAccounts extends StatelessWidget {
  static double toolbarHeight = 55;
  static double toolbarHeightWithBottom = 105;

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<TransactionCubit, TransactionState>(
          builder: (context, state) => ScaffoldConstrainedBox(
                  child: LayoutBuilder(builder: (context, constraints) {
                if (constraints.maxWidth < ScreenSizes.medium) {
                  return Scaffold(
                    appBar: MainAppBar(
                        title: 'Rename accounts',
                        isShowBottom: !(state is TransactionInitialState),
                        height: !(state is TransactionInitialState)
                            ? toolbarHeightWithBottom
                            : toolbarHeight),
                    body: _buildBody(context),
                  );
                } else {
                  return Container(
                    padding: const EdgeInsets.only(top: 20),
                    child: Scaffold(
                      appBar: MainAppBar(
                        title: 'Rename accounts',
                        isShowBottom: !(state is TransactionInitialState),
                        height: !(state is TransactionInitialState)
                            ? toolbarHeightWithBottom
                            : toolbarHeight,
                        isSmall: true,
                      ),
                      body: _buildBody(context, isCustomBgColor: true),
                    ),
                  );
                }
              })));

  Widget _buildBody(context, {isCustomBgColor = false}) {
    return BlocBuilder<AccountCubit, AccountState>(builder: (context, state) {
      if (state is AccountLoadedState) {
        var accountList = state.accounts;

        return Container(
          height: double.infinity,
          color:
              isCustomBgColor ? Theme.of(context).dialogBackgroundColor : null,
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                children: List.generate(
                  accountList.length,
                  (index) => StretchBox(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Account name',
                          style: Theme.of(context).textTheme.headline2,
                        ),
                        SizedBox(height: 8),
                        AccountNameTextForm(
                          initValue: accountList[index].name,
                          onConfirm: (text) {
                            accountList[index].name = text;
                            AccountCubit accountCubit =
                                BlocProvider.of<AccountCubit>(context);
                            accountCubit.updateAccountDetails(
                                state.mnemonic,
                                state.seed,
                                state.accounts,
                                state.masterKeyPair,
                                state.activeAccount);
                          },
                        ),
                        SizedBox(height: 18),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      } else {
        return Container();
      }
    });
  }
}
