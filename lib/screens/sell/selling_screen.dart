import 'package:defi_wallet/bloc/refactoring/ramp/ramp_cubit.dart';
import 'package:defi_wallet/bloc/refactoring/transaction/tx_cubit.dart';
import 'package:defi_wallet/bloc/refactoring/wallet/wallet_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_bloc.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/helpers/balances_helper.dart';
import 'package:defi_wallet/helpers/lock_helper.dart';
import 'package:defi_wallet/mixins/snack_bar_mixin.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/models/fiat_model.dart';
import 'package:defi_wallet/models/iban_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_account_model.dart';
import 'package:defi_wallet/models/token/token_model.dart';
import 'package:defi_wallet/models/token_model.dart';
import 'package:defi_wallet/models/tx_error_model.dart';
import 'package:defi_wallet/models/tx_loader_model.dart';
import 'package:defi_wallet/requests/dfx_requests.dart';
import 'package:defi_wallet/screens/home/home_screen.dart';
import 'package:defi_wallet/screens/lock_screen.dart';
import 'package:defi_wallet/services/navigation/navigator_service.dart';
import 'package:defi_wallet/services/transaction_service.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/account_drawer/account_drawer.dart';
import 'package:defi_wallet/widgets/buttons/restore_button.dart';
import 'package:defi_wallet/widgets/common/page_title.dart';
import 'package:defi_wallet/widgets/fields/iban_field.dart';
import 'package:defi_wallet/widgets/loader/loader.dart';
import 'package:defi_wallet/widgets/dialogs/pass_confirm_dialog.dart';
import 'package:defi_wallet/widgets/refactoring/fields/amount_field.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/selectors/currency_selector.dart';
import 'package:defi_wallet/widgets/selectors/iban_selector.dart';
import 'package:defi_wallet/widgets/toolbar/new_main_app_bar.dart';
import 'package:defi_wallet/widgets/dialogs/tx_status_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Selling extends StatefulWidget {
  final bool isNewIban;
  final String fiatName;

  const Selling({
    Key? key,
    this.isNewIban = false,
    this.fiatName = '',
  }) : super(key: key);

  @override
  _SellingState createState() => _SellingState();
}

class _SellingState extends State<Selling> with ThemeMixin, SnackBarMixin {
  static const completeKycType = 'Completed';

  final TextEditingController amountController =
      TextEditingController(text: '0');
  final TextEditingController _ibanController = TextEditingController();
  late FiatModel selectedFiat;
  final GlobalKey<IbanSelectorState> selectKeyIban =
      GlobalKey<IbanSelectorState>();
  final _formKey = GlobalKey<FormState>();

  DfxRequests dfxRequests = DfxRequests();
  BalancesHelper balancesHelper = BalancesHelper();
  LockHelper lockHelper = LockHelper();
  TokensModel? currentAsset;

  TransactionService transactionService = TransactionService();
  static const String defaultCurrency = 'EUR';
  List<String> assets = [];
  String? balanceInUsd;
  String titleText = 'Selling';
  int iterator = 0;
  int iteratorFiat = 0;

  @override
  void dispose() {
    _ibanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldWrapper(
      builder: (
        BuildContext context,
        bool isFullScreen,
        TransactionState transactionState,
      ) {
        return BlocBuilder<WalletCubit, WalletState>(
          builder: (accountContext, walletState) {
            if (iteratorFiat == 0) {
              RampCubit rampCubit = BlocProvider.of<RampCubit>(context);
              rampCubit.loadFiatAssets();
              iteratorFiat++;
            }
            return BlocBuilder<TxCubit, TxState>(
              builder: (context, txState) {
                TxCubit txCubit = BlocProvider.of<TxCubit>(context);

                if (txState.status == TxStatusList.initial) {
                  txCubit.init(context, TxType.send);
                }

                if (txState.status == TxStatusList.success) {
                  return BlocBuilder<RampCubit, RampState>(
                    builder: (BuildContext context, rampState) {
                      if (rampState.status == RampStatusList.loading) {
                        return Loader();
                      } else if (rampState.status == RampStatusList.expired) {
                        Future.microtask(() => Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation1, animation2) =>
                                  LockScreen(),
                              transitionDuration: Duration.zero,
                              reverseTransitionDuration: Duration.zero,
                            )));
                        return Container();
                      } else {
                        if (iterator == 0) {
                          String targetFiat = widget.fiatName.isEmpty
                              ? defaultCurrency
                              : widget.fiatName;
                          selectedFiat = rampState.fiatAssets!.firstWhere(
                              (element) => element.name == targetFiat);
                          iterator++;
                        }
                        List<IbanModel> uniqueIbans = rampState.uniqueIbans(
                          selectedFiat,
                        );
                        return Scaffold(
                          drawerScrimColor: AppColors.tolopea.withOpacity(0.06),
                          endDrawer: isFullScreen ? null : AccountDrawer(
                            width: buttonSmallWidth,
                          ),
                          appBar: isFullScreen ? null : NewMainAppBar(
                            isShowLogo: false,
                            callback: hideOverlay,
                          ),
                          body: GestureDetector(
                            onTap: hideOverlay,
                            child: Container(
                              padding: EdgeInsets.only(
                                top: 22,
                                bottom: 22,
                                left: 16,
                                right: 16,
                              ),
                              width: double.infinity,
                              height: double.infinity,
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
                              child: Center(
                                child: StretchBox(
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Form(
                                          key: _formKey,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              PageTitle(
                                                title: titleText,
                                                isFullScreen: isFullScreen,
                                              ),
                                              SizedBox(
                                                height: 16,
                                              ),
                                              AmountField(
                                                type: TxType.send,
                                                balance: txState.activeBalance,
                                                available:
                                                    txState.availableBalance,
                                                onChanged: (value) {
                                                  setState(() {});
                                                },
                                                onAssetSelect: (asset) async {
                                                  txCubit.changeActiveBalance(
                                                    context,
                                                    TxType.send,
                                                    balanceModel: asset,
                                                  );
                                                },
                                                suffix: balanceInUsd ?? '0.00',
                                                controller: amountController,
                                                assets: txState.balances!,
                                              ),
                                              SizedBox(height: 16),
                                              Text(
                                                'Fiat Currency',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline5,
                                                textAlign: TextAlign.start,
                                              ),
                                              SizedBox(
                                                height: 6,
                                              ),
                                              CurrencySelector(
                                                currencies:
                                                    rampState.fiatAssets!,
                                                selectedCurrency: selectedFiat,
                                                onSelect: (selected) {
                                                  setState(() {
                                                    selectedFiat = selected;
                                                  });
                                                },
                                              ),
                                              SizedBox(height: 16),
                                              Container(
                                                child: widget.isNewIban ||
                                                        rampState.activeIban ==
                                                            null
                                                    ? IbanField(
                                                        isBorder: false,
                                                        ibanController:
                                                            _ibanController,
                                                        hintText:
                                                            'DE89 37XX XXXX XXXX XXXX XX',
                                                        maskFormat:
                                                            'AA## #### #### #### #### #### ###',
                                                      )
                                                    : IbanSelector(
                                                        isBorder: false,
                                                        fiatName:
                                                            selectedFiat.name!,
                                                        key: selectKeyIban,
                                                        onAnotherSelect:
                                                            hideOverlay,
                                                        ibanList: uniqueIbans,
                                                        selectedIban: rampState
                                                            .activeIban!,
                                                      ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 6),
                                                child: Divider(
                                                    color: AppTheme
                                                        .lightGreyColor),
                                              ),
                                              Container(
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Column(
                                                      children: [
                                                        Container(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  right: 10),
                                                          child: SvgPicture.asset(
                                                              'assets/icons/important_icon.svg'),
                                                        ),
                                                      ],
                                                    ),
                                                    Expanded(
                                                      child: RichText(
                                                        text: TextSpan(
                                                          children: [
                                                            TextSpan(
                                                                text:
                                                                    'Your account needs to get verified once your daily transaction volume exceeds 900 €. If you want to increase the daily trading limit, please complete the ',
                                                                style: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .headline6!
                                                                    .copyWith(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w600,
                                                                        color: Theme.of(context)
                                                                            .textTheme
                                                                            .headline6!
                                                                            .color!
                                                                            .withOpacity(0.6))),
                                                            TextSpan(
                                                              text:
                                                                  'KYC (Know-Your-Customer) process.',
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .headline6!
                                                                  .copyWith(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      color: AppTheme
                                                                          .pinkColor),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: buttonSmallWidth,
                                        child: PendingButton(
                                          'Sell',
                                          callback: (parent) => _sellCallback(
                                            parent,
                                            txState,
                                            walletState,
                                            rampState,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                    },
                  );
                } else {
                  return Loader();
                }
              },
            );
          },
        );
      },
    );
  }

  void _sellCallback(parent, TxState txState, walletState, rampState) {
    if (BalancesHelper().isAmountEmpty(amountController.text)) {
      showSnackBar(
        context,
        title: 'Amount is empty',
        color: AppColors.txStatusError.withOpacity(0.1),
        prefix: Icon(
          Icons.close,
          color: AppColors.txStatusError,
        ),
      );
    } else {
      parent.emitPending(true);
      lockHelper.provideWithLockChecker(context, () async {
        bool isEnough = txState.activeBalance!.balance >
            double.parse(amountController.text);
        hideOverlay();
        if (_formKey.currentState!.validate()) {
          if (isEnough) {
            showDialog(
              barrierColor: AppColors.tolopea.withOpacity(0.06),
              barrierDismissible: false,
              context: context,
              builder: (BuildContext context1) {
                return PassConfirmDialog(onCancel: () {
                  parent.emitPending(false);
                }, onSubmit: (password) async {
                  await _submitSell(
                    walletState,
                    rampState,
                    txState.currentAsset!,
                    password,
                  );
                  parent.emitPending(false);
                });
              },
            );
          } else {
            if (double.parse(amountController.text.replaceAll(',', '.')) == 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Amount is empty',
                    style: Theme.of(context).textTheme.headline5,
                  ),
                  backgroundColor:
                      Theme.of(context).snackBarTheme.backgroundColor,
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Insufficient funds',
                    style: Theme.of(context).textTheme.headline5,
                  ),
                  backgroundColor:
                      Theme.of(context).snackBarTheme.backgroundColor,
                ),
              );
            }
          }
        }
      });
    }
  }

  _submitSell(
    WalletState walletState,
    RampState rampState,
    TokenModel token,
    String password,
  ) async {
    try {
      String address;
      double amount = double.parse(amountController.text.replaceAll(',', '.'));
      IbanModel? foundedIban;
      try {
        foundedIban = rampState.ibans!.firstWhere((el) =>
            el.isSellable! &&
            el.active! &&
            el.iban == rampState.activeIban!.iban &&
            el.fiat!.name == selectedFiat.name);
      } catch (_) {
        print(_);
      }
      String iban = _ibanController.text.isNotEmpty
          ? _ibanController.text
          : rampState.activeIban!.iban!;
      if (foundedIban == null || widget.isNewIban) {
        Map sellDetails = await dfxRequests.sell(
          iban,
          selectedFiat,
          rampState.dfxRampModel!.accessTokensMap[0]!.accessToken,
        );
        address = sellDetails["deposit"]["address"];
      } else {
        address = foundedIban.deposit["address"];
      }
      await _sendTransaction(
        context,
        walletState,
        token,
        walletState.activeAccount,
        address,
        amount,
        password,
      );
    } catch (err) {
      showSnackBar(
        context,
        title: err.toString().replaceAll('"', ''),
        color: AppColors.txStatusError.withOpacity(0.1),
        prefix: Icon(
          Icons.close,
          color: AppColors.txStatusError,
        ),
      );
    }
  }

  hideOverlay() {
    try {
      selectKeyIban.currentState!.hideOverlay();
    } catch (_) {}
  }

  _sendTransaction(
    context,
    WalletState walletState,
    TokenModel token,
    AbstractAccountModel account,
    String address,
    double amount,
    String password,
  ) async {
    TxErrorModel? txResponse;
    try {
      final network = walletState.applicationModel!.activeNetwork!;

      txResponse = await network.send(
        account: walletState.activeAccount,
        address: address,
        password: password,
        token: token,
        amount: double.parse(amountController.text),
        applicationModel: walletState.applicationModel!,
      );
    } catch (err) {
      print(err);
    }
    if (!txResponse!.isError!) {
      TransactionCubit transactionCubit =
          BlocProvider.of<TransactionCubit>(context);

      await transactionCubit.setOngoingTransaction(txResponse);
    }
    showDialog(
      barrierColor: AppColors.tolopea.withOpacity(0.06),
      barrierDismissible: false,
      context: context,
      builder: (BuildContext dialogContext) {
        return TxStatusDialog(
          title: 'Transaction initiated',
          subtitle:
              'Your transaction is now processed in the background. It will take up to 48h until the money arrives in your bank account. Thanks for choosing DFX.',
          buttonLabel: 'Done',
          txResponse: txResponse,
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
            NavigatorService.pushReplacement(context, null);
          },
          callbackTryAgain: () async {
            await _sendTransaction(
              context,
              walletState,
              token,
              walletState.activeAccount,
              address,
              amount,
              password,
            );
          },
        );
      },
    );
  }
}
