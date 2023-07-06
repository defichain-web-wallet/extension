import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:flutter/material.dart';

mixin ThemeMixin {
  final SettingsHelper settingsHelper = SettingsHelper();

  bool isDarkTheme() => SettingsHelper.settings.theme == 'Dark';

  bool isFullScreen(BuildContext context) {
    return MediaQuery.of(context).size.width > ScreenSizes.medium;
  }

  bool isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width > ScreenSizes.large - 1;
  }

  bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width > ScreenSizes.small - 1;
  }
}
