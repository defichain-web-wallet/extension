import 'dart:ui';

import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/screens/tokens/widgets/search_field.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/add_token/token_list_tile.dart';
import 'package:defi_wallet/widgets/buttons/accent_button.dart';
import 'package:defi_wallet/widgets/buttons/new_primary_button.dart';
import 'package:defi_wallet/widgets/fields/custom_text_form_field.dart';
import 'package:defi_wallet/widgets/selectors/custom_select_tile.dart';
import 'package:defi_wallet/widgets/selectors/selector_tab_element.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ChoosePayoutStrategyDialog extends StatefulWidget {
  const ChoosePayoutStrategyDialog({Key? key}) : super(key: key);

  @override
  State<ChoosePayoutStrategyDialog> createState() =>
      _ChoosePayoutStrategyDialogState();
}

class _ChoosePayoutStrategyDialogState extends State<ChoosePayoutStrategyDialog>
    with ThemeMixin {
  String titleText = 'Choose a payout strategy';
  String subtitleText = 'Payout asset: dUSD';
  String currentInvest = 'yield_reinvest';
  bool isFirstTab = true;
  bool isSecondTab = false;
  bool isThirdTab = false;
  int selectIndex = 0;
  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext dialogContext) {
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
                callback: () {},
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
                    subtitleText,
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
                            isSelect: currentInvest == 'yield_reinvest',
                            tokenName: '',
                            availableTokenName: '',
                            onTap: () {
                              setState(() {
                                currentInvest = 'yield_reinvest';
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
                          Column(
                            children: List.generate(
                              10,
                              (index) {
                                if (index < 9)
                                  return Column(
                                    children: [
                                      TokenListTile(
                                        isSingleSelect: true,
                                        isSelect:
                                            currentInvest == 'account_$index',
                                        tokenName: '',
                                        availableTokenName: '',
                                        onTap: () {
                                          setState(() {
                                            currentInvest = 'account_$index';
                                          });
                                        },
                                        customContent: Row(
                                          children: [
                                            SizedBox(
                                              width: 16,
                                            ),
                                            SvgPicture.asset(
                                                'assets/icons/yield_icon.svg'),
                                            SizedBox(
                                              width: 8,
                                            ),
                                            Text(
                                              'Account ${index + 1}',
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
                                        isSelect:
                                            currentInvest == 'other_address',
                                        tokenName: '',
                                        availableTokenName: '',
                                        onTap: () {
                                          setState(() {
                                            currentInvest = 'other_address';
                                          });
                                        },
                                        customContent: Row(
                                          children: [
                                            SizedBox(
                                              width: 16,
                                            ),
                                            SvgPicture.asset(
                                                'assets/icons/yield_icon.svg'),
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
