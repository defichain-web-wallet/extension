import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/staking/staking_cubit.dart';
import 'package:defi_wallet/bloc/tokens/tokens_cubit.dart';
import 'package:defi_wallet/helpers/balances_helper.dart';
import 'package:defi_wallet/helpers/lock_helper.dart';
import 'package:defi_wallet/models/account_model.dart';
import 'package:defi_wallet/models/tx_error_model.dart';
import 'package:defi_wallet/screens/staking/staking_initiated.dart';
import 'package:defi_wallet/services/transaction_service.dart';
import 'package:defi_wallet/widgets/buttons/accent_button.dart';
import 'package:defi_wallet/widgets/buttons/primary_button.dart';
import 'package:defi_wallet/widgets/scaffold_constrained_box_new.dart';
import 'package:defi_wallet/widgets/toolbar/main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class StakingConfirmTransaction extends StatefulWidget {
  final double amount;
  final String assetName;

  const StakingConfirmTransaction(
      {Key? key, required this.amount, required this.assetName})
      : super(key: key);

  @override
  _StakingConfirmTransactionState createState() => _StakingConfirmTransactionState();
}

class _StakingConfirmTransactionState extends State<StakingConfirmTransaction> {
  BalancesHelper balancesHelper = BalancesHelper();
  LockHelper lockHelper = LockHelper();

  TransactionService transactionService = TransactionService();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StakingCubit, StakingState>(builder: (context, state) {
      return BlocBuilder<AccountCubit, AccountState>(builder: (context, accountState) {
        return ScaffoldConstrainedBoxNew(
          appBar: MainAppBar(
            title: 'Staking',
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.only(top: 15),
                          child: SvgPicture.asset('assets/staking_logo.svg'),
                        ),
                        Container(
                          padding: EdgeInsets.only(top: 30),
                          child: Text(
                            'Confirm transcation',
                            style: Theme.of(context).textTheme.headline6,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(top: 30),
                          child: Column(
                            children: [
                              Container(
                                height: 34,
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                        width: 1.0,
                                        color: Colors.black.withOpacity(0.1),
                                        style: BorderStyle.solid),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Staking service provider',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline2,
                                    ),
                                    Text(
                                      'DFX Swiss AG',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline3,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                height: 34,
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                        width: 1.0,
                                        color: Colors.black.withOpacity(0.1),
                                        style: BorderStyle.solid),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Currently staked',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline2,
                                    ),
                                    Text(
                                      '${state.amount} DFI',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline3,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                height: 34,
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                        width: 1.0,
                                        color: Colors.black.withOpacity(0.1),
                                        style: BorderStyle.solid),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'New amount staked',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline2,
                                    ),
                                    Text(
                                      '${widget.amount} ${widget.assetName}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline3,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                height: 34,
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                        width: 1.0,
                                        color: Colors.black.withOpacity(0.1),
                                        style: BorderStyle.solid),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Investment strategy',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline2,
                                    ),
                                    Text(
                                      'Auto sell',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline3,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(top: 16),
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                    text: 'Note: ',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline2),
                                TextSpan(
                                    text:
                                    'I am aware that staking service is provided by DFX Swiss. I am note holding the private keys to the coins which are invested into staking. By confirming, I confirm that my DFI will be locked for 4 weeks.  ',
                                    style:
                                    Theme.of(context).textTheme.headline3)
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: AccentButton(
                        label: 'Cancel',
                        callback: () => Navigator.of(context).pop()),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: PrimaryButton(
                      label: 'Staking',
                      isCheckLock: false,
                      callback: () async {

                        TokensState tokensState = BlocProvider.of<TokensCubit>(context).state;
                        await _sendTransaction(
                            context,
                            tokensState,
                            widget.assetName,
                            accountState.activeAccount!,
                            state.depositAddress!,
                            widget.amount,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      });
    });
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
      await Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => StakingInitiated(
              txResponse: txResponse,
            ),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ));
    } catch (err) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Something went wrong. Please try later',
            style:
            Theme.of(context).textTheme.headline5,
          ),
          backgroundColor: Theme.of(context)
              .snackBarTheme
              .backgroundColor,
        ),
      );
    }
  }
}

