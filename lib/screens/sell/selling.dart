import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/fiat/fiat_cubit.dart';
import 'package:defi_wallet/bloc/tokens/tokens_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_bloc.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/helpers/balances_helper.dart';
import 'package:defi_wallet/helpers/lock_helper.dart';
import 'package:defi_wallet/models/account_model.dart';
import 'package:defi_wallet/models/fiat_model.dart';
import 'package:defi_wallet/models/focus_model.dart';
import 'package:defi_wallet/models/iban_model.dart';
import 'package:defi_wallet/models/test_pool_swap_model.dart';
import 'package:defi_wallet/models/tx_error_model.dart';
import 'package:defi_wallet/requests/dfx_requests.dart';
import 'package:defi_wallet/screens/auth_screen/lock_screen.dart';
import 'package:defi_wallet/screens/dex/widgets/amount_selector_field.dart';
import 'package:defi_wallet/screens/sell/sell_initiated.dart';
import 'package:defi_wallet/services/transaction_service.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:defi_wallet/utils/convert.dart';
import 'package:defi_wallet/widgets/buttons/restore_button.dart';
import 'package:defi_wallet/widgets/fields/iban_field.dart';
import 'package:defi_wallet/widgets/loader/loader.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_constrained_box.dart';
import 'package:defi_wallet/widgets/selectors/currency_selector.dart';
import 'package:defi_wallet/widgets/selectors/iban_selector.dart';
import 'package:defi_wallet/widgets/toolbar/main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:defi_wallet/screens/home/widgets/asset_select.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/widgets.dart';

class Selling extends StatefulWidget {
  final bool isNewIban;

  const Selling({Key? key, this.isNewIban = false}) : super(key: key);

  @override
  _SellingState createState() => _SellingState();
}

class _SellingState extends State<Selling> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController amountController =
      TextEditingController(text: '0');
  final TextEditingController _ibanController = TextEditingController();
  late FiatModel selectedFiat;
  final GlobalKey<AssetSelectState> _selectKeyTokenList =
      GlobalKey<AssetSelectState>();
  final GlobalKey<CurrencySelectorState> _selectKeyCurrency =
      GlobalKey<CurrencySelectorState>();
  final GlobalKey<IbanSelectorState> selectKeyIban =
      GlobalKey<IbanSelectorState>();
  final _formKey = GlobalKey<FormState>();

  DfxRequests dfxRequests = DfxRequests();
  BalancesHelper balancesHelper = BalancesHelper();
  LockHelper lockHelper = LockHelper();
  TestPoolSwapModel dexModel = TestPoolSwapModel();
  FocusNode focusFrom = new FocusNode();
  FocusModel focusAmountFromModel = new FocusModel();

  TransactionService transactionService = TransactionService();

  List<String> assets = [];
  String assetFrom = '';
  String sellFieldMsg = '';
  double toolbarHeight = 55;
  double toolbarHeightWithBottom = 105;
  bool isPending = false;
  int iterator = 0;

  @override
  void dispose() {
    _ibanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FiatCubit fiatCubit = BlocProvider.of<FiatCubit>(context);

    return BlocBuilder<AccountCubit, AccountState>(
        builder: (accountContext, accountState) {
      // fiatCubit.loadIbanList(accountState.accessToken!);
      fiatCubit.loadAllAssets(accountState.accessToken!);
      return BlocBuilder<FiatCubit, FiatState>(
        builder: (BuildContext context, fiatState) {
          return BlocBuilder<TokensCubit, TokensState>(
              builder: (context, tokensState) {
            return ScaffoldConstrainedBox(
              child: GestureDetector(
                child: LayoutBuilder(builder: (context, constraints) {
                  if (constraints.maxWidth < ScreenSizes.medium) {
                    return Scaffold(
                      key: _scaffoldKey,
                      appBar: MainAppBar(
                        title: 'Selling',
                        hideOverlay: () => hideOverlay(),
                      ),
                      body: _buildBody(
                          context, accountState, fiatState, tokensState),
                    );
                  } else {
                    return Container(
                      padding: const EdgeInsets.only(top: 20),
                      child: Scaffold(
                        key: _scaffoldKey,
                        body: _buildBody(
                            context, accountState, fiatState, tokensState,
                            isCustomBgColor: true),
                        appBar: MainAppBar(
                          title: 'Selling',
                          hideOverlay: () => hideOverlay(),
                          isSmall: true,
                        ),
                      ),
                    );
                  }
                }),
                onTap: () => hideOverlay(),
              ),
            );
          });
        },
      );
    });
  }

  Widget _buildBody(context, accountState, fiatState, tokensState,
      {isCustomBgColor = false}) {
    if (fiatState.status == FiatStatusList.loading) {
      return Loader();
    } else if (fiatState.status == FiatStatusList.failure) {
      Future.microtask(() => Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => LockScreen(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          )));
      return Container();
    } else {
      IbanModel? currentIban;
      if (iterator == 0) {
        selectedFiat = fiatState.fiatList![0];
        accountState.activeAccount!.balanceList!.forEach((el) {
          try {
            var assetList = fiatState.assets!
                .where((element) => element.name == el.token && !el.isHidden);
            assets.add(List.from(assetList)[0].name);
          } catch (_) {}
        });
        assetFrom = assets[0];
        getFieldMsg(accountState);
        iterator++;
      }
      List<String> stringIbans = [];
      List<IbanModel> uniqueIbans = [];

      fiatState.ibanList!.forEach((element) {
        stringIbans.add(element.iban!);
      });

      var stringUniqueIbans = Set<String>.from(stringIbans).toList();

      stringUniqueIbans.forEach((element) {
        uniqueIbans
            .add(fiatState.ibanList.firstWhere((el) => el.iban == element));
      });
      print(uniqueIbans);
      return Container(
        color: isCustomBgColor ? Theme.of(context).dialogBackgroundColor : null,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Center(
          child: StretchBox(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AmountSelectorField(
                        label: 'Your asset',
                        selectedAsset: assetFrom,
                        assets: assets,
                        selectKey: _selectKeyTokenList,
                        amountController: amountController,
                        onAnotherSelect: hideOverlay,
                        onSelect: (String asset) {
                          assetFrom = asset;
                          setState(() {
                            getFieldMsg(accountState);
                          });
                        },
                        onChanged: (value) {},
                        focusNode: focusFrom,
                        focusModel: focusAmountFromModel,
                        suffixIcon: Container(
                          padding: EdgeInsets.only(
                            top: 8,
                            bottom: 8,
                            right: 6,
                          ),
                          child: SizedBox(
                            width: 40,
                            child: TextButton(
                              child:
                                  Text('MAX', style: TextStyle(fontSize: 10)),
                              onPressed: () {
                                double maxAmount =
                                    getAvailableAmount(accountState, assetFrom);
                                amountController.text = maxAmount.toString();
                              },
                            ),
                          ),
                        ),
                        isFixedWidthAssetSelectorText: isCustomBgColor,
                      ),
                      SizedBox(height: 12),
                      Text(
                        sellFieldMsg,
                        style: Theme.of(context).textTheme.headline4!.apply(
                            color: Theme.of(context)
                                .textTheme
                                .headline4!
                                .color!
                                .withOpacity(0.5)),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 20),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                child: CurrencySelector(
                                    onAnotherSelect: hideOverlay,
                                    currencies: fiatState.fiatList,
                                    key: _selectKeyCurrency,
                                    selectedCurrency: selectedFiat,
                                    onSelect: (FiatModel selected) {
                                      setState(() {
                                        selectedFiat = selected;
                                      });
                                    }),
                              ),
                            ),
                            Expanded(
                              child: Container(),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 1,
                        child: Image(
                          image: AssetImage('assets/buying_crypto_logo.png'),
                        ),
                      ),
                      Form(
                        key: _formKey,
                        child: Container(
                            padding: EdgeInsets.only(top: 20),
                            child: widget.isNewIban ||
                                    fiatState.activeIban == null
                                ? IbanField(
                                    ibanController: _ibanController,
                                    hintText: 'DE89 37XX XXXX XXXX XXXX XX',
                                    maskFormat: 'AA## #### #### #### #### ##',
                                  )
                                : IbanSelector(
                                    key: selectKeyIban,
                                    onAnotherSelect: hideOverlay,
                                    routeWidget: Selling(
                                      isNewIban: widget.isNewIban,
                                    ),
                                    ibanList: uniqueIbans,
                                    selectedIban: fiatState.activeIban,
                                  )),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.only(right: 10),
                                  child:
                                      SvgPicture.asset('assets/info_icon.svg'),
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
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline3
                                                ?.apply()),
                                        TextSpan(
                                          text: 'KYC process here.',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline3
                                              ?.apply(
                                                  color: AppTheme.pinkColor),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                PendingButton(
                  'Sell',
                  isCheckLock: false,
                  callback: !isPending
                      ? (parent) async {
                          TransactionCubit transactionCubit =
                              BlocProvider.of<TransactionCubit>(context);
                          lockHelper.provideWithLockChecker(context, () async {
                            if (transactionCubit.state
                                is TransactionLoadingState) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Wait for the previous transaction to complete',
                                    style:
                                        Theme.of(context).textTheme.headline5,
                                  ),
                                  backgroundColor: Theme.of(context)
                                      .snackBarTheme
                                      .backgroundColor,
                                ),
                              );
                              return;
                            }
                            bool isEnough = isEnoughBalance(accountState);
                            hideOverlay();
                            if (_formKey.currentState!.validate()) {
                              if (isEnough) {
                                parent.emitPending(true);
                                setState(() {
                                  isPending = true;
                                });
                                try {
                                  String address;
                                  double amount = double.parse(amountController
                                      .text
                                      .replaceAll(',', '.'));
                                  IbanModel? list;
                                  try {
                                    list = fiatState.ibanList.firstWhere(
                                            (el) =>
                                        el.active &&
                                            el.type == "Sell" &&
                                            el.iban ==
                                                fiatState.activeIban.iban &&
                                            el.fiat.name == selectedFiat.name);
                                  } catch (_) {
                                    print(_);
                                  }
                                  print(list);
                                  String iban = widget.isNewIban
                                      ? _ibanController.text
                                      : fiatState.activeIban.iban;
                                  if (list == null || widget.isNewIban) {
                                    Map sellDetails = await dfxRequests.sell(
                                        iban,
                                        selectedFiat,
                                        accountState.accessToken);
                                    address = sellDetails["deposit"]["address"];
                                  } else {
                                    address = fiatState.ibanList
                                        .firstWhere((el) =>
                                            el.active! &&
                                            el.fiat.name == selectedFiat.name)
                                        .deposit["address"];
                                  }
                                  await _sendTransaction(
                                    context,
                                    tokensState,
                                    assetFrom,
                                    accountState.activeAccount,
                                    address,
                                    amount,
                                  );
                                  parent.emitPending(false);
                                } catch (err) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        err.toString(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline5,
                                      ),
                                      backgroundColor: Theme.of(context)
                                          .snackBarTheme
                                          .backgroundColor,
                                    ),
                                  );
                                }
                              } else {
                                if (double.parse(amountController.text
                                        .replaceAll(',', '.')) ==
                                    0) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Amount is empty',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline5,
                                      ),
                                      backgroundColor: Theme.of(context)
                                          .snackBarTheme
                                          .backgroundColor,
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Insufficient funds',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline5,
                                      ),
                                      backgroundColor: Theme.of(context)
                                          .snackBarTheme
                                          .backgroundColor,
                                    ),
                                  );
                                }
                              }
                            }
                          });
                        }
                      : null,
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  hideOverlay() {
    try {
      _selectKeyTokenList.currentState!.hideOverlay();
    } catch (_) {}
    try {
      selectKeyIban.currentState!.hideOverlay();
    } catch (_) {}
    try {
      _selectKeyCurrency.currentState!.hideOverlay();
    } catch (_) {}
  }

  getFieldMsg(accountState) {
    var availableAmount = getAvailableAmount(accountState, assetFrom);
    sellFieldMsg =
        '${balancesHelper.numberStyling(availableAmount)} $assetFrom available to sell';
  }

  double getAvailableAmount(accountState, assetFrom) {
    int fee = 3000;
    int balance = accountState.activeAccount.balanceList!
        .firstWhere((el) => el.token! == assetFrom && !el.isHidden)
        .balance!;
    balance -= fee;
    if (balance < 0) {
      balance = 0;
    }

    return convertFromSatoshi(balance);
  }

  bool isEnoughBalance(state) {
    int balance = state.activeAccount.balanceList!
        .firstWhere((el) => el.token! == assetFrom && !el.isHidden)
        .balance!;
    return convertFromSatoshi(balance) >=
            double.parse(amountController.text.replaceAll(',', '.')) &&
        double.parse(amountController.text.replaceAll(',', '.')) > 0;
  }

  _sendTransaction(context, tokensState, String token, AccountModel account,
      String address, double amount) async {
    TxErrorModel? txResponse;
    try {
      if (token == 'DFI') {
        txResponse = await transactionService.createAndSendTransaction(
            account: account,
            destinationAddress: address,
            amount: balancesHelper.toSatoshi(amount.toString()),
            tokens: tokensState.tokens);
      } else {
        txResponse = await transactionService.createAndSendToken(
            account: account,
            token: token,
            destinationAddress: address,
            amount: balancesHelper.toSatoshi(amount.toString()),
            tokens: tokensState.tokens);
      }
    } catch (err) {
      print(err);
    }
    await Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => SellInitiated(
            txResponse: txResponse,
          ),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ));
  }
}
