import 'package:defi_wallet/helpers/settings_helper.dart';

mixin ThemeMixin {
  SettingsHelper settingsHelper = SettingsHelper();

  bool isDarkTheme() => SettingsHelper.settings.theme == 'Dark';
}
