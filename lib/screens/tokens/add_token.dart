import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_bloc.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/models/token_model.dart';
import 'package:defi_wallet/screens/home/home_screen.dart';
import 'package:defi_wallet/widgets/buttons/accent_button.dart';
import 'package:defi_wallet/widgets/buttons/primary_button.dart';
import 'package:defi_wallet/widgets/loader/loader.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_constrained_box.dart';
import 'package:defi_wallet/widgets/toolbar/main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:defi_wallet/services/logger_service.dart';

class AddToken extends StatefulWidget {
  final List<String> arguments;

  const AddToken({Key? key, required this.arguments}) : super(key: key);

  @override
  State<AddToken> createState() => _AddTokenState();
}

class _AddTokenState extends State<AddToken> {
  List<String> symbols = [];
  double toolbarHeight = 55;
  double toolbarHeightWithBottom = 105;

  @override
  Widget build(BuildContext context) {
    symbols = widget.arguments;
    return BlocBuilder<TransactionCubit, TransactionState>(
        builder: (context, state) => ScaffoldConstrainedBox(
                child: LayoutBuilder(builder: (context, constraints) {
              if (constraints.maxWidth < ScreenSizes.medium) {
                return Scaffold(
                  appBar: MainAppBar(
                    title: 'Add Tokens',
                    isShowBottom: !(state is TransactionInitialState),
                    height: !(state is TransactionInitialState)
                        ? toolbarHeightWithBottom
                        : toolbarHeight,
                  ),
                  body: _buildBody(context),
                );
              } else {
                return Container(
                  padding: const EdgeInsets.only(top: 20),
                  child: Scaffold(
                    appBar: MainAppBar(
                      title: 'Add Tokens',
                      action: null,
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
  }

  Widget _buildBody(context, {isCustomBgColor = false}) =>
      BlocBuilder<AccountCubit, AccountState>(builder: (context, state) {
        if (state.status == AccountStatusList.success) {
          return Container(
            color: isCustomBgColor
                ? Theme.of(context).dialogBackgroundColor
                : null,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Center(
              child: StretchBox(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 26),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Token',
                            style: Theme.of(context).textTheme.headline6,
                          ),
                          Text(
                            'Balance',
                            style: Theme.of(context).textTheme.headline6,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        itemCount: symbols.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: SvgPicture.asset(
                              tokenHelper
                                  .getImageNameByTokenName(symbols[index]),
                              height: 30,
                              width: 30,
                            ),
                            title: Text(
                              (symbols[index] != 'DFI')
                                  ? 'd' + symbols[index]
                                  : symbols[index],
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                            trailing: Text(
                              '0',
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                          );
                        },
                        separatorBuilder: (context, index) => Divider(
                          height: 4,
                          color: Theme.of(context).scaffoldBackgroundColor,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: AccentButton(
                              label: 'Cancel',
                              callback: () => Navigator.of(context).pop(),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: PrimaryButton(
                              label: 'Add token',
                              callback: () => submitAddToken(state),
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
          return Loader();
        }
      });

  submitAddToken(state) async {
    AccountCubit accountCubit = BlocProvider.of<AccountCubit>(context);

    for (var tokenName in symbols) {
      await accountCubit.addToken(tokenName);
    }
    LoggerService.invokeInfoLogg('user added new token');
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => HomeScreen(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }
}
