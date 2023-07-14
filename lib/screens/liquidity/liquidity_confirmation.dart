import 'package:defi_wallet/bloc/refactoring/lm/lm_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_bloc.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/helpers/tokens_helper.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/models/token/lp_pool_model.dart';
import 'package:defi_wallet/screens/home/home_screen.dart';
import 'package:defi_wallet/services/navigation/navigator_service.dart';
import 'package:defi_wallet/utils/convert.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/account_drawer/account_drawer.dart';
import 'package:defi_wallet/widgets/buttons/flat_button.dart';
import 'package:defi_wallet/widgets/buttons/restore_button.dart';
import 'package:defi_wallet/widgets/liquidity/asset_pair_details.dart';
import 'package:defi_wallet/widgets/dialogs/pass_confirm_dialog.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/toolbar/new_main_app_bar.dart';
import 'package:defi_wallet/widgets/dialogs/tx_status_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';

class LiquidityConfirmation extends StatefulWidget {
  final LmPoolModel assetPair;
  final double baseAmount;
  final double quoteAmount;
  final double amountUSD;
  final double balanceUSD;
  final double shareOfPool;
  final double removeLT;
  final double balanceA;
  final double balanceB;
  final double amount;

  const LiquidityConfirmation(
      {Key? key,
      required this.assetPair,
      required this.baseAmount,
      required this.quoteAmount,
      required this.amountUSD,
      required this.balanceUSD,
      required this.shareOfPool,
      required this.balanceA,
      required this.balanceB,
      required this.amount,
      this.removeLT = 0})
      : super(key: key);

  @override
  State<LiquidityConfirmation> createState() => _LiquidityConfirmationState();
}

class _LiquidityConfirmationState extends State<LiquidityConfirmation>
    with ThemeMixin {
  String appBarTitle = 'Confirmation';
  String submitLabel = '';
  String secondStepLoaderTextAdd =
      'Did you know that DeFiChain is working without smart contracts? It\'s all based on so called custom-transactions. Makes things more secure!';
  String secondStepLoaderTextRemove =
      'Do you like Jellywallet? Leave us a review on the Google Store to support us!';
  TokensHelper tokenHelper = TokensHelper();
  double toolbarHeight = 55;
  double toolbarHeightWithBottom = 105;
  bool isShowDetails = true;

  @override
  Widget build(BuildContext context) {
    return ScaffoldWrapper(
      builder: (
        BuildContext context,
        bool isFullScreen,
        TransactionState transactionState,
      ) {
        return Scaffold(
          drawerScrimColor: AppColors.tolopea.withOpacity(0.06),
          endDrawer: isFullScreen ? null : AccountDrawer(
            width: buttonSmallWidth,
          ),
          appBar: isFullScreen ? null : NewMainAppBar(
            isShowLogo: false,
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
                  ? DarkColors.drawerBgColor
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
                bottomLeft: Radius.circular(isFullScreen ? 20 : 0),
                bottomRight: Radius.circular(isFullScreen ? 20 : 0),
              ),
            ),
            child: _buildBody(context, transactionState, isFullScreen),
          ),
        );
      },
    );
  }

  Widget _buildBody(context, transactionState, isFullScreen) {
    double arrowRotateDeg = isShowDetails ? 180.0 : 0.0;
    submitLabel = widget.removeLT == 0 ? 'Add' : 'Remove';
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
                  height: widget.removeLT == 0 ? 148 : 88,
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
                  child: Row(
                    children: [
                      if (widget.removeLT != 0) ...[
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'You will receive',
                                style: Theme.of(context)
                                    .textTheme
                                    .headline6!
                                    .copyWith(
                                      fontWeight: FontWeight.w400,
                                      color: Theme.of(context)
                                          .textTheme
                                          .headline6!
                                          .color!
                                          .withOpacity(0.5),
                                    ),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Row(
                                children: [
                                  Flexible(
                                    child: Container(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: SvgPicture.asset(
                                              widget.assetPair.tokens[0]
                                                  .imagePath,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 6,
                                          ),
                                          Text(
                                            balancesHelper.numberStyling(
                                                widget.baseAmount,
                                                fixed: true),
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline3!
                                                .copyWith(
                                                  fontSize: 20,
                                                ),
                                          ),
                                          SizedBox(
                                            width: 6,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 16,
                                  ),
                                  Flexible(
                                    child: Container(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: SvgPicture.asset(
                                              widget.assetPair.tokens[1]
                                                  .imagePath,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 6,
                                          ),
                                          Text(
                                            balancesHelper.numberStyling(
                                                widget.quoteAmount,
                                                fixed: true),
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline3!
                                                .copyWith(
                                                  fontSize: 20,
                                                ),
                                          ),
                                          SizedBox(
                                            width: 6,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (widget.removeLT == 0) ...[
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'You will receive',
                                style: Theme.of(context)
                                    .textTheme
                                    .headline6!
                                    .copyWith(
                                      fontWeight: FontWeight.w400,
                                      color: Theme.of(context)
                                          .textTheme
                                          .headline6!
                                          .color!
                                          .withOpacity(0.5),
                                    ),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: SvgPicture.asset(
                                      widget.assetPair.tokens[0].imagePath,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 6,
                                  ),
                                  Text(
                                    balancesHelper.numberStyling(
                                        widget.baseAmount,
                                        fixed: true),
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline3!
                                        .copyWith(
                                          fontSize: 20,
                                        ),
                                  )
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: SvgPicture.asset(
                                      widget.assetPair.tokens[1].imagePath,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 6,
                                  ),
                                  Text(
                                    balancesHelper.numberStyling(
                                        widget.quoteAmount,
                                        fixed: true),
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
                        SizedBox(
                          width: 16,
                        ),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Yield',
                                style: Theme.of(context)
                                    .textTheme
                                    .headline6!
                                    .copyWith(
                                      fontWeight: FontWeight.w400,
                                      color: Theme.of(context)
                                          .textTheme
                                          .headline6!
                                          .color!
                                          .withOpacity(0.5),
                                    ),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Text(
                                TokensHelper()
                                    .getAprFormat(widget.assetPair.apr!, true),
                                style: Theme.of(context)
                                    .textTheme
                                    .headline3!
                                    .copyWith(
                                      fontSize: 20,
                                    ),
                              )
                            ],
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
                SizedBox(
                  height: 26,
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isShowDetails = !isShowDetails;
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Show less',
                        style: Theme.of(context).textTheme.headline5!.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      RotationTransition(
                        turns: AlwaysStoppedAnimation(arrowRotateDeg / 360),
                        child: SizedBox(
                          width: 8,
                          height: 8,
                          child: SvgPicture.asset(
                            'assets/icons/arrow_down.svg',
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                if (isShowDetails) ...[
                  AssetPairDetails(
                    assetPair: widget.assetPair,
                    isRemove: widget.removeLT != 0,
                    amountA: widget.baseAmount,
                    amountB: widget.quoteAmount,
                    balanceA: widget.balanceA,
                    balanceB: widget.balanceB,
                    totalBalanceInUsd: widget.balanceUSD,
                    totalAmountInUsd: widget.amountUSD,
                  ),
                ],
                Container(
                    padding: const EdgeInsets.only(top: 24),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Note: ',
                            style:
                                Theme.of(context).textTheme.headline6!.copyWith(
                                      fontWeight: FontWeight.w400,
                                      color: Theme.of(context)
                                          .textTheme
                                          .headline6!
                                          .color!
                                          .withOpacity(0.3),
                                    ),
                          ),
                          TextSpan(
                            text:
                                'Liquidity tokens represent a share of the liquidity pool',
                            style:
                                Theme.of(context).textTheme.headline6!.copyWith(
                                      fontWeight: FontWeight.w400,
                                      color: Theme.of(context)
                                          .textTheme
                                          .headline6!
                                          .color!
                                          .withOpacity(0.3),
                                    ),
                          ),
                        ],
                      ),
                    ))
              ],
            ),
          ),
          Container(
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
                    widget.removeLT == 0 ? 'Add' : 'Remove',
                    pendingText: 'Pending',
                    callback: (parent) async {
                      final isLedger = await SettingsHelper.isLedger();

                      if (!isLedger) {
                        showDialog(
                          barrierColor: AppColors.tolopea.withOpacity(0.06),
                          barrierDismissible: false,
                          context: context,
                          builder: (BuildContext context1) {
                            return PassConfirmDialog(
                                onSubmit: (password) async {
                              parent.emitPending(true);
                              await submitLiquidityAction(
                                context,
                                transactionState,
                                password,
                              );
                              parent.emitPending(false);
                            });
                          },
                        );
                      }
                      //TODO: ledger
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
                      //         await submitLiquidityAction(
                      //             state,
                      //             tokensState,
                      //             transactionState,
                      //             null, callbackOk: () {
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
            ),
          ),
        ],
      ),
    );
  }

  submitLiquidityAction(context, transactionState, password,
      {final Function()? callbackOk, final Function()? callbackFail}) async {
    if (transactionState is TransactionLoadingState) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Wait for the previous transaction to complete',
            style: Theme.of(context).textTheme.headline5,
          ),
          backgroundColor: Theme.of(context).snackBarTheme.backgroundColor,
        ),
      );
      return;
    }
    try {
      var txError;
      final lmCubit = BlocProvider.of<LmCubit>(context);
      if (widget.removeLT != 0) {
        txError = await lmCubit.removeLiqudity(
          password,
          widget.assetPair,
          widget.removeLT,
          context,
        );
      } else {
        txError = await lmCubit.addLiqudity(
          password,
          widget.assetPair,
          [widget.baseAmount, widget.quoteAmount],
          context,
        );
      }

      if (!txError.isError) {
        TransactionCubit transactionCubit =
            BlocProvider.of<TransactionCubit>(context);

        await transactionCubit.setOngoingTransaction(txError);
      }

      showDialog(
        barrierColor: AppColors.tolopea.withOpacity(0.06),
        barrierDismissible: false,
        context: context,
        builder: (BuildContext dialogContext) {
          return TxStatusDialog(
            txResponse: txError,
            callbackOk: () {
              if (callbackOk != null) {
                callbackOk();
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
              NavigatorService.pushReplacement(context, null);
            },
            callbackTryAgain: () async {
              await submitLiquidityAction(context, transactionState, password,
                  callbackFail: callbackFail, callbackOk: callbackOk);
            },
          );
        },
      );
    } catch (err) {
      if (callbackFail != null) {
        callbackFail();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Something went wrong. Please, try later',
              style: Theme.of(context).textTheme.headline5,
            ),
            backgroundColor: Theme.of(context).snackBarTheme.backgroundColor,
          ),
        );
      }
    }
  }
}
