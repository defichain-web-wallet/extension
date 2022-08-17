import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/models/focus_model.dart';
import 'package:defi_wallet/screens/home/widgets/asset_select.dart';
import 'package:defi_wallet/screens/send/widgets/asset_dropdown.dart';
import 'package:defi_wallet/screens/staking/send_staking_rewards.dart';
import 'package:defi_wallet/utils/convert.dart';
import 'package:defi_wallet/widgets/buttons/accent_button.dart';
import 'package:defi_wallet/widgets/buttons/primary_button.dart';
import 'package:defi_wallet/widgets/loader/loader.dart';
import 'package:defi_wallet/widgets/scaffold_constrained_box_new.dart';
import 'package:defi_wallet/widgets/toolbar/main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NumberOfCoinsToStakeScreen extends StatefulWidget {
  const NumberOfCoinsToStakeScreen({Key? key}) : super(key: key);

  @override
  _NumberOfCoinsToStakeScreenState createState() =>
      _NumberOfCoinsToStakeScreenState();
}

class _NumberOfCoinsToStakeScreenState
    extends State<NumberOfCoinsToStakeScreen> {
  GlobalKey<AssetSelectState> _selectKeyFrom = GlobalKey<AssetSelectState>();
  TextEditingController _amountController = TextEditingController(text: '0');
  FocusNode _amountFocusNode = new FocusNode();
  FocusModel _amountFocusModel = new FocusModel();
  String assetFrom = '';
  bool isFailed = false;

  void hideOverlay() {
    try {
      _selectKeyFrom.currentState!.hideOverlay();
    } catch (_) {}
  }

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
                        padding: const EdgeInsets.only(top: 0),
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
                                'How much DFI do you want to stake?',
                                style: Theme.of(context).textTheme.headline6,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(top: 30),
                              child: AssetDropdown(
                                onAnotherSelect: hideOverlay,
                                isMaxOnly: true,
                                selectKeyFrom: _selectKeyFrom,
                                amountController: _amountController,
                                focusNode: _amountFocusNode,
                                focusModel: _amountFocusModel,
                                assets: assets,
                                assetFrom: assetFrom,
                                onSelect: (String asset) {
                                  setState(() => {assetFrom = asset});
                                },
                                onChanged: (value) {
                                  if (isFailed) {
                                    setState(() {
                                      isFailed = false;
                                    });
                                  }
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
                                onPressedHalf: () {
                                  setState(() {
                                    int balance = state
                                        .activeAccount!.balanceList!
                                        .firstWhere((el) =>
                                            el.token! == assetFrom &&
                                            !el.isHidden!)
                                        .balance!;
                                    final int fee = 3000;
                                    double amount =
                                        (convertFromSatoshi(balance - fee) / 2);
                                    _amountController.text = amount.toString();
                                  });
                                },
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
                          callback: () {
                            hideOverlay();
                            Navigator.of(context).pop();
                          },
                        ),
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
                                        SendStakingRewardsScreen(),
                                transitionDuration: Duration.zero,
                                reverseTransitionDuration: Duration.zero,
                              ),
                            );
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
}
