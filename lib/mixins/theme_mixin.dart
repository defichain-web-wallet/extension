import 'package:defi_wallet/helpers/settings_helper.dart';

mixin ThemeMixin {
  final SettingsHelper settingsHelper = SettingsHelper();

  bool isDarkTheme() => SettingsHelper.settings.theme == 'Dark';
}
