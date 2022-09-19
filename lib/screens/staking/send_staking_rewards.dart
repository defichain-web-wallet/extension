import 'dart:convert';

import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/fiat/fiat_cubit.dart';
import 'package:defi_wallet/bloc/staking/staking_cubit.dart';
import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/models/available_asset_model.dart';
import 'package:defi_wallet/models/iban_model.dart';
import 'package:defi_wallet/screens/home/widgets/asset_select.dart';
import 'package:defi_wallet/screens/home/widgets/home_app_bar.dart';
import 'package:defi_wallet/screens/sell/selling.dart';
import 'package:defi_wallet/screens/staking/number_of_coins_to_stake.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:defi_wallet/widgets/buttons/accent_button.dart';
import 'package:defi_wallet/widgets/buttons/primary_button.dart';
import 'package:defi_wallet/widgets/loader/loader.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_constrained_box.dart';
import 'package:defi_wallet/widgets/scaffold_constrained_box_new.dart';
import 'package:defi_wallet/widgets/selectors/currency_selector.dart';
import 'package:defi_wallet/widgets/selectors/iban_selector.dart';
import 'package:defi_wallet/widgets/toolbar/main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SendStakingRewardsScreen extends StatefulWidget {
  final bool isNewIban;
  final bool isPayment;

  const SendStakingRewardsScreen({
    Key? key,
    this.isPayment = false,
    this.isNewIban = false,
  }) : super(key: key);

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

  String assetFrom = '';

  StakingType type = StakingType.Reinvest;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountCubit, AccountState>(
      builder: (context, state) {
        FiatCubit fiatCubit = BlocProvider.of<FiatCubit>(context);
        StakingCubit stakingCubit = BlocProvider.of<StakingCubit>(context);
        fiatCubit.loadAllAssets(state.accessToken!, isSell: true);
        return BlocBuilder<FiatCubit, FiatState>(builder: (context, fiatState) {
          return BlocBuilder<StakingCubit, StakingState>(
            builder: (context, stakingState) {
              if (state.status == AccountStatusList.success &&
                  fiatState.status == FiatStatusList.success) {
                List<IbanModel> uniqueIbans =
                    fiatState.ibanList!.where((el) => el.fiat != null).toList();

                assetFrom =
                    (assetFrom.isEmpty) ? state.activeToken! : assetFrom;
                List<String> assets = [];
                fiatState.assets!.forEach((el) {
                  assets.add(el.dexName!);
                });

                return ScaffoldConstrainedBox(
                  child: GestureDetector(
                    onTap: () => hideOverlay(),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth < ScreenSizes.medium) {
                          return Scaffold(
                            appBar: MainAppBar(
                              hideOverlay: hideOverlay,
                              title: 'Staking',
                            ),
                            body: _buildBody(state, fiatState, stakingState,
                                stakingCubit, uniqueIbans, assets),
                          );
                        } else {
                          return Container(
                            padding: const EdgeInsets.only(top: 20),
                            child: Scaffold(
                              appBar: MainAppBar(
                                hideOverlay: hideOverlay,
                                title: 'Staking',
                                isSmall: true,
                              ),
                              body: _buildBody(
                                state,
                                fiatState,
                                stakingState,
                                stakingCubit,
                                uniqueIbans,
                                assets,
                                isFullSize: true,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                );
              } else {
                return Loader();
              }
            },
          );
        });
      },
    );
  }

  Widget _buildBody(
          state, fiatState, stakingState, stakingCubit, uniqueIbans, assets,
          {isFullSize = false}) =>
      Container(
        color: Theme.of(context).dialogBackgroundColor,
        padding:
            const EdgeInsets.only(left: 18, right: 12, top: 24, bottom: 24),
        child: Center(
          child: StretchBox(
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
                                widget.isPayment
                                    ? 'Where should we send your staking rewards?'
                                    : 'Where do you want to receive your staking rewards?',
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
                                            color: type == StakingType.Reinvest
                                                ? AppTheme.pinkColor
                                                : Colors.transparent,
                                            width: 1,
                                            style: BorderStyle.solid,
                                          ),
                                        ),
                                        child: Center(child: Text('Reinvest')),
                                      ),
                                      onTap: () {
                                        hideOverlay();
                                        type = StakingType.Reinvest;
                                        if (widget.isPayment) {
                                          stakingCubit.setPaymentType(type);
                                        } else {
                                          stakingCubit.setRewardType(type);
                                        }
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
                                            color: type == StakingType.Wallet
                                                ? AppTheme.pinkColor
                                                : Colors.transparent,
                                            width: 1,
                                            style: BorderStyle.solid,
                                          ),
                                        ),
                                        child: Center(child: Text('Wallet')),
                                      ),
                                      onTap: () {
                                        hideOverlay();
                                        type = StakingType.Wallet;
                                        if (widget.isPayment) {
                                          stakingCubit.setPaymentType(type);
                                        } else {
                                          stakingCubit.setRewardType(type);
                                        }
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
                                            color:
                                                type == StakingType.BankAccount
                                                    ? AppTheme.pinkColor
                                                    : Colors.transparent,
                                            width: 1,
                                            style: BorderStyle.solid,
                                          ),
                                        ),
                                        child: Center(child: Text('Auto sell')),
                                      ),
                                      onTap: () {
                                        hideOverlay();
                                        type = StakingType.BankAccount;
                                        if (widget.isPayment) {
                                          stakingCubit.setPaymentType(type);
                                        } else {
                                          stakingCubit.setRewardType(type);
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            type == StakingType.Wallet
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
                                : type == StakingType.BankAccount
                                    ? Container(
                                        padding: EdgeInsets.only(top: 30),
                                        child: Column(
                                          children: [
                                            Form(
                                              key: _formKey,
                                              child: Container(
                                                padding:
                                                    EdgeInsets.only(top: 10),
                                                child: IbanSelector(
                                                  key: selectKeyIban,
                                                  onAnotherSelect: hideOverlay,
                                                  routeWidget: Selling(
                                                    isNewIban: widget.isNewIban,
                                                  ),
                                                  ibanList: uniqueIbans,
                                                  selectedIban:
                                                      fiatState.activeIban!,
                                                  isShowAsset: true,
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
                          callback: () async {
                            hideOverlay();
                            AssetByFiatModel foundAsset = fiatState.assets!
                                .firstWhere(
                                    (element) => element.dexName == assetFrom);

                            try {
                              if (widget.isPayment) {
                                stakingCubit.updatePaymentInfo(
                                    type, foundAsset, fiatState.activeIban!);
                                String rewardType = stakingState.rewardType
                                    .toString()
                                    .split('.')[1];
                                String paybackType = stakingState.paymentType
                                    .toString()
                                    .split('.')[1];
                                try {
                                  var foundedRoute = stakingState.routes!
                                      .firstWhere((element) =>
                                          element.active! &&
                                          element.rewardType == rewardType &&
                                          element.paybackType == paybackType);
                                  await stakingCubit.createStaking(
                                      state.accessToken!,
                                      isActive: true,
                                      id: foundedRoute.id!);
                                } catch (err) {
                                  await stakingCubit
                                      .createStaking(state.accessToken!);
                                }
                              } else {
                                stakingCubit.updateRewardInfo(
                                    type, foundAsset, fiatState.activeIban!);
                              }
                              Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder:
                                        (context, animation1, animation2) =>
                                            widget.isPayment
                                                ? NumberOfCoinsToStakeScreen()
                                                : SendStakingRewardsScreen(
                                                    isPayment: true),
                                    transitionDuration: Duration.zero,
                                    reverseTransitionDuration: Duration.zero,
                                  ));
                            } catch (err) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    err.toString().replaceAll("\"", ''),
                                    style:
                                        Theme.of(context).textTheme.headline5,
                                  ),
                                  backgroundColor: Theme.of(context)
                                      .snackBarTheme
                                      .backgroundColor,
                                ),
                              );
                            }
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

  hideOverlay() {
    try {
      _selectKeyFrom.currentState!.hideOverlay();
    } catch (_) {}
    try {
      _selectKeyCurrency.currentState!.hideOverlay();
    } catch (_) {}
    try {
      selectKeyIban.currentState!.hideOverlay();
    } catch (_) {}
  }
}
