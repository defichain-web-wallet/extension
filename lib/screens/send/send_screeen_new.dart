import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/address_book/address_book_cubit.dart';
import 'package:defi_wallet/bloc/bitcoin/bitcoin_cubit.dart';
import 'package:defi_wallet/bloc/tokens/tokens_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/mixins/netwrok_mixin.dart';
import 'package:defi_wallet/mixins/snack_bar_mixin.dart';
import 'package:defi_wallet/models/address_book_model.dart';
import 'package:defi_wallet/models/token_model.dart';
import 'package:defi_wallet/screens/send/send_summary_screen.dart';
import 'package:defi_wallet/screens/settings/settings.dart';
import 'package:defi_wallet/utils/convert.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/widgets/account_drawer/account_drawer.dart';
import 'package:defi_wallet/widgets/dialogs/create_edit_contact_dialog.dart';
import 'package:defi_wallet/widgets/buttons/new_primary_button.dart';
import 'package:defi_wallet/widgets/defi_checkbox.dart';
import 'package:defi_wallet/widgets/error_placeholder.dart';
import 'package:defi_wallet/widgets/fields/address_field_new.dart';
import 'package:defi_wallet/widgets/fields/amount_field.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/selectors/fees_selector.dart';
import 'package:defi_wallet/widgets/toolbar/new_main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SendScreenNew extends StatefulWidget {
  const SendScreenNew({Key? key}) : super(key: key);

  @override
  State<SendScreenNew> createState() => _SendScreenNewState();
}

class _SendScreenNewState extends State<SendScreenNew>
    with ThemeMixin, NetworkMixin, SnackBarMixin {
  TextEditingController addressController = TextEditingController();
  TextEditingController assetController = TextEditingController(text: '0');
  FocusNode addressFocusNode = FocusNode();
  AddressBookModel contact = AddressBookModel();
  TokensModel? currentAsset;
  String suffixText = '';
  String? balanceInUsd;
  String titleText = 'Send';
  String subtitleText = 'Please enter the recipient and amount';
  bool isAddNewContact = false;
  bool isShowCheckbox = false;
  int iterator = 0;

  getTokensList(accountState, tokensState) {
    List<TokensModel> resList = [];
    if (!SettingsHelper.isBitcoin()) {
      accountState.balances!.forEach((element) {
        tokensState.tokens!.forEach((el) {
          if (element.token == el.symbol) {
            resList.add(el);
          }
        });
      });
    }
    return resList;
  }

  double getAvailableBalance(accountState, bitcoinState) {
    if (SettingsHelper.isBitcoin()) {
      if (bitcoinState.totalBalance <= 0) {
        return 0.0;
      } else {
        return convertFromSatoshi(bitcoinState.totalBalance);
      }
    } else {
      int balance = accountState.activeAccount!.balanceList!
          .firstWhere(
              (el) => el.token! == currentAsset!.symbol! && !el.isHidden!)
          .balance!;
      int fee = 3000;
      int resultBalance = balance - fee;

      if (resultBalance <= 0) {
        return 0.0;
      } else {
        return convertFromSatoshi(balance - fee);
      }
    }
  }

  String getUsdBalance(context) {
    TokensCubit tokensCubit = BlocProvider.of<TokensCubit>(context);
    try {
      var amount = tokenHelper.getAmountByUsd(
        tokensCubit.state.tokensPairs!,
        double.parse(assetController.text.replaceAll(',', '.')),
        currentAsset!.symbol!,
      );
      return balancesHelper.numberStyling(amount, fixedCount: 2, fixed: true);
    } catch (err) {
      return '0.00';
    }
  }

  @override
  void initState() {
    addressController.addListener(() {
      if (addressController.text != '') {
        setState(() {
          isShowCheckbox = true;
        });
      } else {
        setState(() {
          isShowCheckbox = false;
          isAddNewContact = false;
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    addressController.dispose();
    // TODO: implement dispose
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
            return BlocBuilder<TokensCubit, TokensState>(
              builder: (tokenContext, tokensState) {
                List<TokensModel> tokens = getTokensList(
                  accountState,
                  tokensState,
                );
                return BlocBuilder<BitcoinCubit, BitcoinState>(
                    builder: (bitcoinContext, bitcoinState) {
                  BitcoinCubit bitcoinCubit =
                      BlocProvider.of<BitcoinCubit>(context);
                  AddressBookCubit addressBookCubit =
                      BlocProvider.of<AddressBookCubit>(context);

                  if (iterator == 0 && SettingsHelper.isBitcoin()) {
                    bitcoinCubit.loadAvailableBalance(
                        accountState.activeAccount!.bitcoinAddress!);
                    iterator++;
                  }

                  if (accountState.status == AccountStatusList.success &&
                      (bitcoinState.status == BitcoinStatusList.success ||
                          !SettingsHelper.isBitcoin())) {
                    if (SettingsHelper.isBitcoin()) {
                      currentAsset = TokensModel(
                        name: 'Bitcoin',
                        symbol: 'BTC',
                      );
                    } else {
                      currentAsset = currentAsset ??
                          getTokensList(accountState, tokensState).first;
                    }
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          titleText,
                                          style: headline2.copyWith(
                                              fontWeight: FontWeight.w700),
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          subtitleText,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline5!
                                              .apply(
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .headline5!
                                                    .color!
                                                    .withOpacity(0.6),
                                              ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 24,
                                    ),
                                    GestureDetector(
                                      onDoubleTap: () {
                                        addressFocusNode.requestFocus();
                                        if (addressController.text.isNotEmpty) {
                                          addressController.selection =
                                              TextSelection(
                                                  baseOffset: 0,
                                                  extentOffset:
                                                      addressController
                                                          .text.length);
                                        }
                                      },
                                      child: AddressFieldNew(
                                        addressFocusNode: addressFocusNode,
                                        clearPrefix: () {
                                          setState(() {
                                            contact = AddressBookModel();
                                          });
                                        },
                                        onChange: (val) {
                                          if (val == '') {
                                            setState(() {
                                              isAddNewContact = false;
                                            });
                                          }
                                        },
                                        controller: addressController,
                                        getAddress: (val) {
                                          addressController.text = val;
                                        },
                                        getContact: (val) {
                                          setState(() {
                                            addressController.text = '';
                                            contact = val;
                                          });
                                        },
                                        contact: contact,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 16,
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          'Asset',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline5,
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 6,
                                    ),
                                    AmountField(
                                      onChanged: (value) {
                                        setState(() {
                                          balanceInUsd = getUsdBalance(context);
                                        });
                                      },
                                      isDisabledSelector:
                                          SettingsHelper.isBitcoin(),
                                      suffix: balanceInUsd ??
                                          getUsdBalance(context),
                                      available: getAvailableBalance(
                                          accountState, bitcoinState),
                                      onAssetSelect: (t) {
                                        setState(() {
                                          currentAsset = t;
                                        });
                                      },
                                      controller: assetController,
                                      selectedAsset: currentAsset!,
                                      assets: tokens,
                                    ),
                                    SizedBox(
                                      height: 16,
                                    ),
                                    if (bitcoinState.networkFee != null &&
                                        SettingsHelper.isBitcoin()) ...[
                                      Row(
                                        children: [
                                          Text(
                                            'Fees',
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline5,
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 6,
                                      ),
                                      FeesSelector(
                                        onSelect: (int fee) {
                                          bitcoinCubit.changeActiveFee(
                                            accountState
                                                .activeAccount!.bitcoinAddress!,
                                            fee,
                                          );
                                        },
                                        activeFee: bitcoinState.activeFee,
                                        fees: [
                                          bitcoinState.networkFee!.low!,
                                          bitcoinState.networkFee!.medium!,
                                          bitcoinState.networkFee!.high!,
                                        ],
                                      ),
                                    ]
                                  ],
                                ),
                                Column(
                                  children: [
                                    if (isShowCheckbox)
                                      DefiCheckbox(
                                        callback: (val) {
                                          setState(() {
                                            isAddNewContact = val!;
                                          });
                                        },
                                        value: isAddNewContact,
                                        width: 250,
                                        isShowLabel: false,
                                        textWidget: Text(
                                          'Add contact to Address Book',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline5!
                                              .copyWith(
                                                fontWeight: FontWeight.w400,
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .headline5!
                                                    .color!
                                                    .withOpacity(0.8),
                                              ),
                                        ),
                                      ),
                                    if (addressController.text != '')
                                      SizedBox(
                                        height: 18.5,
                                      ),
                                    NewPrimaryButton(
                                      width: buttonSmallWidth,
                                      callback: () {
                                        if (txState is! TransactionLoadingState) {
                                          if (addressController.text != '') {
                                            if (isAddNewContact) {
                                              showDialog(
                                                barrierColor: Color(0x0f180245),
                                                barrierDismissible: false,
                                                context: context,
                                                builder: (BuildContext
                                                    dialogContext) {
                                                  return CreateEditContactDialog(
                                                    address:
                                                        addressController.text,
                                                    isEdit: false,
                                                    confirmCallback:
                                                        (name, address) {
                                                      addressBookCubit
                                                          .addAddress(
                                                        AddressBookModel(
                                                            name: name,
                                                            address: address,
                                                            network:
                                                                currentNetworkName()),
                                                      );
                                                      Navigator.push(
                                                        context,
                                                        PageRouteBuilder(
                                                          pageBuilder: (context,
                                                                  animation1,
                                                                  animation2) =>
                                                              SendSummaryScreen(
                                                            address:
                                                                addressController
                                                                    .text,
                                                            isAfterAddContact:
                                                                true,
                                                            amount: double.parse(
                                                                assetController
                                                                    .text),
                                                            token:
                                                                currentAsset!,
                                                            fee: bitcoinState
                                                                .activeFee,
                                                          ),
                                                          transitionDuration:
                                                              Duration.zero,
                                                          reverseTransitionDuration:
                                                              Duration.zero,
                                                        ),
                                                      );
                                                      Navigator.pop(
                                                          dialogContext);
                                                    },
                                                  );
                                                },
                                              );
                                            } else {
                                              Navigator.push(
                                                context,
                                                PageRouteBuilder(
                                                  pageBuilder: (context,
                                                          animation1,
                                                          animation2) =>
                                                      SendSummaryScreen(
                                                    address:
                                                        addressController.text,
                                                    amount: double.parse(
                                                        assetController.text),
                                                    token: currentAsset!,
                                                    fee: bitcoinState.activeFee,
                                                  ),
                                                  transitionDuration:
                                                      Duration.zero,
                                                  reverseTransitionDuration:
                                                      Duration.zero,
                                                ),
                                              );
                                            }
                                          } else if (contact.name != null) {
                                            Navigator.push(
                                              context,
                                              PageRouteBuilder(
                                                pageBuilder: (context,
                                                        animation1,
                                                        animation2) =>
                                                    SendSummaryScreen(
                                                  amount: double.parse(
                                                      assetController.text),
                                                  token: currentAsset!,
                                                  contact: contact,
                                                  fee: bitcoinState.activeFee,
                                                ),
                                                transitionDuration:
                                                    Duration.zero,
                                                reverseTransitionDuration:
                                                    Duration.zero,
                                              ),
                                            );
                                          }
                                        } else {
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
                                        }
                                      },
                                      title: 'Continue',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  } else if (bitcoinState.status == BitcoinStatusList.failure) {
                    return Container(
                      child: Center(
                        child: ErrorPlaceholder(
                          message: 'BTC error',
                          description:
                              'Something error when loading BTC balance',
                        ),
                      ),
                    );
                  } else {
                    return Container();
                  }
                });
              },
            );
          },
        );
      },
    );
  }
}
