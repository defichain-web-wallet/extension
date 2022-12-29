import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/bitcoin/bitcoin_cubit.dart';
import 'package:defi_wallet/bloc/tokens/tokens_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_bloc.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/helpers/tokens_helper.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/services/hd_wallet_service.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/account_drawer/account_drawer.dart';
import 'package:defi_wallet/widgets/buttons/accent_button.dart';
import 'package:defi_wallet/widgets/buttons/flat_button.dart';
import 'package:defi_wallet/widgets/loader/loader_new.dart';
import 'package:defi_wallet/widgets/pass_confirm_dialog.dart';
import 'package:defi_wallet/widgets/password_bottom_sheet.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_constrained_box.dart';
import 'package:defi_wallet/helpers/balances_helper.dart';
import 'package:defi_wallet/models/token_model.dart';
import 'package:defi_wallet/screens/dex/swap_status.dart';
import 'package:defi_wallet/services/transaction_service.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:defi_wallet/widgets/buttons/restore_button.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/toolbar/main_app_bar.dart';
import 'package:defi_wallet/widgets/toolbar/new_main_app_bar.dart';
import 'package:defichaindart/defichaindart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SwapSummaryScreen extends StatefulWidget {
  final String assetFrom;
  final String assetTo;
  final double amountFrom;
  final double amountTo;
  final double slippage;
  final String btcTx;

  const SwapSummaryScreen(this.assetFrom, this.assetTo, this.amountFrom,
      this.amountTo, this.slippage,
      {this.btcTx = ''});

  @override
  _SwapSummaryScreenState createState() => _SwapSummaryScreenState();
}

class _SwapSummaryScreenState extends State<SwapSummaryScreen> with ThemeMixin {
  BalancesHelper balancesHelper = BalancesHelper();
  TransactionService transactionService = TransactionService();
  bool isFailed = false;
  double toolbarHeight = 55;
  double toolbarHeightWithBottom = 105;
  String secondStepLoaderText =
      'One second, Jelly is preparing your transaction!';
  String appBarTitle = 'Swap';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionCubit, TransactionState>(
      builder: (context, state) {
        return ScaffoldWrapper(
          builder: (
            BuildContext context,
            bool isFullScreen,
            TransactionState transactionState,
          ) {
            return Scaffold(
              appBar: NewMainAppBar(
                isShowLogo: false,
              ),
              drawerScrimColor: Color(0x0f180245),
              endDrawer: AccountDrawer(
                width: buttonSmallWidth,
              ),
              body: Container(
                padding: EdgeInsets.only(
                  top: 22,
                  bottom: 22,
                  left: 16,
                  right: 16,
                ),
                decoration: BoxDecoration(
                  color: isDarkTheme()
                      ? DarkColors.scaffoldContainerBgColor
                      : LightColors.scaffoldContainerBgColor,
                  border: isDarkTheme()
                      ? Border.all(
                          width: 1.0,
                          color: Colors.white.withOpacity(0.05),
                        )
                      : null,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20),
                    topLeft: Radius.circular(20),
                  ),
                ),
                child: _buildBody(context),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBody(context, {isCustomBgColor = false}) => StretchBox(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Summary',
                    style: Theme.of(context).textTheme.headline3,
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Container(
                    width: double.infinity,
                    height: 168,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1.0,
                        color: AppColors.lavenderPurple.withOpacity(0.35),
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(12),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          child: Column(
                            children: [
                              Text(
                                'Do you really want to change',
                                style: Theme.of(context)
                                    .textTheme
                                    .headline5!
                                    .copyWith(
                                      fontSize: 12,
                                      color: Theme.of(context)
                                          .textTheme
                                          .headline5!
                                          .color!
                                          .withOpacity(0.5),
                                    ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: SvgPicture.asset(
                                      TokensHelper().getImageNameByTokenName(widget.assetFrom),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 6,
                                  ),
                                  Text(
                                    widget.amountFrom.toString(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline3!
                                        .copyWith(
                                      fontSize: 20,
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                        Text(
                          'to',
                          style: Theme.of(context)
                              .textTheme
                              .headline5!
                              .copyWith(
                            fontSize: 12,
                            color: Theme.of(context)
                                .textTheme
                                .headline5!
                                .color!
                                .withOpacity(0.5),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: SvgPicture.asset(
                                TokensHelper().getImageNameByTokenName(widget.assetTo),
                              ),
                            ),
                            SizedBox(
                              width: 6,
                            ),
                            Text(
                              widget.amountTo.toString(),
                              style: Theme.of(context)
                                  .textTheme
                                  .headline3!
                                  .copyWith(
                                fontSize: 20,
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Some error. Please try later',
                      style: Theme.of(context).textTheme.headline4!.copyWith(
                            color: isFailed
                                ? AppTheme.redErrorColor
                                : Colors.transparent,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: BlocBuilder<AccountCubit, AccountState>(
                  builder: (context, state) {
                return BlocBuilder<TokensCubit, TokensState>(
                  builder: (context, tokensState) {
                    if (tokensState.status == TokensStatusList.success) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 104,
                            child: FlatButton(
                              title: 'Cancel',
                              isPrimary: false,
                              callback: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                          SizedBox(
                            width: 104,
                            child: PendingButton(
                              'Change',
                              isCheckLock: false,
                              callback: (parent) {
                                if (widget.btcTx != '') {
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder:
                                          (context, animation1, animation2) =>
                                          LoaderNew(
                                            title: appBarTitle,
                                            secondStepLoaderText: secondStepLoaderText,
                                            callback: () {
                                              submitSwap(state, tokensState, "");
                                            },
                                          ),
                                      transitionDuration: Duration.zero,
                                      reverseTransitionDuration: Duration.zero,
                                    ),
                                  );
                                } else {
                                  showDialog(
                                    barrierColor: Color(0x0f180245),
                                    barrierDismissible: false,
                                    context: context,
                                    builder: (BuildContext context1) {
                                      return PassConfirmDialog(
                                        onSubmit: (password) async {
                                          await submitSwap(
                                            state,
                                            tokensState,
                                            password,
                                          );
                                        }
                                      );
                                    },
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      );
                    } else {
                      return Container();
                    }
                  },
                );
              }),
            )
          ],
        ),
      );

  submitSwap(state, tokenState, String password) async {
    if (state.status == AccountStatusList.success) {
      try {
        if (widget.btcTx != '') {
          BitcoinCubit bitcoinCubit = BlocProvider.of<BitcoinCubit>(context);
          var txResponse = await bitcoinCubit.sendTransaction(widget.btcTx);
          Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) =>
                    SwapStatusScreen(
                        appBarTitle: appBarTitle,
                        txResponse: txResponse,
                        amount: widget.amountFrom,
                        assetFrom: widget.assetFrom,
                        assetTo: widget.assetTo),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ));
        }
        if (widget.assetFrom != widget.assetTo) {
          ECPair keyPair = await HDWalletService()
              .getKeypairFromStorage(password, state.activeAccount.index!);
          var txResponse = await transactionService.createAndSendSwap(
              keyPair: keyPair,
              account: state.activeAccount,
              tokenFrom: widget.assetFrom,
              tokenTo: widget.assetTo,
              amount: balancesHelper.toSatoshi(widget.amountFrom.toString()),
              amountTo: balancesHelper.toSatoshi(widget.amountTo.toString()),
              slippage: widget.slippage,
              tokens: tokenState.tokens);
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) =>
                  SwapStatusScreen(
                      appBarTitle: appBarTitle,
                      txResponse: txResponse,
                      amount: widget.amountFrom,
                      assetFrom: widget.assetFrom,
                      assetTo: widget.assetTo),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        }
      } catch (err) {
        setState(() {
          isFailed = true;
        });
      }
    }
  }
}
