import 'package:flutter/material.dart';
import 'package:defi_wallet/bloc/theme/theme_cubit.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/models/settings_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ThemeManager {
  static SettingsHelper settingsHelper = SettingsHelper();

  static void changeTheme(BuildContext context) {
    SettingsModel localSettings = SettingsHelper.settings.clone();
    String themeName = localSettings.theme == 'Light' ? 'Dark' : 'Light';

    localSettings.theme = themeName;
    SettingsHelper.settings = localSettings;
    settingsHelper.saveSettings();

    ThemeCubit themeCubit = BlocProvider.of<ThemeCubit>(context);
    themeCubit.changeTheme();
  }
}