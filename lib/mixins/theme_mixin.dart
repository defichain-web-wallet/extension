import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:flutter/material.dart';

mixin ThemeMixin {
  final SettingsHelper settingsHelper = SettingsHelper();

  bool isDarkTheme() => SettingsHelper.settings.theme == 'Dark';

  bool isFullScreen(BuildContext context) {
    return MediaQuery.of(context).size.width > ScreenSizes.medium;
  }
}
