import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/bitcoin/bitcoin_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_bloc.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/helpers/addresses_helper.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/models/focus_model.dart';
import 'package:defi_wallet/requests/btc_requests.dart';
import 'package:defi_wallet/screens/send/widgets/address_field.dart';
import 'package:defi_wallet/screens/send/widgets/asset_dropdown.dart';
import 'package:defi_wallet/screens/send/widgets/fee_card.dart';
import 'package:defi_wallet/widgets/buttons/primary_button.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_constrained_box.dart';
import 'package:defi_wallet/helpers/balances_helper.dart';
import 'package:defi_wallet/helpers/tokens_helper.dart';
import 'package:defi_wallet/screens/home/widgets/asset_select.dart';
import 'package:defi_wallet/screens/send/send_confirm_screen.dart';
import 'package:defi_wallet/services/transaction_service.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:defi_wallet/utils/convert.dart';
import 'package:defi_wallet/widgets/loader/loader.dart';
import 'package:defi_wallet/widgets/toolbar/main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SendTokenSelector extends StatefulWidget {
  final String selectedAddress;

  const SendTokenSelector({
    Key? key,
    this.selectedAddress = '',
  }) : super(key: key);

  @override
  State<SendTokenSelector> createState() => _SendConfirmState();
}

class _SendConfirmState extends State<SendTokenSelector> {
  TokensHelper tokenHelper = TokensHelper();
  BalancesHelper balancesHelper = BalancesHelper();
  TransactionService transactionService = TransactionService();
  GlobalKey<AssetSelectState> _selectKeyFrom = GlobalKey<AssetSelectState>();
  TextEditingController _amountController = TextEditingController(text: '0');
  FocusNode _amountFocusNode = new FocusNode();
  FocusModel _amountFocusModel = new FocusModel();
  AddressesHelper addressHelper = AddressesHelper();
  TextEditingController addressController = TextEditingController();
  BtcRequests btcRequests = BtcRequests();
  double toolbarHeight = 55;
  double toolbarHeightWithBottom = 105;
  String assetFrom = '';
  String assetTo = '';
  int selectedFee = 0;
  double btcAvailableBalance = 0;

  @override
  void initState() {
    super.initState();
    BitcoinCubit bitcoinCubit = BlocProvider.of<BitcoinCubit>(context);
    selectedFee = bitcoinCubit.state.networkFee!.low!;
    btcAvailableBalance =
        convertFromSatoshi(bitcoinCubit.state.availableBalance);
  }

  void dispose() {
    hideOverlay();
    super.dispose();
  }

  void hideOverlay() {
    try {
      _selectKeyFrom.currentState!.hideOverlay();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<TransactionCubit, TransactionState>(
        builder: (context, state) => ScaffoldConstrainedBox(
            child: LayoutBuilder(builder: (context, constraints) {
          if (constraints.maxWidth < ScreenSizes.medium) {
            return Scaffold(
              appBar: MainAppBar(
                title: 'Send',
                hideOverlay: () => hideOverlay(),
                isShowBottom: !(state is TransactionInitialState),
                height: !(state is TransactionInitialState)
                    ? toolbarHeightWithBottom
                    : toolbarHeight,
              ),
              body: _buildBody(context, state),
            );
          } else {
            return Container(
              padding: const EdgeInsets.only(top: 20),
              child: Scaffold(
                appBar: MainAppBar(
                  title: 'Send',
                  hideOverlay: () => hideOverlay(),
                  action: null,
                  isSmall: true,
                ),
                body: _buildBody(context, state, isCustomBgColor: true),
              ),
            );
          }
        })),
      );

  Widget _buildBody(context, transactionState, {isCustomBgColor = false}) =>
      BlocBuilder<AccountCubit, AccountState>(
        builder: (context, state) {
          BitcoinCubit bitcoinCubit = BlocProvider.of<BitcoinCubit>(context);
          if (state.status == AccountStatusList.success) {
            List<String> assets = [];
            if (SettingsHelper.isBitcoin()) {
              assetFrom = 'BTC';
              assets = [];
            } else {
              assetFrom = (assetFrom.isEmpty) ? state.activeToken! : assetFrom;
              state.activeAccount!.balanceList!.forEach((el) {
                if (!el.isHidden!) {
                  assets.add(el.token!);
                }
              });
            }

            addressController.text = widget.selectedAddress;

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
                      Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Address',
                                style: Theme.of(context).textTheme.headline6),
                            SizedBox(height: 16),
                            AddressField(
                              addressController: addressController,
                            ),
                            SizedBox(height: 8),
                            Divider(),
                            SizedBox(height: 12),
                            Text(
                              'Amount',
                              style: Theme.of(context).textTheme.headline6,
                            ),
                            SizedBox(height: 16),
                            AssetDropdown(
                              selectKeyFrom: _selectKeyFrom,
                              amountController: _amountController,
                              focusNode: _amountFocusNode,
                              focusModel: _amountFocusModel,
                              assets: assets,
                              assetFrom: assetFrom,
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
                                  _amountController.text = amount.toString();
                                });
                              },
                              isFixedWidthAssetSelectorText: isCustomBgColor,
                            ),
                            SizedBox(height: 16),
                            Text(
                                "Available balance: ${balancesHelper.numberStyling(btcAvailableBalance, fixed: true, fixedCount: 6)} BTC"),
                            SizedBox(height: 28),
                            Text("Fees"),
                            SizedBox(height: 16),
                            Column(
                              children: [
                                FeeCard(
                                  fee: bitcoinCubit.state.networkFee!.low!,
                                  iconUrl: '',
                                  label: 'Slow',
                                  callback: () async {
                                    setState(() {
                                      selectedFee =
                                          bitcoinCubit.state.networkFee!.low!;
                                    });
                                    double balance =
                                        await getAvailableBalance(state);
                                    setState(() {
                                      btcAvailableBalance = balance;
                                    });
                                  },
                                  isActive: selectedFee ==
                                      bitcoinCubit.state.networkFee!.low,
                                ),
                                SizedBox(height: 8),
                                FeeCard(
                                  fee: bitcoinCubit.state.networkFee!.medium!,
                                  iconUrl: '',
                                  label: 'Medium',
                                  callback: () async {
                                    setState(() {
                                      selectedFee = bitcoinCubit
                                          .state.networkFee!.medium!;
                                    });
                                    double balance =
                                        await getAvailableBalance(state);
                                    setState(() {
                                      btcAvailableBalance = balance;
                                    });
                                  },
                                  isActive: selectedFee ==
                                      bitcoinCubit.state.networkFee!.medium,
                                ),
                                SizedBox(height: 8),
                                FeeCard(
                                  fee: bitcoinCubit.state.networkFee!.high!,
                                  iconUrl: '',
                                  label: 'Fast',
                                  callback: () async {
                                    setState(() {
                                      selectedFee =
                                          bitcoinCubit.state.networkFee!.high!;
                                    });
                                    double balance =
                                        await getAvailableBalance(state);
                                    setState(() {
                                      btcAvailableBalance = balance;
                                    });
                                  },
                                  isActive: selectedFee ==
                                      bitcoinCubit.state.networkFee!.high,
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                      PrimaryButton(
                        label: 'Continue',
                        callback: () =>
                            submitToConfirm(state, transactionState),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            return Loader();
          }
        },
      );

  submitToConfirm(state, transactionState) async {
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
      valid = await addressHelper.validateAddress(addressController.text);
      amount = btcAvailableBalance;
    } else {
      valid = await addressHelper.validateBtcAddress(addressController.text);
      balance = state.activeAccount.balanceList!
          .firstWhere((el) => el.token! == assetFrom && !el.isHidden)
          .balance!;
      amount = convertFromSatoshi(balance - fee);
    }
    if (valid) {
      if (double.parse(_amountController.text.replaceAll(',', '.')) > 0) {
        if (double.parse(_amountController.text.replaceAll(',', '.')) <
            amount) {
          hideOverlay();
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) =>
                  SendConfirmScreen(
                addressController.text,
                assetFrom,
                double.parse(_amountController.text.replaceAll(',', '.')),
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

  Future<double> getAvailableBalance(state) async {
    int balance = await btcRequests.getAvailableBalance(
        address: state.activeAccount!.bitcoinAddress!, feePerByte: selectedFee);
    return convertFromSatoshi(balance);
  }
}
