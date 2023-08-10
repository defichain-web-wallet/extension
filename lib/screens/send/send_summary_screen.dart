import 'dart:async';
import 'dart:ui';

import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/address_book/address_book_cubit.dart';
import 'package:defi_wallet/bloc/bitcoin/bitcoin_cubit.dart';
import 'package:defi_wallet/bloc/refactoring/wallet/wallet_cubit.dart';
import 'package:defi_wallet/bloc/tokens/tokens_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_bloc.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/helpers/balances_helper.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/helpers/tokens_helper.dart';
import 'package:defi_wallet/mixins/network_mixin.dart';
import 'package:defi_wallet/mixins/snack_bar_mixin.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/models/address_book_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_account_model.dart';
import 'package:defi_wallet/models/network/account_model.dart';
import 'package:defi_wallet/models/token/token_model.dart';
import 'package:defi_wallet/models/token_model.dart';
import 'package:defi_wallet/models/tx_error_model.dart';
import 'package:defi_wallet/screens/home/home_screen.dart';
import 'package:defi_wallet/screens/ledger/ledger_check_screen.dart';
import 'package:defi_wallet/services/navigation/navigator_service.dart';
import 'package:defi_wallet/services/transaction_service.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/account_drawer/account_drawer.dart';
import 'package:defi_wallet/widgets/assets/asset_logo.dart';
import 'package:defi_wallet/widgets/buttons/accent_button.dart';
import 'package:defi_wallet/widgets/buttons/restore_button.dart';
import 'package:defi_wallet/widgets/common/page_title.dart';
import 'package:defi_wallet/widgets/dialogs/pass_confirm_dialog.dart';
import 'package:defi_wallet/widgets/liquidity/asset_pair.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/dialogs/tx_status_dialog.dart';
import 'package:defi_wallet/widgets/toolbar/new_main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SendSummaryScreen extends StatefulWidget {
  final Function()? callback;
  final AddressBookModel? contact;
  final String? address;
  final TokenModel token;
  final double amount;
  final bool isAfterAddContact;
  final int? fee;
  final bool isLedger;

  const SendSummaryScreen({
    Key? key,
    required this.token,
    required this.amount,
    this.callback,
    this.contact,
    this.address,
    this.isAfterAddContact = false,
    this.isLedger = false,
    this.fee = 0,
  }) : super(key: key);

  @override
  State<SendSummaryScreen> createState() => _SendSummaryScreenState();
}

class _SendSummaryScreenState extends State<SendSummaryScreen>
    with ThemeMixin, NetworkMixin, SnackBarMixin {
  TransactionService transactionService = TransactionService();
  BalancesHelper balancesHelper = BalancesHelper();
  String secondStepLoaderText =
      'One second, Jelly is preparing your transaction!';

  String subtitleText =
      'Please confirm the process on your device to complete it.';
  String titleText = 'Summary';
  bool isShowAdded = false;
  late String address;

  @override
  void initState() {
    if (widget.contact != null) {
      address =
          widget.address != null ? widget.address! : widget.contact!.address!;
    } else {
      address = widget.address!;
    }
    super.initState();
    if (widget.isAfterAddContact) {
      isShowAdded = true;
      Timer(Duration(milliseconds: 1500), () {
        setState(() {
          isShowAdded = false;
        });
      });
    }
  }

  cutAddress(String s) {
    if (s.length >= 42) {
      return s.substring(0, 14) + '...' + s.substring(28, 42);
    }
    return s;
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldWrapper(
      builder: (
        BuildContext context,
        bool isFullScreen,
        TransactionState txState,
      ) {
        return Scaffold(
          drawerScrimColor: AppColors.tolopea.withOpacity(0.06),
          endDrawer: isFullScreen
              ? null
              : AccountDrawer(
                  width: buttonSmallWidth,
                ),
          appBar: isFullScreen
              ? null
              : NewMainAppBar(
                  isShowLogo: false,
                ),
          body:
              BlocBuilder<WalletCubit, WalletState>(builder: (context, state) {
            return Stack(
              children: [
                Container(
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              PageTitle(
                                title: titleText,
                                isFullScreen: isFullScreen,
                              ),
                              if (widget.isLedger)
                                SizedBox(
                                  height: 8,
                                ),
                              if (widget.isLedger)
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
                                  softWrap: true,
                                  textAlign: TextAlign.start,
                                ),
                              if (widget.isLedger)
                                SizedBox(
                                  height: 16,
                                ),
                              if (widget.isLedger)
                                Container(
                                  width: 296,
                                  height: 118,
                                  child: Stack(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 4,
                                        ),
                                        child: Image.asset(
                                          'assets/images/ledger_light.png',
                                          width: 296,
                                          height: 114,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: 53,
                                          ),
                                          Container(
                                            width: 45,
                                            height: 45,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                  color: AppColors.pinkColor),
                                              color: AppColors.pinkColor
                                                  .withOpacity(0.1),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 39,
                                          ),
                                          Container(
                                            width: 45,
                                            height: 45,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                  color: AppColors.pinkColor),
                                              color: AppColors.pinkColor
                                                  .withOpacity(0.1),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              SizedBox(
                                height: 16,
                              ),
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 21),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: AppColors.lavenderPurple
                                            .withOpacity(0.32))),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Do you really want to send',
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
                                          MainAxisAlignment.center,
                                      children: [
                                        if (tokenHelper
                                            .isPair(widget.token.symbol))
                                          AssetPair(
                                            isBorder: false,
                                            pair: widget.token.symbol,
                                            height: 20,
                                          ),
                                        if (!tokenHelper
                                            .isPair(widget.token.symbol))
                                          AssetLogo(
                                            size: 20,
                                            assetStyle: tokenHelper
                                                .getAssetStyleByTokenName(
                                                    widget.token.symbol),
                                            borderWidth: 0,
                                            isBorder: false,
                                          ),
                                        SizedBox(
                                          width: 6.4,
                                        ),
                                        Text(
                                          widget.amount.toString(),
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline4!
                                              .copyWith(
                                                fontSize: 20,
                                              ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 12,
                                    ),
                                    Text(
                                      'to',
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
                                      height: 12,
                                    ),
                                    if (widget.contact != null)
                                      Text(
                                        widget.contact!.name!,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline4!
                                            .copyWith(
                                              fontSize: 20,
                                            ),
                                      ),
                                    if (widget.contact != null)
                                      SizedBox(
                                        height: 4,
                                      ),
                                    if (widget.contact != null)
                                      Text(
                                        widget.contact!.address!,
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
                                    if (widget.address != null)
                                      Tooltip(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 12,
                                          horizontal: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isDarkTheme()
                                              ? DarkColors.drawerBgColor
                                              : LightColors.drawerBgColor,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: AppColors.lavenderPurple
                                                .withOpacity(0.32),
                                            width: 0.5,
                                          ),
                                        ),
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .subtitle2!
                                            .copyWith(
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .subtitle2!
                                                  .color!
                                                  .withOpacity(0.5),
                                              fontSize: 10,
                                            ),
                                        message: '${widget.address!}',
                                        child: Padding(
                                          padding: EdgeInsets.only(bottom: 20),
                                          child: Text(
                                            cutAddress(widget.address!),
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline4!
                                                .copyWith(
                                                  fontSize: 20,
                                                ),
                                          ),
                                        ),
                                      )
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width: 104,
                                    child: AccentButton(
                                      callback: () {
                                        NavigatorService.pop(context);
                                      },
                                      label: 'Cancel',
                                    ),
                                  ),
                                  SizedBox(
                                    width: 104,
                                    child: PendingButton(
                                      'Send',
                                      isCheckLock: false,
                                      pendingText: 'Pending',
                                      callback: (parent) async {
                                        parent.emitPending(true);
                                        await showDialog(
                                          barrierColor: AppColors.tolopea
                                              .withOpacity(0.06),
                                          barrierDismissible: false,
                                          context: context,
                                          builder: (BuildContext context1) {
                                            return PassConfirmDialog(
                                              onCancel: () {
                                                parent.emitPending(false);
                                              },
                                              onSubmit: (password) async {
                                                await submitSend(
                                                  state,
                                                  password,
                                                  isFullScreen,
                                                );
                                              },
                                              context: context,
                                            );
                                          },
                                        );

                                        parent?.emitPending(false);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (isShowAdded)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 253,
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6.4),
                              color: AppColors.malachite.withOpacity(0.08),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6.4),
                              child: BackdropFilter(
                                filter:
                                    ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.done,
                                      color: Color(0xFF00CF21),
                                      size: 24,
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text('A new contact has been added')
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 96,
                      ),
                    ],
                  ),
              ],
            );
          }),
        );
      },
    );
  }

  Future submitSend(
    WalletState state,
    password,
    isFullScreen, {
    final Function()? callbackOk,
  }) async {
    try {
      if (widget.amount > 0) {
        await _sendTransaction(
          context,
          widget.token,
          state,
          password,
          isFullScreen,
          callbackOk: callbackOk,
        );
      }
    } catch (err) {
      print(err);
      if (!state.applicationModel!.activeNetwork!.networkType.isLocalWallet) {
        throw err;
      }
    }
  }

  Future _sendTransaction(
    context,
    TokenModel token,
    WalletState walletState,
    String? password,
    bool isFullScreen, {
    final Function()? callbackOk,
  }) async {
    TxErrorModel? txResponse;
    AddressBookCubit addressBookCubit =
        BlocProvider.of<AddressBookCubit>(context);

    var network = walletState.applicationModel!.activeNetwork!;

    txResponse = await network.send(
      account: walletState.activeAccount,
      address: address,
      password: password!,
      token: token,
      amount: widget.amount,
      applicationModel: walletState.applicationModel!,
      satPerByte: widget.fee ?? 0,
    );

    addressBookCubit.addAddressToLastSent(
        context,
        AddressBookModel(
          address: address,
        ));

    showDialog(
      barrierColor: AppColors.tolopea.withOpacity(0.06),
      barrierDismissible: false,
      context: context,
      builder: (BuildContext dialogContext) {
        return TxStatusDialog(
          txResponse: txResponse,
          callbackOk: () async {
            if (callbackOk != null) {
              callbackOk();
            }
            if (!txResponse!.isError! && !walletState.isSendReceiveOnly) {
              TransactionCubit transactionCubit =
                  BlocProvider.of<TransactionCubit>(context);

              await transactionCubit.setOngoingTransaction(txResponse);
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
            await _sendTransaction(
              context,
              widget.token,
              walletState,
              password,
              isFullScreen,
            );
          },
        );
      },
    );
  }
}
