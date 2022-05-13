import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FullSizeIcon extends StatelessWidget {
  final String lightIconPath = 'assets/open_in_full_icon_light.svg';
  final String darkIconPath = 'assets/open_in_full_icon.svg';
  final double iconWidth = 24;

  @override
  Widget build(BuildContext context) {
    String _iconPath;
    if (SettingsHelper.settings.theme == 'Auto') {
      _iconPath = MediaQuery.of(context).platformBrightness == Brightness.dark
          ? lightIconPath
          : darkIconPath;
    } else {
      _iconPath = SettingsHelper.settings.theme == 'Light'
          ? darkIconPath
          : lightIconPath;
    }
    return SvgPicture.asset(
      _iconPath,
      color: Theme.of(context).appBarTheme.actionsIconTheme!.color,
      width: iconWidth,
    );
  }
}