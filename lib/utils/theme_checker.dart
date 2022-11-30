import 'package:defi_wallet/bloc/theme/theme_cubit.dart';
import 'package:defi_wallet/bloc/theme/theme_state.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
// import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ThemeChecker extends StatefulWidget {
  final Widget screen;

  const ThemeChecker(this.screen, {Key? key}) : super(key: key);

  @override
  _ThemeCheckerState createState() => _ThemeCheckerState();
}

class _ThemeCheckerState extends State<ThemeChecker> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(builder: (context, state) {
      var theme = MediaQuery.of(context).platformBrightness;
      ThemeMode currentTheme;
      if (SettingsHelper.settings.theme == 'Auto') {
        currentTheme =
            theme == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
      } else {
        currentTheme = SettingsHelper.settings.theme == 'Dark'
            ? ThemeMode.dark
            : ThemeMode.light;
      }
      return MaterialApp(
        theme: createLightTheme(),
        darkTheme: createDarkTheme(),
        themeMode: currentTheme,
        debugShowCheckedModeBanner: false,
        home: widget.screen,
      );
    });
  }
}
