import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/bitcoin/bitcoin_cubit.dart';
import 'package:defi_wallet/bloc/tokens/tokens_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_bloc.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/helpers/addresses_helper.dart';
import 'package:defi_wallet/helpers/balances_helper.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/helpers/tokens_helper.dart';
import 'package:defi_wallet/models/focus_model.dart';
import 'package:defi_wallet/requests/btc_requests.dart';
import 'package:defi_wallet/screens/home/widgets/asset_select.dart';
import 'package:defi_wallet/screens/home/widgets/asset_select_field.dart';
import 'package:defi_wallet/screens/send/send_confirm_screen.dart';
import 'package:defi_wallet/screens/send/widgets/address_field.dart';
import 'package:defi_wallet/screens/send/widgets/asset_dropdown.dart';
import 'package:defi_wallet/screens/send/widgets/fee_card.dart';
import 'package:defi_wallet/services/transaction_service.dart';
import 'package:defi_wallet/utils/convert.dart';
import 'package:defi_wallet/widgets/buttons/primary_button.dart';
import 'package:defi_wallet/widgets/error_placeholder.dart';
import 'package:defi_wallet/widgets/loader/loader.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SendForm extends StatefulWidget {
  final GlobalKey<AssetSelectState> selectKeyFrom;
  final GlobalKey<AssetSelectFieldState> selectKeyFieldFrom;
  final Function() hideOverlay;
  final bool isFullScreen;
  final String selectedAddress;

  SendForm({
    Key? key,
    required this.selectKeyFrom,
    required this.selectKeyFieldFrom,
    required this.hideOverlay,
    required this.isFullScreen,
    this.selectedAddress = '',
  }) : super(key: key);

  @override
  _SendFormState createState() => _SendFormState();
}

class _SendFormState extends State<SendForm> {
  TokensHelper tokenHelper = TokensHelper();
  BalancesHelper balancesHelper = BalancesHelper();
  TransactionService transactionService = TransactionService();

  TextEditingController _amountController = TextEditingController(text: '0');
  FocusNode _amountFocusNode = new FocusNode();
  FocusModel _amountFocusModel = new FocusModel();
  AddressesHelper addressHelper = AddressesHelper();
  TextEditingController addressController = TextEditingController();
  var btcRequests = BtcRequests();
  bool isFailed = false;
  bool isFailedAddress = false;
  bool _isBalanceError = false;
  double toolbarHeight = 55;
  double toolbarHeightWithBottom = 105;
  String assetFrom = '';
  String assetTo = '';
  int selectedFee = 0;
  double btcAvailableBalance = 0;
  String amountInUsd = '0.0';
  int iterator = 0;

  @override
  void initState() {
    super.initState();
    addressController.text = widget.selectedAddress;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.hideOverlay,
      child: Container(
        child: BlocBuilder<BitcoinCubit, BitcoinState>(
          builder: (context, bitcoinState) {
            return BlocBuilder<AccountCubit, AccountState>(
              builder: (context, state) {
                BitcoinCubit bitcoinCubit =
                    BlocProvider.of<BitcoinCubit>(context);
                TokensCubit tokensCubit = BlocProvider.of<TokensCubit>(context);
                if (iterator == 0 && SettingsHelper.isBitcoin()) {
                  bitcoinCubit.loadAvailableBalance(
                      state.activeAccount!.bitcoinAddress!);
                  iterator++;
                }
                String theme =
                    SettingsHelper.settings.theme == 'Light' ? 'dark' : 'light';

                if (state.status == AccountStatusList.success &&
                    (bitcoinState.status == BitcoinStatusList.success ||
                        !SettingsHelper.isBitcoin())) {
                  List<String> assets = [];
                  if (SettingsHelper.isBitcoin()) {
                    assetFrom = 'BTC';
                    assets = [];
                  } else {
                    assetFrom =
                        (assetFrom.isEmpty) ? state.activeToken! : assetFrom;
                    state.activeAccount!.balanceList!.forEach((el) {
                      if (!el.isHidden!) {
                        assets.add(el.token!);
                      }
                    });
                  }

                  return Container(
                    color: Theme.of(context).dialogBackgroundColor,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 24),
                    child: Center(
                      child: StretchBox(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Recipient Address',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline6),
                                  SizedBox(height: 12),
                                  AddressField(
                                    addressController: addressController,
                                    hideOverlay: widget.hideOverlay,
                                  ),
                                  SizedBox(height: 8),
                                  Divider(),
                                  SizedBox(height: 12),
                                  Text(
                                    'Asset',
                                    style:
                                        Theme.of(context).textTheme.headline6,
                                  ),
                                  SizedBox(height: 12),
                                  AssetDropdown(
                                    accountState: state,
                                    selectKeyFrom: widget.selectKeyFrom,
                                    selectKeyFieldFrom:
                                        widget.selectKeyFieldFrom,
                                    amountController: _amountController,
                                    focusNode: _amountFocusNode,
                                    focusModel: _amountFocusModel,
                                    assets: assets,
                                    assetFrom: assetFrom,
                                    amountInUsd: amountInUsd,
                                    onChanged: (String value) {
                                      try {
                                        var amount = tokenHelper.getAmountByUsd(
                                          tokensCubit.state.tokensPairs!,
                                          double.parse(
                                              value.replaceAll(',', '.')),
                                          assetFrom,
                                        );
                                        setState(() {
                                          amountInUsd = balancesHelper
                                              .numberStyling(amount,
                                                  fixedCount: 2, fixed: true);
                                        });
                                      } catch (err) {
                                        print(err);
                                      }
                                    },
                                    onSelect: (String asset) {
                                      setState(() => {assetFrom = asset});
                                    },
                                    onPressedMax: () {
                                      setState(() {
                                        int balance = state
                                            .activeAccount!.balanceList!
                                            .firstWhere((el) =>
                                                el.token! == assetFrom &&
                                                !el.isHidden!)
                                            .balance!;
                                        final int fee = 3000;
                                        double amount =
                                            convertFromSatoshi(balance - fee);
                                        _amountController.text =
                                            amount.toString();
                                      });
                                    },
                                    isFixedWidthAssetSelectorText:
                                        widget.isFullScreen,
                                  ),
                                  SizedBox(height: 12),
                                  if (SettingsHelper.isBitcoin())
                                    Text(
                                      "Available balance: ${_getAvailableBalance(bitcoinState)} BTC",
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline4!
                                          .apply(
                                            color: Colors.grey,
                                          ),
                                    ),
                                  SizedBox(height: 22),
                                  if (SettingsHelper.isBitcoin()) Text("Fees"),
                                  SizedBox(height: 12),
                                  if (bitcoinState.networkFee != null &&
                                      SettingsHelper.isBitcoin())
                                    Column(
                                      children: [
                                        FeeCard(
                                          fee: bitcoinState.networkFee!.low!,
                                          iconUrl: 'assets/slow_$theme.svg',
                                          label: 'Slow',
                                          callback: () async {
                                            bitcoinCubit.changeActiveFee(
                                                state.activeAccount!
                                                    .bitcoinAddress!,
                                                bitcoinState.networkFee!.low!);
                                          },
                                          isActive: bitcoinState.activeFee ==
                                              bitcoinState.networkFee!.low,
                                        ),
                                        SizedBox(height: 8),
                                        FeeCard(
                                          fee: bitcoinState.networkFee!.medium!,
                                          iconUrl: 'assets/medium_$theme.svg',
                                          label: 'Medium',
                                          callback: () async {
                                            bitcoinCubit.changeActiveFee(
                                                state.activeAccount!
                                                    .bitcoinAddress!,
                                                bitcoinState
                                                    .networkFee!.medium!);
                                          },
                                          isActive: bitcoinState.activeFee ==
                                              bitcoinState.networkFee!.medium,
                                        ),
                                        SizedBox(height: 8),
                                        FeeCard(
                                          fee: bitcoinState.networkFee!.high!,
                                          iconUrl: 'assets/fast_$theme.svg',
                                          label: 'Fast',
                                          callback: () async {
                                            bitcoinCubit.changeActiveFee(
                                                state.activeAccount!
                                                    .bitcoinAddress!,
                                                bitcoinState.networkFee!.high!);
                                          },
                                          isActive: bitcoinState.activeFee ==
                                              bitcoinState.networkFee!.high,
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                            PrimaryButton(
                              label: 'Continue',
                              callback: () =>
                                  submitToConfirm(state, bitcoinState),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                } else if (bitcoinState.status == BitcoinStatusList.failure &&
                    SettingsHelper.isBitcoin()) {
                  return Center(
                    child: ErrorPlaceholder(
                      message: 'Something went wrong',
                      description: 'Please try later',
                    ),
                  );
                } else {
                  return Loader();
                }
              },
            );
          },
        ),
      ),
    );
  }

  submitToConfirm(state, bitcoinState) async {
    widget.hideOverlay();
    TransactionState transactionState =
        BlocProvider.of<TransactionCubit>(context).state;

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
    bool valid = false;
    int balance = 0;
    final int fee = 3000;
    double amount = 0;
    if (SettingsHelper.isBitcoin()) {
      valid = await addressHelper.validateBtcAddress(addressController.text);
      amount = convertFromSatoshi(bitcoinState.availableBalance);
    } else {
      valid = await addressHelper.validateAddress(addressController.text);
      balance = state.activeAccount.balanceList!
          .firstWhere((el) => el.token! == assetFrom && !el.isHidden)
          .balance!;
      amount = convertFromSatoshi(balance - fee);
    }
    if (valid) {
      if (double.parse(_amountController.text.replaceAll(',', '.')) > 0) {
        if (double.parse(_amountController.text.replaceAll(',', '.')) <
            amount) {
          widget.hideOverlay();
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) =>
                  SendConfirmScreen(
                addressController.text,
                assetFrom,
                double.parse(_amountController.text.replaceAll(',', '.')),
                fee: bitcoinState.activeFee,
              ),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Insufficient funds',
                style: Theme.of(context).textTheme.headline5,
              ),
              backgroundColor: Theme.of(context).snackBarTheme.backgroundColor,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Invalid amount',
              style: Theme.of(context).textTheme.headline5,
            ),
            backgroundColor: Theme.of(context).snackBarTheme.backgroundColor,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Invalid address',
            style: Theme.of(context).textTheme.headline5,
          ),
          backgroundColor: Theme.of(context).snackBarTheme.backgroundColor,
        ),
      );
    }
  }

  String _getAvailableBalance(state) {
    double balance = convertFromSatoshi(state.availableBalance);
    if (balance > 0) {
      return balancesHelper.numberStyling(balance, fixed: true, fixedCount: 6);
    } else {
      return balancesHelper.numberStyling(0, fixed: true, fixedCount: 6);
    }
  }
}
