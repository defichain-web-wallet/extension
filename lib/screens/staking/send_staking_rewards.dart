import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/models/fiat_model.dart';
import 'package:defi_wallet/screens/home/widgets/asset_select.dart';
import 'package:defi_wallet/screens/staking/staking_confirm_transaction.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:defi_wallet/widgets/buttons/accent_button.dart';
import 'package:defi_wallet/widgets/buttons/primary_button.dart';
import 'package:defi_wallet/widgets/fields/iban_field.dart';
import 'package:defi_wallet/widgets/loader/loader.dart';
import 'package:defi_wallet/widgets/scaffold_constrained_box_new.dart';
import 'package:defi_wallet/widgets/selectors/currency_selector.dart';
import 'package:defi_wallet/widgets/selectors/iban_selector.dart';
import 'package:defi_wallet/widgets/toolbar/main_app_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SendStakingRewardsScreen extends StatefulWidget {
  final bool isNewIban;

  const SendStakingRewardsScreen({Key? key, this.isNewIban = false})
      : super(key: key);

  @override
  _SendStakingRewardsScreenState createState() =>
      _SendStakingRewardsScreenState();
}

class _SendStakingRewardsScreenState extends State<SendStakingRewardsScreen> {
  GlobalKey<AssetSelectState> _selectKeyFrom = GlobalKey<AssetSelectState>();
  final GlobalKey<CurrencySelectorState> _selectKeyCurrency =
      GlobalKey<CurrencySelectorState>();
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<IbanSelectorState> selectKeyIban =
      GlobalKey<IbanSelectorState>();

  FiatModel selectedFiat = FiatModel(name: "EUR", enable: true, id: 2);
  String assetFrom = '';

  bool isReinvest = true;
  bool isWallet = false;
  bool isAutoSell = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountCubit, AccountState>(
      builder: (context, state) {
        if (state.status == AccountStatusList.success) {
          assetFrom = (assetFrom.isEmpty) ? state.activeToken! : assetFrom;
          List<String> assets = [];
          state.activeAccount!.balanceList!.forEach((el) {
            if (!el.isHidden!) {
              assets.add(el.token!);
            }
          });

          return ScaffoldConstrainedBoxNew(
            hideOverlay: hideOverlay,
            appBar: MainAppBar(
              hideOverlay: hideOverlay,
              title: 'Staking',
            ),
            child: GestureDetector(
              onTap: () {
                hideOverlay();
              },
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
                              child:
                                  SvgPicture.asset('assets/staking_logo.svg'),
                            ),
                            Container(
                              padding: EdgeInsets.only(top: 30),
                              child: Text(
                                'Where should we send your staking rewards?',
                                style: Theme.of(context).textTheme.headline6,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(top: 30),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: GestureDetector(
                                      child: Container(
                                        width: 100,
                                        height: 46,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).cardColor,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                            color: isReinvest
                                                ? AppTheme.pinkColor
                                                : Theme.of(context)
                                                    .dividerColor,
                                            width: 1,
                                            style: BorderStyle.solid,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppTheme.shadowColor
                                                  .withOpacity(0.1),
                                              spreadRadius: 2,
                                              blurRadius: 3,
                                            ),
                                          ],
                                        ),
                                        child: Center(child: Text('Reinvest')),
                                      ),
                                      onTap: () {
                                        hideOverlay();
                                        setState(() {
                                          isReinvest = true;
                                          isWallet = false;
                                          isAutoSell = false;
                                        });
                                      },
                                    ),
                                  ),
                                  MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: GestureDetector(
                                      child: Container(
                                        width: 100,
                                        height: 46,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).cardColor,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                            color: isWallet
                                                ? AppTheme.pinkColor
                                                : Theme.of(context)
                                                    .dividerColor,
                                            width: 1,
                                            style: BorderStyle.solid,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppTheme.shadowColor
                                                  .withOpacity(0.1),
                                              spreadRadius: 2,
                                              blurRadius: 3,
                                            ),
                                          ],
                                        ),
                                        child: Center(child: Text('Wallet')),
                                      ),
                                      onTap: () {
                                        hideOverlay();
                                        setState(() {
                                          isReinvest = false;
                                          isWallet = true;
                                          isAutoSell = false;
                                        });
                                      },
                                    ),
                                  ),
                                  MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: GestureDetector(
                                      child: Container(
                                        width: 100,
                                        height: 46,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).cardColor,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                            color: isAutoSell
                                                ? AppTheme.pinkColor
                                                : Theme.of(context)
                                                    .dividerColor,
                                            width: 1,
                                            style: BorderStyle.solid,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppTheme.shadowColor
                                                  .withOpacity(0.1),
                                              spreadRadius: 2,
                                              blurRadius: 3,
                                            ),
                                          ],
                                        ),
                                        child: Center(child: Text('Auto sell')),
                                      ),
                                      onTap: () {
                                        hideOverlay();
                                        setState(() {
                                          isReinvest = false;
                                          isWallet = false;
                                          isAutoSell = true;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            isWallet
                                ? Container(
                                    padding: EdgeInsets.only(top: 30),
                                    child: Column(
                                      children: [
                                        Text(
                                          'In which currencie do you want to receive your staking rewards?',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline2,
                                        ),
                                        Container(
                                          padding: EdgeInsets.only(top: 20),
                                          child: Container(
                                            width: 250,
                                            child: AssetSelect(
                                              onAnotherSelect: hideOverlay,
                                              isTopPosition: true,
                                              key: _selectKeyFrom,
                                              isBorderRadiusAll: true,
                                              tokensForSwap: assets,
                                              selectedToken: assetFrom,
                                              onSelect: (String asset) {
                                                setState(
                                                    () => {assetFrom = asset});
                                              },
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                : isAutoSell
                                    ? Container(
                                        padding: EdgeInsets.only(top: 30),
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Container(
                                                    child: CurrencySelector(
                                                        onAnotherSelect:
                                                            hideOverlay,
                                                        currencies: [
                                                          FiatModel(
                                                            name: "CHF",
                                                            enable: true,
                                                            id: 1,
                                                          ),
                                                          FiatModel(
                                                            name: "EUR",
                                                            enable: true,
                                                            id: 2,
                                                          ),
                                                        ],
                                                        key: _selectKeyCurrency,
                                                        selectedCurrency:
                                                            selectedFiat,
                                                        onSelect: (FiatModel
                                                            selected) {
                                                          setState(() {
                                                            selectedFiat =
                                                                selected;
                                                          });
                                                        }),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Container(),
                                                ),
                                              ],
                                            ),
                                            Form(
                                              key: _formKey,
                                              child: Container(
                                                padding:
                                                    EdgeInsets.only(top: 10),
                                                child: IbanField(
                                                  onFocus: hideOverlay,
                                                  ibanController:
                                                      TextEditingController(),
                                                  hintText:
                                                      'DE89 3704 0044 0532 0130 00',
                                                  maskFormat:
                                                      'AA## #### #### #### #### ##',
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : Container(),
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
                            callback: () {
                              hideOverlay();
                              Navigator.of(context).pop();
                            }),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: PrimaryButton(
                          label: 'Next',
                          isCheckLock: false,
                          callback: () {
                            hideOverlay();
                            Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder:
                                      (context, animation1, animation2) =>
                                          StakingConfirmTransaction(),
                                  transitionDuration: Duration.zero,
                                  reverseTransitionDuration: Duration.zero,
                                ));
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        } else {
          return Loader();
        }
      },
    );
  }

  hideOverlay() {
    try {
      _selectKeyFrom.currentState!.hideOverlay();
    } catch (_) {}try {
      _selectKeyCurrency.currentState!.hideOverlay();
    } catch (_) {}
  }
}
