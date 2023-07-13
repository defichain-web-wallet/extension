import 'dart:ui';

import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/buttons/new_primary_button.dart';
import 'package:flutter/material.dart';

class RestoreWalletDialog extends StatefulWidget {
  final Function() callbackOk;

  const RestoreWalletDialog({
    Key? key,
    required this.callbackOk,
  }) : super(key: key);

  @override
  State<RestoreWalletDialog> createState() => _RestoreWalletDialogState();
}

class _RestoreWalletDialogState extends State<RestoreWalletDialog> with ThemeMixin {
  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0),
      child: AlertDialog(
        insetPadding: EdgeInsets.all(24),
        elevation: 48.0,
        backgroundColor: isDarkTheme()
            ? DarkColors.drawerBgColor
            : LightColors.drawerBgColor,
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
          Center(
            child: NewPrimaryButton(
              width: buttonSmallWidth,
              callback: () {
                Navigator.pop(context);
                widget.callbackOk();
              },
              title: 'Continue',
            ),
          ),
        ],
        contentPadding: EdgeInsets.only(
          top: 16,
          bottom: 0,
          left: 16,
          right: 16,
        ),
        content: Container(
          height: 220,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'Important Update',
                  style: Theme.of(context)
                      .textTheme
                      .headline2!
                      .copyWith(
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context)
                          .textTheme
                          .headline5!
                          .color),
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
              SizedBox(
                height: 16,
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: 350,
                  child: Text(
                    'We have recently implemented a major update that requires your data to be stored in a new format. Please note that this process does not expose or access your private key in any manner. Jellywallet ensures the encryption of your keys locally on your device, with no external access. To proceed,  click on the “Continue” button.” This process may take a while. Please don’t close Jellywallet',
                    textAlign: TextAlign.justify,
                    style: Theme.of(context).textTheme.headline5!.copyWith(
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
