import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:defi_wallet/widgets/accounts/account_name_text_form.dart';
import 'package:defi_wallet/widgets/loader/loader.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/toolbar/main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RenameAccountsScreen extends StatelessWidget {
  static double toolbarHeight = 55;
  static double toolbarHeightWithBottom = 105;

  @override
  Widget build(BuildContext context) {
    return ScaffoldWrapper(
      builder: (
        BuildContext context,
        bool isFullScreen,
        TransactionState txState,
      ) {
        return BlocBuilder<AccountCubit, AccountState>(
          builder: (context, state) {
            if (state.status == AccountStatusList.success) {
              var accountList = state.accounts;

              return Scaffold(
                appBar: MainAppBar(
                  title: 'Rename accounts',
                  isSmall: isFullScreen,
                ),
                body: Container(
                  height: double.infinity,
                  color: Theme.of(context).dialogBackgroundColor,
                  padding: AppTheme.screenPadding,
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
                                  isBorder: isFullScreen,
                                  initValue: accountList[index].name,
                                  onConfirm: (text) {
                                    accountList[index].name = text;
                                    AccountCubit accountCubit =
                                        BlocProvider.of<AccountCubit>(context);
                                    accountCubit.updateAccountDetails();
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
                ),
              );
            } else {
              return Loader();
            }
          },
        );
      },
    );
  }
}
