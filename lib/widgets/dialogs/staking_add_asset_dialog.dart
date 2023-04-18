import 'dart:ui';

import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/buttons/accent_button.dart';
import 'package:defi_wallet/widgets/buttons/new_action_button.dart';
import 'package:defi_wallet/widgets/buttons/new_primary_button.dart';
import 'package:defi_wallet/widgets/defi_checkbox.dart';
import 'package:defi_wallet/widgets/fields/input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class StakingAddAssetDialog extends StatefulWidget {
  const StakingAddAssetDialog({Key? key}) : super(key: key);

  @override
  State<StakingAddAssetDialog> createState() => _StakingAddAssetDialogState();
}

class _StakingAddAssetDialogState extends State<StakingAddAssetDialog>
    with ThemeMixin {
  TextEditingController addressController = TextEditingController();
  TextEditingController labelController = TextEditingController();
  FocusNode checkBoxFocusNode = FocusNode();
  final String titleText = 'Add your payout asset';
  final String warningText = 'Please provide an alternate payout address '
      'if you would like to receive your rewards there.';
  bool isPayout = false;

  @override
  Widget build(BuildContext context) {
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
        actionsPadding: EdgeInsets.symmetric(
          vertical: 24,
          horizontal: 14,
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              height: 305,
              child: Stack(
                children: [
                  Container(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          titleText,
                          style: Theme.of(context)
                              .textTheme
                              .headline2!
                              .copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: Theme.of(context)
                                      .textTheme
                                      .headline5!
                                      .color),
                          softWrap: true,
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        Container(
                          height: 56,
                          width: double.infinity,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.8),
                              border: Border.all(
                                color: Theme.of(context)
                                    .inputDecorationTheme
                                    .enabledBorder!
                                    .borderSide
                                    .color,
                              ),
                              color: Theme.of(context)
                                  .inputDecorationTheme
                                  .fillColor!),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 19,
                              ),
                              SvgPicture.asset(
                                'assets/tokens/defi.svg',
                                width: 24,
                                height: 24,
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              Text(
                                'DFI - DeFiChain',
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
                          height: 16,
                        ),
                        Container(
                          padding: EdgeInsets.all(16),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: AppColors.portageBg.withOpacity(0.07),
                          ),
                          child: Column(
                            children: [
                              InputField(
                                controller: labelController,
                                hintText: 'Label: e.g. Wifes wallet',
                                suffix: Padding(
                                  padding: EdgeInsets.only(right: 16),
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        labelController.text = '';
                                      });
                                    },
                                    child: MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: SvgPicture.asset(
                                        'assets/icons/delete_text_input.svg',
                                        color: Theme.of(context)
                                            .textTheme
                                            .headline5!
                                            .color!
                                            .withOpacity(0.2),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              InputField(
                                controller: addressController,
                                hintText: 'Address: e.g.: df1qx5hraps.....',
                                suffix: Padding(
                                  padding: EdgeInsets.only(right: 16),
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        addressController.text = '';
                                      });
                                    },
                                    child: MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: SvgPicture.asset(
                                        'assets/icons/delete_text_input.svg',
                                        color: Theme.of(context)
                                            .textTheme
                                            .headline5!
                                            .color!
                                            .withOpacity(0.2),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
                      Navigator.pop(context);
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
