import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_bloc.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/client/hive_names.dart';
import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/screens/settings/accounts/account_name_text_form.dart';
import 'package:defi_wallet/widgets/loader/loader.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_constrained_box.dart';
import 'package:defi_wallet/widgets/toolbar/main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RenameAccounts extends StatefulWidget {
  static double toolbarHeight = 55;
  static double toolbarHeightWithBottom = 105;

  @override
  State<RenameAccounts> createState() => _RenameAccountsState();
}

class _RenameAccountsState extends State<RenameAccounts> {
  @override
  Widget build(BuildContext context) =>
      BlocBuilder<TransactionCubit, TransactionState>(
        builder: (context, transactionState) =>
            BlocBuilder<AccountCubit, AccountState>(
          builder: (context, state) => ScaffoldConstrainedBox(
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < ScreenSizes.medium) {
                  return Scaffold(
                    appBar: MainAppBar(
                      title: 'Rename accounts',
                    ),
                    body: _buildBody(state, context),
                  );
                } else {
                  return Container(
                    padding: const EdgeInsets.only(top: 20),
                    child: Scaffold(
                      appBar: MainAppBar(
                        title: 'Rename accounts',
                        isSmall: true,
                      ),
                      body: _buildBody(state, context, isCustomBgColor: true),
                    ),
                  );
                }
              },
            ),
          ),
        ),
      );

  Widget _buildBody(state, context, {isCustomBgColor = false}) {
    if (state.status == AccountStatusList.success) {
      var accountList = state.accounts;

      return Container(
        height: double.infinity,
        color: Theme.of(context).dialogBackgroundColor,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: List.generate(
                accountList!.length,
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
                        isBorder: isCustomBgColor,
                        initValue: accountList[index].name,
                        onConfirm: (text) {
                          accountList[index].name = text;
                          AccountCubit accountCubit =
                              BlocProvider.of<AccountCubit>(context);
                          accountCubit.setAccountName();
                          if (SettingsHelper.settings.network == 'mainnet') {
                            AccountCubit accountCubit =
                                BlocProvider.of<AccountCubit>(context);
                            accountCubit.saveAccountsToStorage(
                                accountsMainnet: state.accounts,);
                          }
                          if (SettingsHelper.settings.network == 'testnet') {
                            AccountCubit accountCubit =
                                BlocProvider.of<AccountCubit>(context);
                            accountCubit.saveAccountsToStorage(
                              accountsTestnet: state.accounts,);
                          }
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
      return Loader();
    }
  }
}
