import 'dart:ui';

import 'package:defi_wallet/mixins/dialog_mixin.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/screens/tokens/widgets/search_field.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/add_token/token_list_tile.dart';
import 'package:defi_wallet/widgets/buttons/accent_button.dart';
import 'package:defi_wallet/widgets/buttons/new_primary_button.dart';
import 'package:defi_wallet/widgets/dialogs/choose_payout_strategy_dialog.dart';
import 'package:defi_wallet/widgets/fields/custom_text_form_field.dart';
import 'package:defi_wallet/widgets/selectors/custom_select_tile.dart';
import 'package:defi_wallet/widgets/selectors/selector_tab_element.dart';
import 'package:flutter/material.dart';

class SelectPayoutAssetDialog extends StatefulWidget {
  const SelectPayoutAssetDialog({Key? key}) : super(key: key);

  @override
  State<SelectPayoutAssetDialog> createState() =>
      _SelectPayoutAssetDialogState();
}

class _SelectPayoutAssetDialogState extends State<SelectPayoutAssetDialog>
    with ThemeMixin, DialogMixin {
  String titleText = 'Select your payout asset';
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
            ? DarkColors.scaffoldContainerBgColor
            : LightColors.scaffoldContainerBgColor,
        insetPadding: EdgeInsets.all(24),
        shape: RoundedRectangleBorder(
          side: BorderSide.none,
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
                  jellyDialog(ChoosePayoutStrategyDialog(), context);
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
                    width: 200,
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
                  Row(
                    children: [
                      SizedBox(
                        width: 8,
                      ),
                      SelectorTabElement(
                        callback: () {
                          setState(() {
                            isFirstTab = true;
                            isSecondTab = false;
                            isThirdTab = false;
                          });
                        },
                        title: 'Crypto assets',
                        isSelect: isFirstTab,
                      ),
                      SizedBox(
                        width: 24,
                      ),
                      SelectorTabElement(
                        callback: () {
                          setState(() {
                            isFirstTab = false;
                            isSecondTab = true;
                            isThirdTab = false;
                          });
                        },
                        isSelect: isSecondTab,
                        title: 'dTokens',
                      ),
                      SizedBox(
                        width: 24,
                      ),
                      SelectorTabElement(
                        callback: () {
                          setState(() {
                            isFirstTab = false;
                            isSecondTab = false;
                            isThirdTab = true;
                          });
                        },
                        isSelect: isThirdTab,
                        title: 'LP Tokens',
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  CustomTextFormField(
                    prefix: Icon(Icons.search),
                    addressController: searchController,
                    hintText: 'Search Token',
                    isBorder: true,
                    onChanged: (value) {},
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  if (isFirstTab)
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        child: ListView.builder(
                          itemCount: 10,
                          itemBuilder: (BuildContext context, int index) {
                            return Column(
                              children: [
                                TokenListTile(
                                  isSingleSelect: true,
                                  isSelect: index == selectIndex,
                                  tokenName: 'DFI',
                                  availableTokenName: 'DFI test name',
                                  onTap: () {
                                    setState(() {
                                      selectIndex = index;
                                    });
                                  },
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                              ],
                            );
                          },
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
