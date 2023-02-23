import 'package:defi_wallet/bloc/theme/theme_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/models/settings_model.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/buttons/restore_button.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/selectors/circle_selector_tile.dart';
import 'package:defi_wallet/widgets/toolbar/welcome_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignupChooseThemeScreen extends StatefulWidget {
  final Function() callback;

  const SignupChooseThemeScreen({
    Key? key,
    required this.callback,
  }) : super(key: key);

  @override
  State<SignupChooseThemeScreen> createState() =>
      _SignupChooseThemeScreenState();
}

class _SignupChooseThemeScreenState extends State<SignupChooseThemeScreen> {
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
            padding: authPaddingContainer.copyWith(
              left: 16,
              right: 16,
            ),
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
                              style: headline3,
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Container(
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
                          CircleSelectorTile(
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
                          CircleSelectorTile(
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
                    Container(
                      width: buttonSmallWidth,
                      child: PendingButton(
                        'Continue',
                        pendingText: 'Processing...',
                        isCheckLock: false,
                        callback: (parent) async {
                          parent.emitPending(true);
                          await widget.callback();
                          // parent.emitPending(false);
                        },
                      ),
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
