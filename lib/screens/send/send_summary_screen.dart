import 'dart:async';
import 'dart:ui';

import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/bitcoin/bitcoin_cubit.dart';
import 'package:defi_wallet/bloc/tokens/tokens_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/helpers/balances_helper.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/helpers/tokens_helper.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/models/account_model.dart';
import 'package:defi_wallet/models/address_book_model.dart';
import 'package:defi_wallet/models/token_model.dart';
import 'package:defi_wallet/models/tx_error_model.dart';
import 'package:defi_wallet/screens/home/home_screen.dart';
import 'package:defi_wallet/screens/send/send_status_screen.dart';
import 'package:defi_wallet/services/hd_wallet_service.dart';
import 'package:defi_wallet/services/transaction_service.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/account_drawer/account_drawer.dart';
import 'package:defi_wallet/widgets/buttons/accent_button.dart';
import 'package:defi_wallet/widgets/buttons/new_primary_button.dart';
import 'package:defi_wallet/widgets/loader/loader_new.dart';
import 'package:defi_wallet/widgets/pass_confirm_dialog.dart';
import 'package:defi_wallet/widgets/password_bottom_sheet.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/tx_status_dialog.dart';
import 'package:defi_wallet/widgets/toolbar/new_main_app_bar.dart';
import 'package:defichaindart/defichaindart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class SendSummaryScreen extends StatefulWidget {
  final Function()? callback;
  final AddressBookModel? contact;
  final String? address;
  final TokensModel token;
  final double amount;
  final bool isAfterAddContact;
  final int? fee;

  const SendSummaryScreen({
    Key? key,
    required this.token,
    required this.amount,
    this.callback,
    this.contact,
    this.address,
    this.isAfterAddContact = false,
    this.fee = 0,
  }) : super(key: key);

  @override
  State<SendSummaryScreen> createState() => _SendSummaryScreenState();
}

class _SendSummaryScreenState extends State<SendSummaryScreen> with ThemeMixin {
  TransactionService transactionService = TransactionService();
  BalancesHelper balancesHelper = BalancesHelper();
  String secondStepLoaderText =
      'One second, Jelly is preparing your transaction!';
  String titleText = 'Summary';
  bool isShowAdded = false;
  late String address;

  @override
  void initState() {
    address =
        widget.address != null ? widget.address! : widget.contact!.address!;
    // TODO: implement initState
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
    return s.substring(0, 14) + '...' + s.substring(28, 42);
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
          drawerScrimColor: Color(0x0f180245),
          endDrawer: AccountDrawer(
            width: buttonSmallWidth,
          ),
          appBar: NewMainAppBar(
            isShowLogo: false,
          ),
          body: BlocBuilder<AccountCubit, AccountState>(
              builder: (context, state) {
            return BlocBuilder<TokensCubit, TokensState>(
              builder: (context, tokensState) {
                return Stack(
                  children: [
                    Container(
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                            SvgPicture.asset(
                                              TokensHelper()
                                                  .getImageNameByTokenName(
                                                      widget.token.symbol),  height: 20,
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
                                                color: AppColors.whiteLilac,
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
                                              padding:
                                                  EdgeInsets.only(bottom: 20),
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
                                            Navigator.pop(context);
                                          },
                                          label: 'Cancel',
                                        ),
                                      ),
                                      NewPrimaryButton(
                                        width: 104,
                                        callback: () {
                                          showDialog(
                                            barrierColor: Color(0x0f180245),
                                            barrierDismissible: false,
                                            context: context,
                                            builder: (BuildContext context1) {
                                              return PassConfirmDialog(
                                                  onSubmit: (password) async {
                                                await submitSend(
                                                  state,
                                                  tokensState,
                                                  password,
                                                );
                                              });
                                            },
                                          );
                                        },
                                        title: 'Send',
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
                                    filter: ImageFilter.blur(
                                        sigmaX: 5.0, sigmaY: 5.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
              },
            );
          }),
        );
      },
    );
  }

  submitSend(state, tokensState, password) async {
    BitcoinCubit bitcoinCubit = BlocProvider.of<BitcoinCubit>(context);
    try {
      if (balancesHelper.toSatoshi(widget.amount.toString()) > 0) {
        _callback(
            state.activeAccount, password, bitcoinCubit, tokensState.tokens);
      }
    } catch (_err) {
      print(_err);
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => SendStatusScreen(
            errorBTC: _err.toString(),
            appBarTitle: 'Change',
            txResponse: null,
            amount: widget.amount,
            token: 'BTC',
            address: address,
          ),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    }
  }

  Future _callback(AccountModel account, String password,
      BitcoinCubit bitcoinCubit, List<TokensModel> tokens) async {
    ECPair keyPair =
        await HDWalletService().getKeypairFromStorage(password, account.index!);
    if (SettingsHelper.isBitcoin()) {
      var tx = await transactionService.createBTCTransaction(
        keyPair: keyPair,
        account: account,
        destinationAddress: address,
        amount: balancesHelper.toSatoshi(widget.amount.toString()),
        satPerByte: widget.fee!,
      );
      var txResponse = await bitcoinCubit.sendTransaction(tx);
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => SendStatusScreen(
              appBarTitle: 'Change',
              txResponse: txResponse,
              amount: widget.amount,
              token: 'BTC',
              address: address),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    } else {
      await _sendTransaction(
          context, tokens, widget.token.symbol!, account, keyPair);
    }
  }

  Future _sendTransaction(context, List<TokensModel> tokens, String token,
      AccountModel account, ECPair keyPair) async {
    TxErrorModel? txResponse;
    if (token == 'DFI') {
      txResponse = await transactionService.createAndSendTransaction(
          keyPair: keyPair,
          account: account,
          destinationAddress: address,
          amount: balancesHelper.toSatoshi(widget.amount.toString()),
          tokens: tokens);
    } else {
      txResponse = await transactionService.createAndSendToken(
          keyPair: keyPair,
          account: account,
          token: token,
          destinationAddress: address,
          amount: balancesHelper.toSatoshi(widget.amount.toString()),
          tokens: tokens);
    }

    showDialog(
      barrierColor: Color(0x0f180245),
      barrierDismissible: false,
      context: context,
      builder: (BuildContext dialogContext) {
        return TxStatusDialog(
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
                context, tokens, widget.token.symbol!, account, keyPair);
          },
        );
      },
    );
  }
}
