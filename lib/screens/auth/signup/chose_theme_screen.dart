import 'package:defi_wallet/bloc/theme/theme_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/models/settings_model.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/buttons/new_primary_button.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/selectors/selector_theme_element.dart';
import 'package:defi_wallet/widgets/toolbar/welcome_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChoseThemeScreen extends StatefulWidget {
  final Function()? callback;

  const ChoseThemeScreen({
    Key? key,
    this.callback,
  }) : super(key: key);

  @override
  State<ChoseThemeScreen> createState() => _ChoseThemeScreenState();
}

class _ChoseThemeScreenState extends State<ChoseThemeScreen> {
  bool isLight = true;
  bool isDark = false;
  SettingsHelper settingsHelper = SettingsHelper();

  @override
  void initState() {
    if (SettingsHelper.settings.theme == 'Light') {
      isLight = true;
      isDark = false;
    }
    if (SettingsHelper.settings.theme == 'Dark') {
      isLight = false;
      isDark = true;
    }
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldWrapper(
      builder: (
        BuildContext context,
        bool isFullScreen,
        TransactionState txState,
      ) {
        return Scaffold(
          appBar: WelcomeAppBar(
            progress: 1,
          ),
          body: Container(
            padding: authPaddingContainer,
            child: Center(
              child: StretchBox(
                child: Column(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            height: 34,
                            child: Text(
                              'Choose theme',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 26,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Container(
                            width: 328,
                            height: 42,
                            child: Text(
                              'You will always have possibility to change theme in extension',
                              textAlign: TextAlign.center,
                              style:
                                  Theme.of(context).textTheme.headline5!.apply(
                                        color: Theme.of(context)
                                            .textTheme
                                            .headline5!
                                            .color!
                                            .withOpacity(0.6),
                                      ),
                            ),
                          ),
                          SizedBox(
                            height: 24,
                          ),
                          SelectorThemeElement(
                            text: 'Light theme',
                            isSelected: isLight,
                            callback: () {
                              setState(() {
                                isLight = true;
                                isDark = false;
                              });
                              changeTheme('Light');
                            },
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          SelectorThemeElement(
                            text: 'Dark theme',
                            isSelected: isDark,
                            callback: () {
                              setState(() {
                                isLight = false;
                                isDark = true;
                              });
                              changeTheme('Dark');
                            },
                          ),
                        ],
                      ),
                    ),
                    NewPrimaryButton(
                      callback: widget.callback,
                      width: 280,
                      title: 'Continue',
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  changeTheme(String themeName) {
    SettingsModel localSettings = SettingsHelper.settings.clone();
    localSettings.theme = themeName;
    SettingsHelper.settings = localSettings;
    settingsHelper.saveSettings();
    ThemeCubit themeCubit = BlocProvider.of<ThemeCubit>(context);
    themeCubit.changeTheme();
  }
}
