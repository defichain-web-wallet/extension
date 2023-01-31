import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/tokens/tokens_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_bloc.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/helpers/tokens_helper.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/models/asset_pair_model.dart';
import 'package:defi_wallet/screens/home/home_screen.dart';
import 'package:defi_wallet/services/hd_wallet_service.dart';
import 'package:defi_wallet/services/transaction_service.dart';
import 'package:defi_wallet/utils/convert.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/account_drawer/account_drawer.dart';
import 'package:defi_wallet/widgets/buttons/accent_button.dart';
import 'package:defi_wallet/widgets/buttons/flat_button.dart';
import 'package:defi_wallet/widgets/buttons/new_primary_button.dart';
import 'package:defi_wallet/widgets/buttons/primary_button.dart';
import 'package:defi_wallet/widgets/buttons/restore_button.dart';
import 'package:defi_wallet/widgets/liquidity/asset_pair.dart';
import 'package:defi_wallet/widgets/liquidity/asset_pair_details.dart';
import 'package:defi_wallet/screens/liquidity/liquidity_status.dart';
import 'package:defi_wallet/widgets/loader/loader_new.dart';
import 'package:defi_wallet/widgets/dialogs/pass_confirm_dialog.dart';
import 'package:defi_wallet/widgets/password_bottom_sheet.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_constrained_box.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/ticker_text.dart';
import 'package:defi_wallet/widgets/toolbar/main_app_bar.dart';
import 'package:defi_wallet/widgets/toolbar/new_main_app_bar.dart';
import 'package:defi_wallet/widgets/dialogs/tx_status_dialog.dart';
import 'package:defichaindart/defichaindart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LiquidityConfirmation extends StatefulWidget {
  final AssetPairModel assetPair;
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
            child: _buildBody(context, transactionState),
          ),
        );
      },
    );
  }

  Widget _buildBody(context, transactionState) {
    double arrowRotateDeg = isShowDetails ? 180.0 : 0.0;
    return BlocBuilder<AccountCubit, AccountState>(builder: (context, state) {
      return BlocBuilder<TokensCubit, TokensState>(
        builder: (context, tokensState) {
          if (state.status == AccountStatusList.success &&
              tokensState.status == TokensStatusList.success) {
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
                          padding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 18),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                                      TokensHelper()
                                                          .getImageNameByTokenName(
                                                              widget.assetPair
                                                                  .tokenA),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 6,
                                                  ),
                                                  Text(
                                                    balancesHelper
                                                        .numberStyling(
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
                                                      TokensHelper()
                                                          .getImageNameByTokenName(
                                                              widget.assetPair
                                                                  .tokenB),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 6,
                                                  ),
                                                  Text(
                                                    balancesHelper
                                                        .numberStyling(
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: SvgPicture.asset(
                                              TokensHelper()
                                                  .getImageNameByTokenName(
                                                      widget.assetPair.tokenA),
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: SvgPicture.asset(
                                              TokensHelper()
                                                  .getImageNameByTokenName(
                                                      widget.assetPair.tokenB),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                        TokensHelper().getAprFormat(
                                            widget.assetPair.apr!),
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
                                style: Theme.of(context)
                                    .textTheme
                                    .headline5!
                                    .copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              RotationTransition(
                                turns: AlwaysStoppedAnimation(
                                    arrowRotateDeg / 360),
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
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline6!
                                        .copyWith(
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
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline6!
                                        .copyWith(
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
                            callback: (parent) {
                              showDialog(
                                barrierColor: Color(0x0f180245),
                                barrierDismissible: false,
                                context: context,
                                builder: (BuildContext context1) {
                                  return PassConfirmDialog(
                                      onSubmit: (password) async {
                                    parent.emitPending(true);
                                    await submitLiquidityAction(
                                      state,
                                      tokensState,
                                      transactionState,
                                      password,
                                    );
                                    parent.emitPending(false);
                                  });
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Container();
          }
        },
      );
    });
  }

  submitLiquidityAction(state, tokensState, transactionState, password) async {
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
      var txser = TransactionService();
      var txError;
      ECPair keyPair = await HDWalletService()
          .getKeypairFromStorage(password, state.activeAccount.index!);
      if (widget.removeLT != 0) {
        txError = await txser.removeLiqudity(
            keyPair: keyPair,
            account: state.activeAccount,
            token: widget.assetPair,
            amount: convertToSatoshi(widget.removeLT));
      } else {
        txError = await txser.createAndSendLiqudity(
            keyPair: keyPair,
            account: state.activeAccount,
            tokenA: widget.assetPair.tokenA!,
            tokenB: widget.assetPair.tokenB!,
            amountA: convertToSatoshi(widget.baseAmount),
            amountB: convertToSatoshi(widget.quoteAmount),
            tokens: tokensState.tokens);
      }

      showDialog(
        barrierColor: Color(0x0f180245),
        barrierDismissible: false,
        context: context,
        builder: (BuildContext dialogContext) {
          return TxStatusDialog(
            txResponse: txError,
            callbackOk: () {
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
              await submitLiquidityAction(
                state,
                tokensState,
                transactionState,
                password,
              );
            },
          );
        },
      );
    } catch (err) {
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

  String getLiquidityToken() {
    if (widget.removeLT != 0) {
      return widget.removeLT.toStringAsFixed(8);
    } else {
      return '${widget.baseAmount.toString()}-${widget.quoteAmount.toString()}';
    }
  }
}
