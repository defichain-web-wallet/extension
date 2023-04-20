import 'dart:ui';

import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/lock/lock_cubit.dart';
import 'package:defi_wallet/mixins/dialog_mixin.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/models/token_model.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/add_token/token_list_tile.dart';
import 'package:defi_wallet/widgets/buttons/accent_button.dart';
import 'package:defi_wallet/widgets/buttons/new_primary_button.dart';
import 'package:defi_wallet/widgets/dialogs/staking_add_asset_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ChoosePayoutStrategyDialog extends StatefulWidget {
  final String assetName;

  const ChoosePayoutStrategyDialog({
    Key? key,
    required this.assetName,
  }) : super(key: key);

  @override
  State<ChoosePayoutStrategyDialog> createState() =>
      _ChoosePayoutStrategyDialogState();
}

class _ChoosePayoutStrategyDialogState extends State<ChoosePayoutStrategyDialog>
    with ThemeMixin, DialogMixin {
  String titleText = 'Choose a payout strategy';
  String subtitleText = 'Payout asset: ';
  String currentAddress = '';
  String currentLabel = '';

  @override
  Widget build(BuildContext dialogContext) {
    LockCubit lockCubit = BlocProvider.of<LockCubit>(dialogContext);

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0),
      child: AlertDialog(
        backgroundColor: isDarkTheme()
            ? DarkColors.drawerBgColor
            : LightColors.drawerBgColor,
        insetPadding: EdgeInsets.all(24),
        shape: RoundedRectangleBorder(
          side: isDarkTheme()
              ? BorderSide(color: DarkColors.drawerBorderColor)
              : BorderSide.none,
          borderRadius: BorderRadius.circular(20),
        ),
        actionsPadding: EdgeInsets.only(
          bottom: 24,
          right: 14,
          left: 14,
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 104,
                child: AccentButton(
                  callback: () {
                    Navigator.pop(dialogContext);
                  },
                  label: 'Cancel',
                ),
              ),
              NewPrimaryButton(
                width: 104,
                title: 'Confirm',
                callback: () {
                  Navigator.pop(dialogContext);
                  if (currentAddress == 'other_address') {
                    showAppDialog(
                      StakingAddAssetDialog(
                        assetName: widget.assetName,
                      ),
                      dialogContext,
                    );
                  } else {
                    lockCubit.updateLockRewardNewRoute(
                      address: currentAddress,
                      label: currentLabel,
                      isComplete: true
                    );
                  }
                },
              ),
            ],
          ),
        ],
        contentPadding: EdgeInsets.only(
          top: 16,
          bottom: 0,
          left: 16,
          right: 16,
        ),
        content: Stack(
          children: [
            Container(
              width: 312,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    child: Text(
                      titleText,
                      style: Theme.of(context).textTheme.headline2!.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).textTheme.headline5!.color),
                      softWrap: true,
                    ),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Text(
                    subtitleText + tokenHelper.getTokenFormat(widget.assetName),
                    style: Theme.of(context).textTheme.headline4!.copyWith(
                        fontSize: 16,
                        color: Theme.of(context).textTheme.headline5!.color),
                    softWrap: true,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 41,
                          ),
                          Text(
                            'Reinvest',
                            style:
                                Theme.of(context).textTheme.headline5!.copyWith(
                                      fontSize: 12,
                                      color: Theme.of(context)
                                          .textTheme
                                          .headline5!
                                          .color!
                                          .withOpacity(0.3),
                                    ),
                            softWrap: true,
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          TokenListTile(
                            isSingleSelect: true,
                            isSelect: currentAddress == lockCubit.state.lockStakingDetails!.depositAddress!,
                            tokenName: '',
                            isDense: true,
                            availableTokenName: '',
                            onTap: () {
                              setState(() {
                                currentAddress = lockCubit.state.lockStakingDetails!.depositAddress!;
                              });
                            },
                            customContent: Row(
                              children: [
                                SizedBox(
                                  width: 16,
                                ),
                                SvgPicture.asset('assets/icons/yield_icon.svg'),
                                SizedBox(
                                  width: 8,
                                ),
                                Text(
                                  'Yield Machine',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline5!
                                      .copyWith(
                                        fontSize: 16,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Text(
                            'Payout',
                            style:
                                Theme.of(context).textTheme.headline5!.copyWith(
                                      fontSize: 12,
                                      color: Theme.of(context)
                                          .textTheme
                                          .headline5!
                                          .color!
                                          .withOpacity(0.3),
                                    ),
                            softWrap: true,
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          BlocBuilder<AccountCubit, AccountState>(
                            builder: (context, state) {
                              return Column(
                                children: List.generate(
                                  state.accounts!.length + 1,
                                      (index) {
                                    if (index < state.accounts!.length)
                                      return Column(
                                        children: [
                                          TokenListTile(
                                            isSingleSelect: true,
                                            isSelect:
                                            currentAddress == state.accounts![index].addressList![0].address,
                                            tokenName: '',
                                            availableTokenName: '',
                                            onTap: () {
                                              setState(() {
                                                currentLabel = state.accounts![index].name!;
                                                currentAddress = state.accounts![index].addressList![0].address!;
                                              });
                                            },
                                            customContent: Row(
                                              children: [
                                                SizedBox(
                                                  width: 16,
                                                ),
                                                Container(
                                                  width: 25,
                                                  height: 25,
                                                  padding: const EdgeInsets.all(4),
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: AppTheme.iconButtonBackground,
                                                  ),
                                                  child: SvgPicture.asset(
                                                    'assets/icons/account_icon.svg',
                                                    width: 25 / 2,
                                                    height: 25 / 2,
                                                    color: isDarkTheme()
                                                        ? Colors.white
                                                        : null,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 8,
                                                ),
                                                Text(
                                                  state.accounts![index].name!,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headline5!
                                                      .copyWith(
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height: 8,
                                          ),
                                        ],
                                      );
                                    else
                                      return Column(
                                        children: [
                                          TokenListTile(
                                            isSingleSelect: true,
                                            isSelect: currentAddress == 'other_address',
                                            tokenName: '',
                                            availableTokenName: '',
                                            onTap: () {
                                              setState(() {
                                                currentAddress = 'other_address';
                                              });
                                            },
                                            customContent: Row(
                                              children: [
                                                SizedBox(
                                                  width: 16,
                                                ),
                                                Container(
                                                  width: 25,
                                                  height: 25,
                                                  padding: const EdgeInsets.all(4),
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: AppTheme.iconButtonBackground,
                                                  ),
                                                  child: SvgPicture.asset(
                                                    'assets/icons/account_icon.svg',
                                                    width: 25 / 2,
                                                    height: 25 / 2,
                                                    color: isDarkTheme()
                                                        ? Colors.white
                                                        : null,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 8,
                                                ),
                                                Text(
                                                  'Other DeFiChain address',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headline5!
                                                      .copyWith(
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height: 8,
                                          ),
                                        ],
                                      );
                                  },
                                ),
                              );
                            }
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(dialogContext);
                    },
                    child: Icon(
                      Icons.close,
                      size: 16,
                      color: Theme.of(context).dividerColor.withOpacity(0.5),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
