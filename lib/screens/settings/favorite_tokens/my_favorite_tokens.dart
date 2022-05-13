import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/account/account_state.dart';
import 'package:defi_wallet/bloc/transaction/transaction_bloc.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/helpers/tokens_helper.dart';
import 'package:defi_wallet/models/balance_model.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:defi_wallet/widgets/buttons/accent_button.dart';
import 'package:defi_wallet/widgets/buttons/primary_button.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_constrained_box.dart';
import 'package:defi_wallet/widgets/toolbar/main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MyFavoriteTokens extends StatefulWidget {
  @override
  _MyFavoriteTokensState createState() => _MyFavoriteTokensState();
}

class _MyFavoriteTokensState extends State<MyFavoriteTokens> {
  TokensHelper tokenHelper = TokensHelper();
  bool balanceHiddenInit = true;
  int changedButtonCounter = 0;
  int activeButtonCounter = 0;
  List<BalanceModel>? balanceList = [];
  Map balanceCheckMap = Map();
  double toolbarHeight = 55;
  double toolbarHeightWithBottom = 105;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionCubit, TransactionState>(
      builder: (context, state) => ScaffoldConstrainedBox(
          child: LayoutBuilder(builder: (context, constraints) {
            if (constraints.maxWidth < ScreenSizes.medium) {
              return Scaffold(
                appBar: MainAppBar(
                    title: 'My favorite tokens',
                    isShowBottom: !(state is TransactionInitialState),
                    height: !(state is TransactionInitialState)
                        ? toolbarHeightWithBottom
                        : toolbarHeight
                ),
                body: _buildBody(context),
              );
            } else {
              return Container(
                padding: const EdgeInsets.only(top: 20),
                child: Scaffold(
                  appBar: MainAppBar(
                    title: 'My favorite tokens',
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
          }))
    );
  }

  Widget _buildBody(context, {isCustomBgColor = false}) {
    return BlocBuilder<AccountCubit, AccountState>(builder: (context, state) {
      if (state is AccountLoadedState) {
        if (balanceHiddenInit) {
          balanceHiddenInit = false;
          balanceList = state.activeAccount.balanceList!;
          balanceList!.forEach((balance) {
            balanceCheckMap[balance] = balance.isHidden;
            if (!balance.isHidden!) activeButtonCounter++;
          });
        }
        return Container(
          color:
              isCustomBgColor ? Theme.of(context).dialogBackgroundColor : null,
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Center(
            child: StretchBox(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: balanceList!.length,
                        itemBuilder: (context, index) {
                          final tokenName = (balanceList![index].token != 'DFI')
                              ? 'd' + balanceList![index].token!
                              : balanceList![index].token;
                          return ListTile(
                            title: Text(
                              '$tokenName',
                              style: Theme.of(context).textTheme.headline6,
                            ),
                            leading: SvgPicture.asset(
                              tokenHelper.getImageNameByTokenName(
                                  balanceList![index].token!),
                              fit: BoxFit.scaleDown,
                              width: 30,
                              height: 30,
                            ),
                            trailing: Icon(
                              balanceCheckMap[balanceList![index]]
                                  ? Icons.radio_button_unchecked
                                  : Icons.check_circle,
                              color: balanceCheckMap[balanceList![index]]
                                  ? Colors.grey
                                  : AppTheme.pinkColor,
                            ),
                            onTap: () {
                              setState(() {
                                if (balanceList![index].token != 'DFI') {
                                  balanceCheckMap[balanceList![index]] =
                                      !balanceCheckMap[balanceList![index]];
                                  if (balanceList![index].isHidden !=
                                      balanceCheckMap[balanceList![index]]) {
                                    changedButtonCounter++;
                                  } else {
                                    changedButtonCounter--;
                                  }
                                  if (!balanceCheckMap[balanceList![index]]) {
                                    activeButtonCounter++;
                                  } else {
                                    activeButtonCounter--;
                                  }
                                }
                              });
                            },
                          );
                        }),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: AccentButton(
                              label: 'Cancel',
                              callback: () => Navigator.of(context).pop()),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: PrimaryButton(
                            label: 'Save',
                            callback: changedButtonCounter > 0 &&
                                    activeButtonCounter > 0
                                ? () => submit(state)
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      } else {
        return Container();
      }
    });
  }

  void submit(state) {
    balanceList!
        .forEach((balance) => balance.isHidden = balanceCheckMap[balance]);

    var activeToken = state.activeAccount.activeToken;
    balanceList!.forEach((balance) {
      var tokenName = balance.token;
      if (activeToken == tokenName && balance.isHidden!) {
        tokenName = balanceList!.firstWhere((el) => !el.isHidden!).token;
        activeToken = tokenName;
      }
    });

    state.activeAccount.balanceList = balanceList!.cast<BalanceModel>();
    state.activeAccount.activeToken = activeToken;
    AccountCubit accountCubit = BlocProvider.of<AccountCubit>(context);
    accountCubit.updateActiveToken(
      state.mnemonic,
      state.seed,
      state.accounts,
      state.balances,
      state.masterKeyPair,
      state.activeAccount,
      activeToken,
    );
    if (SettingsHelper.settings.network! == 'testnet') {
      accountCubit.saveAccountInfoToStorage(
          null, null, state.accounts, state.masterKeyPair);
    } else {
      accountCubit.saveAccountInfoToStorage(
          state.accounts, state.masterKeyPair, null, null);
    }

    Navigator.of(context).pop();
  }
}
