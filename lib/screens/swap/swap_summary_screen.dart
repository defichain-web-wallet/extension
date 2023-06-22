import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/bitcoin/bitcoin_cubit.dart';
import 'package:defi_wallet/bloc/refactoring/exchange/exchange_cubit.dart';
import 'package:defi_wallet/bloc/tokens/tokens_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_bloc.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/helpers/tokens_helper.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/models/tx_error_model.dart';
import 'package:defi_wallet/screens/home/home_screen.dart';
import 'package:defi_wallet/screens/ledger/ledger_check_screen.dart';
import 'package:defi_wallet/services/hd_wallet_service.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/account_drawer/account_drawer.dart';
import 'package:defi_wallet/widgets/assets/asset_logo.dart';
import 'package:defi_wallet/widgets/buttons/flat_button.dart';
import 'package:defi_wallet/widgets/dialogs/pass_confirm_dialog.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/helpers/balances_helper.dart';
import 'package:defi_wallet/services/transaction_service.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:defi_wallet/widgets/buttons/restore_button.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/toolbar/new_main_app_bar.dart';
import 'package:defi_wallet/widgets/dialogs/tx_status_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SwapSummaryScreen extends StatefulWidget {
  // final String assetFrom;
  // final String assetTo;
  // final double amountFrom;
  // final double amountTo;
  // final double slippage;
  // final String btcTx;

  const SwapSummaryScreen();

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
              drawerScrimColor: AppColors.tolopea.withOpacity(0.06),
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

  Widget _buildBody(context, {isCustomBgColor = false}) => BlocBuilder<ExchangeCubit, ExchangeState>(
  builder: (context, state) {
    ExchangeCubit exchangeCubit = BlocProvider.of<ExchangeCubit>(context);
    return StretchBox(
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
                                  AssetLogo(
                                    size: 24,
                                    assetStyle:
                                    TokensHelper().getAssetStyleByTokenName(state.selectedBalance!.token!.symbol),
                                    borderWidth: 0,
                                    isBorder: false,

                                  ),
                                  SizedBox(
                                    width: 6,
                                  ),
                                  Text(
                                    state.amountFrom.toString(),
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
                          style:
                              Theme.of(context).textTheme.headline5!.copyWith(
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
                            AssetLogo(
                              size: 24,
                              assetStyle:
                              TokensHelper().getAssetStyleByTokenName(state.selectedSecondInputBalance!.token!.symbol),
                              borderWidth: 0,
                              isBorder: false,
                            ),
                            SizedBox(
                              width: 6,
                            ),
                            Text(
                              state.amountTo.toString(),
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
              child: Row(
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
                              pendingText: 'Pending',
                              isCheckLock: false,
                              callback: (parent) async {
                                // final isLedger =
                                //     await SettingsHelper.isLedger();
                                //
                                // parent.emitPending(true);
                                // if (widget.btcTx != '') {
                                //   submitSwap(state, tokensState, "");
                                // } else if (!isLedger) {
                                  showDialog(
                                    barrierColor: AppColors.tolopea.withOpacity(0.06),
                                    barrierDismissible: false,
                                    context: context,
                                    builder: (BuildContext context1) {
                                      return PassConfirmDialog(
                                          onSubmit: (password) async {
                                        parent.emitPending(true);
                                        await submitSwap(
                                          context,
                                          state,
                                          exchangeCubit,
                                          password,
                                        );
                                        parent.emitPending(false);
                                      });
                                    },
                                  );
                                // }
                                // else if (isLedger) {
                                //   showDialog(
                                //     barrierColor: AppColors.tolopea.withOpacity(0.06),
                                //     barrierDismissible: false,
                                //     context: context,
                                //     builder: (BuildContext context1) {
                                //       return LedgerCheckScreen(
                                //           onStartSign: (p, c) async {
                                //         parent.emitPending(true);
                                //         p.emitPending(true);
                                //         await submitSwap(
                                //             state, tokensState, null,
                                //             callbackOk: () {
                                //           Navigator.pop(c);
                                //         }, callbackFail: () {
                                //           parent.emitPending(true);
                                //           p.emitPending(true);
                                //         });
                                //         parent.emitPending(false);
                                //         p.emitPending(false);
                                //       });
                                //     },
                                //   );
                                // }
                              },
                            ),
                          ),
                        ],
                      )
            )
          ],
        ),
      ); });

  submitSwap(context, ExchangeState exchangeState, ExchangeCubit exchangeCubit, String? password,
      {final Function()? callbackOk, final Function()? callbackFail}) async {
      late TxErrorModel txResponse;
      try {
          txResponse = await exchangeCubit.exchange(context, password);
      } on Exception catch (err) {
        print(err);
        throw err;
      } catch (err) {
        print(err);
        txResponse = TxErrorModel(isError: true);
        if (callbackFail != null) callbackFail();
      }

      showDialog(
        barrierColor: AppColors.tolopea.withOpacity(0.06),
        barrierDismissible: false,
        context: context,
        builder: (BuildContext dialogContext) {
          return TxStatusDialog(
            txResponse: txResponse,
            callbackOk: () {
              if (callbackOk != null) {
                callbackOk();
              }
              if (!txResponse.isError!) {
                TransactionCubit transactionCubit =
                    BlocProvider.of<TransactionCubit>(context);

                transactionCubit.setOngoingTransaction(txResponse);
              }
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation1, animation2) => HomeScreen(
                    isLoadTokens: true,
                  ),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
            },
            callbackTryAgain: () async {
              print('TryAgain');
              await submitSwap(
                context,
                exchangeState,
                exchangeCubit,
                password,
              );
            },
          );
        },
      );
  }
}
