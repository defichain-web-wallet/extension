import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/fiat/fiat_cubit.dart';
import 'package:defi_wallet/bloc/tokens/tokens_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_bloc.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/helpers/balances_helper.dart';
import 'package:defi_wallet/helpers/lock_helper.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/mixins/snack_bar_mixin.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/models/account_model.dart';
import 'package:defi_wallet/models/fiat_model.dart';
import 'package:defi_wallet/models/iban_model.dart';
import 'package:defi_wallet/models/token_model.dart';
import 'package:defi_wallet/models/tx_error_model.dart';
import 'package:defi_wallet/requests/dfx_requests.dart';
import 'package:defi_wallet/screens/home/home_screen.dart';
import 'package:defi_wallet/screens/lock_screen.dart';
import 'package:defi_wallet/services/hd_wallet_service.dart';
import 'package:defi_wallet/services/transaction_service.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:defi_wallet/utils/convert.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/account_drawer/account_drawer.dart';
import 'package:defi_wallet/widgets/buttons/new_primary_button.dart';
import 'package:defi_wallet/widgets/buttons/restore_button.dart';
import 'package:defi_wallet/widgets/fields/amount_field.dart';
import 'package:defi_wallet/widgets/fields/iban_field.dart';
import 'package:defi_wallet/widgets/loader/loader.dart';
import 'package:defi_wallet/widgets/dialogs/pass_confirm_dialog.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/selectors/currency_selector.dart';
import 'package:defi_wallet/widgets/selectors/iban_selector.dart';
import 'package:defi_wallet/widgets/toolbar/new_main_app_bar.dart';
import 'package:defi_wallet/widgets/dialogs/tx_status_dialog.dart';
import 'package:defichaindart/defichaindart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Selling extends StatefulWidget {
  final bool isNewIban;

  const Selling({Key? key, this.isNewIban = false}) : super(key: key);

  @override
  _SellingState createState() => _SellingState();
}

class _SellingState extends State<Selling> with ThemeMixin, SnackBarMixin {
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
          TransactionState txState,
          ) {
        return BlocBuilder<AccountCubit, AccountState>(
          builder: (accountContext, accountState) {
            if (iteratorFiat == 0) {
              FiatCubit fiatCubit = BlocProvider.of<FiatCubit>(context);
              fiatCubit.loadAllAssets(isSell: true);
              iteratorFiat++;
            }
            return BlocBuilder<TokensCubit, TokensState>(
              builder: (context, tokensState) {
                return BlocBuilder<FiatCubit, FiatState>(
                  builder: (BuildContext context, fiatState) {
                    if (fiatState.status == FiatStatusList.loading) {
                      return Loader();
                    } else if (fiatState.status == FiatStatusList.expired) {
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
                      IbanModel? currentIban;
                      if (iterator == 0) {
                        selectedFiat = fiatState.sellableFiatList![0];
                        accountState.activeAccount!.balanceList!.forEach((el) {
                          try {
                            var assetList = fiatState.assets!.where((element) =>
                            element.dexName == el.token && !el.isHidden!);
                            assets.add(List.from(assetList)[0].dexName);
                          } catch (_) {
                            print(_);
                          }
                        });
                        currentAsset = currentAsset ??
                            getTokensList(accountState, tokensState, assets)
                                .first;
                        iterator++;
                      }
                      List<String> stringIbans = [];
                      List<IbanModel> uniqueIbans = [];

                      fiatState.ibanList!.forEach((element) {
                        stringIbans.add(element.iban!);
                      });

                      var stringUniqueIbans =
                      Set<String>.from(stringIbans).toList();

                      stringUniqueIbans.forEach((element) {
                        uniqueIbans.add(fiatState.ibanList!
                            .firstWhere((el) => el.iban == element));
                      });
                      return Scaffold(
                        drawerScrimColor: Color(0x0f180245),
                        endDrawer: AccountDrawer(
                          width: buttonSmallWidth,
                        ),
                        appBar: NewMainAppBar(
                          isShowLogo: false,
                        ),
                        body: Container(
                          padding: EdgeInsets.only(
                            top: 22,
                            bottom: 24,
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
                            ),
                          ),
                          child: Center(
                            child: StretchBox(
                              child: Column(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Form(
                                      key: _formKey,
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                titleText,
                                                style: headline2.copyWith(
                                                    fontWeight:
                                                    FontWeight.w700),
                                                textAlign: TextAlign.start,
                                                softWrap: true,
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 16,
                                          ),
                                          AmountField(
                                            onChanged: (value) {
                                              setState(() {
                                                balanceInUsd =
                                                    getUsdBalance(context);
                                              });
                                            },
                                            suffix: balanceInUsd ??
                                                getUsdBalance(context),
                                            available: getAvailableBalance(
                                                accountState),
                                            onAssetSelect: (t) {
                                              setState(() {
                                                currentAsset = t;
                                              });
                                            },
                                            controller: amountController,
                                            selectedAsset: currentAsset!,
                                            assets: getTokensList(
                                              accountState,
                                              tokensState,
                                              assets,
                                            ),
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
                                            currencies: fiatState.sellableFiatList!,
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
                                                      fiatState.activeIban ==
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
                                                      key: selectKeyIban,
                                                      onAnotherSelect:
                                                          hideOverlay,
                                                      ibanList: uniqueIbans,
                                                      selectedIban:
                                                          fiatState.activeIban!,
                                                    )),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 6),
                                            child: Divider(
                                                color: AppTheme.lightGreyColor),
                                          ),
                                          Container(
                                            child: Row(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: [
                                                Column(
                                                  children: [
                                                    Container(
                                                      padding: EdgeInsets.only(
                                                          right: 10),
                                                      child: SvgPicture.asset(
                                                          'assets/icons/important_icon.svg'),
                                                    ),
                                                  ],
                                                ),
                                                Expanded(
                                                  child: Column(
                                                    children: [
                                                      RichText(
                                                        text: TextSpan(
                                                          children: [
                                                            TextSpan(
                                                                text:
                                                                'Over 900 € transfer volume per day KYC (Know Your Customer) process is necessary. If you would like to remove this limit, please complete the ',
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
                                                              'KYC process here.',
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
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: buttonSmallWidth,
                                        child: PendingButton(
                                          'Sell',
                                          callback: (parent) async {
                                            parent.emitPending(true);
                                            lockHelper.provideWithLockChecker(
                                                context, () async {
                                              if (txState
                                              is TransactionLoadingState) {
                                                parent.emitPending(false);
                                                showSnackBar(
                                                  context,
                                                  title:
                                                  'Please wait for the previous '
                                                      'transaction',
                                                  color: AppColors.txStatusError
                                                      .withOpacity(0.1),
                                                  prefix: Icon(
                                                    Icons.close,
                                                    color: AppColors.txStatusError,
                                                  ),
                                                );
                                                return;
                                              }
                                              bool isEnough =
                                              isEnoughBalance(accountState);
                                              hideOverlay();
                                              if (_formKey.currentState!
                                                  .validate()) {
                                                if (isEnough) {
                                                  showDialog(
                                                    barrierColor:
                                                    Color(0x0f180245),
                                                    barrierDismissible: false,
                                                    context: context,
                                                    builder:
                                                        (BuildContext context1) {
                                                      return PassConfirmDialog(
                                                          onCancel: () {
                                                            parent.emitPending(false);
                                                          },
                                                          onSubmit:
                                                              (password) async {

                                                            await _submitSell(
                                                              accountState,
                                                              tokensState,
                                                              fiatState,
                                                              password,
                                                            );
                                                            parent.emitPending(false);
                                                          });
                                                    },
                                                  );
                                                } else {
                                                  if (double.parse(
                                                      amountController.text
                                                          .replaceAll(
                                                          ',', '.')) ==
                                                      0) {
                                                    ScaffoldMessenger.of(context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          'Amount is empty',
                                                          style: Theme.of(context)
                                                              .textTheme
                                                              .headline5,
                                                        ),
                                                        backgroundColor:
                                                        Theme.of(context)
                                                            .snackBarTheme
                                                            .backgroundColor,
                                                      ),
                                                    );
                                                  } else {
                                                    ScaffoldMessenger.of(context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          'Insufficient funds',
                                                          style: Theme.of(context)
                                                              .textTheme
                                                              .headline5,
                                                        ),
                                                        backgroundColor:
                                                        Theme.of(context)
                                                            .snackBarTheme
                                                            .backgroundColor,
                                                      ),
                                                    );
                                                  }
                                                }
                                              }
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  getTokensList(accountState, tokensState, targetAssets) {
    List<TokensModel> tempList = [];
    List<TokensModel> resList = [];
    accountState.balances!.forEach((element) {
      tokensState.tokens!.forEach((el) {
        if (element.token == el.symbol) {
          tempList.add(el);
        }
      });
    });
    targetAssets.forEach((element) {
      tempList.forEach((el) {
        if (element == el.symbol) {
          resList.add(el);
        }
      });
    });

    return resList;
  }

  String getUsdBalance(context) {
    TokensCubit tokensCubit = BlocProvider.of<TokensCubit>(context);
    try {
      var amount = tokenHelper.getAmountByUsd(
        tokensCubit.state.tokensPairs!,
        double.parse(amountController.text.replaceAll(',', '.')),
        currentAsset!.symbol!,
      );
      return balancesHelper.numberStyling(amount, fixedCount: 2, fixed: true);
    } catch (err) {
      return '0.00';
    }
  }

  _submitSell(
      AccountState accountState,
      TokensState tokensState,
      FiatState fiatState,
      String password,
      ) async {
    try {
      String address;
      double amount = double.parse(amountController.text.replaceAll(',', '.'));
      IbanModel? foundedIban;
      try {
        foundedIban = fiatState.ibanList!.firstWhere((el) =>
        el.active! &&
            el.type == "Sell" &&
            el.iban == fiatState.activeIban!.iban &&
            el.fiat!.name == selectedFiat.name);
      } catch (_) {
        print(_);
      }
      String iban = _ibanController.text.isNotEmpty
          ? _ibanController.text
          : fiatState.activeIban!.iban!;
      if (foundedIban == null || widget.isNewIban) {
        Map sellDetails =
        await dfxRequests.sell(iban, selectedFiat, fiatState.accessToken!);
        address = sellDetails["deposit"]["address"];
      } else {
        address = foundedIban.deposit["address"];
      }
      await _sendTransaction(context, tokensState, currentAsset!.symbol!,
          accountState.activeAccount!, address, amount, password);
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

  double getAvailableBalance(accountState) {
    int balance = accountState.activeAccount!.balanceList!
        .firstWhere((el) => el.token! == currentAsset!.symbol! && !el.isHidden!)
        .balance!;
    final int fee = 3000;
    return convertFromSatoshi(balance - fee);
  }

  bool isEnoughBalance(state) {
    int balance = state.activeAccount.balanceList!
        .firstWhere((el) => el.token! == currentAsset!.symbol! && !el.isHidden)
        .balance!;
    return convertFromSatoshi(balance) >=
        double.parse(amountController.text.replaceAll(',', '.')) &&
        double.parse(amountController.text.replaceAll(',', '.')) > 0;
  }

  _sendTransaction(context, tokensState, String token, AccountModel account,
      String address, double amount, String password) async {
    TxErrorModel? txResponse;
    try {
      ECPair keyPair = await HDWalletService()
          .getKeypairFromStorage(password, account.index!);
      if (token == 'DFI') {
        txResponse = await transactionService.createAndSendTransaction(
            keyPair: keyPair,
            account: account,
            destinationAddress: address,
            amount: balancesHelper.toSatoshi(amount.toString()),
            tokens: tokensState.tokens);
      } else {
        txResponse = await transactionService.createAndSendToken(
            keyPair: keyPair,
            account: account,
            token: token,
            destinationAddress: address,
            amount: balancesHelper.toSatoshi(amount.toString()),
            tokens: tokensState.tokens);
      }
    } catch (err) {
      print(err);
    }
    if (!txResponse!.isError!) {
      TransactionCubit transactionCubit =
      BlocProvider.of<TransactionCubit>(context);

      transactionCubit.setOngoingTransaction(txResponse);
    }
    showDialog(
      barrierColor: Color(0x0f180245),
      barrierDismissible: false,
      context: context,
      builder: (BuildContext dialogContext) {
        return TxStatusDialog(
          title: 'Transaction initiated',
          subtitle: 'Your transaction is now processed in the background. It will take up to 48h until the money arrives in your bank account. Thanks for choosing DFX.',
          buttonLabel: 'Done',
          txResponse: txResponse,
          callbackOk: () {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder:
                    (context, animation1, animation2) =>
                    HomeScreen(isLoadTokens: true,),
                transitionDuration: Duration.zero,
                reverseTransitionDuration:
                Duration.zero,
              ),
            );
          },
          callbackTryAgain: () async {
            print('TryAgain');
            await _sendTransaction(
              context,
              tokensState,
              currentAsset!.symbol!,
              account,
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
