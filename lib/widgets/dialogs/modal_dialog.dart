import 'dart:ui';

import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/buttons/accent_button.dart';
import 'package:defi_wallet/widgets/buttons/new_primary_button.dart';
import 'package:flutter/material.dart';

class ModalDialog extends StatelessWidget with ThemeMixin {
  final String title;
  final String message;
  final Function() onClose;
  final Function() onSubmit;

  ModalDialog({
    Key? key,
    required this.title,
    required this.message,
    required this.onClose,
    required this.onSubmit,
  }) : super(key: key);

  final FocusNode confirmFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0),
      child: AlertDialog(
        backgroundColor: isDarkTheme()
            ? DarkColors.drawerBgColor
            : LightColors.drawerBgColor,
        shape: RoundedRectangleBorder(
          side: isDarkTheme()
              ? BorderSide(color: DarkColors.drawerBorderColor)
              : BorderSide.none,
          borderRadius: BorderRadius.circular(20),
        ),
        insetPadding: EdgeInsets.all(24),
        actionsPadding: EdgeInsets.symmetric(
          vertical: 24,
          horizontal: 14,
        ),
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
              height: 112,
              child: Stack(
                children: [
                  Container(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 8,
                        ),
                        Row(
                          children: [
                            Text(
                              title,
                              style: Theme.of(context)
                                  .textTheme
                                  .headline2!
                                  .copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: Theme.of(context)
                                          .textTheme
                                          .headline5!
                                          .color),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                message,
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle1!
                                    .copyWith(
                                      color: Theme.of(context)
                                          .textTheme
                                          .subtitle1!
                                          .color!
                                          .withOpacity(0.6),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                softWrap: true,
                              ),
                            ),
                          ],
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
        actions: <Widget>[
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
                focusNode: confirmFocusNode,
                width: 104,
                title: 'Confirm',
                callback: () {
                  Navigator.pop(context);
                  onSubmit();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
