import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/theme/theme_cubit.dart';
import 'package:defi_wallet/bloc/tokens/tokens_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_bloc.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/models/settings_model.dart';
import 'package:defi_wallet/widgets/buttons/accent_button.dart';
import 'package:defi_wallet/widgets/buttons/primary_button.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_constrained_box.dart';
import 'package:defi_wallet/widgets/toolbar/main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/helpers/logo_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:defi_wallet/widgets/loader/loader.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final LogoHelper logoHelper = LogoHelper();
  final SettingsHelper settingsHelper = SettingsHelper();
  late SettingsModel localSettings;
  bool isEnable = true;
  bool isPending = false;
  double toolbarHeight = 55;
  double toolbarHeightWithBottom = 105;

  @override
  void initState() {
    super.initState();
    localSettings = SettingsHelper.settings.clone();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionCubit, TransactionState>(
      builder: (context, state) => ScaffoldConstrainedBox(
          child: LayoutBuilder(builder: (context, constraints) {
            if (constraints.maxWidth < ScreenSizes.medium) {
              return Scaffold(
                appBar: MainAppBar(
                    title: 'Settings',
                    isShowBottom: !(state is TransactionInitialState),
                    height: !(state is TransactionInitialState)
                        ? toolbarHeightWithBottom
                        : toolbarHeight
                ),
                body: _buildBody(context),
              );
            } else {
              return Container(
                padding: const EdgeInsets.only(top: 20),
                child: Scaffold(
                  appBar: MainAppBar(
                    title: 'Settings',
                    isShowBottom: !(state is TransactionInitialState),
                    height: !(state is TransactionInitialState)
                        ? toolbarHeightWithBottom
                        : toolbarHeight,
                    isSmall: true,
                  ),
                  body: _buildBody(context, isCustomBgColor: true),
                ),
              );
            }
          })
      )
    );
  }

  Widget _buildBody(context, {isCustomBgColor = false}) {
    return BlocBuilder<AccountCubit, AccountState>(
      builder: (context, state) {
        if (state.status == AccountStatusList.success) {
          return Container(
            color: isCustomBgColor ? Theme.of(context).dialogBackgroundColor : null,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Center(
              child: StretchBox(
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Column(
                            children: [
                              Text('Currency'),
                              ListTile(
                                title: SettingsLabel(
                                  label: 'USD',
                                  callback: () {
                                    setState(() {
                                      localSettings.currency = 'USD';
                                    });
                                  },
                                ),
                                leading: Radio<String>(
                                  value: 'USD',
                                  groupValue: localSettings.currency,
                                  onChanged: (value) {
                                    setState(() {
                                      localSettings.currency = value;
                                    });
                                  },
                                  activeColor: Color(0xFFFF00A3),
                                ),
                              ),
                              ListTile(
                                title: SettingsLabel(
                                  label: 'EUR',
                                  callback: () {
                                    setState(() {
                                      localSettings.currency = 'EUR';
                                    });
                                  },
                                ),
                                leading: Radio<String>(
                                  value: 'EUR',
                                  groupValue: localSettings.currency,
                                  onChanged: (value) {
                                    setState(() {
                                      localSettings.currency = value;
                                    });
                                  },
                                  activeColor: Color(0xFFFF00A3),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Divider(),
                          ),
                          Column(
                            children: [
                              Text('Theme'),
                              ListTile(
                                title: SettingsLabel(
                                  label: 'Auto',
                                  callback: () {
                                    setState(() {
                                      localSettings.theme = 'Auto';
                                    });
                                  },
                                ),
                                leading: Radio<String>(
                                  value: 'Auto',
                                  groupValue: localSettings.theme,
                                  onChanged: (value) {
                                    setState(() {
                                      localSettings.theme = value;
                                    });
                                  },
                                  activeColor: Color(0xFFFF00A3),
                                ),
                              ),
                              ListTile(
                                title: SettingsLabel(
                                  label: 'Light',
                                  callback: () {
                                    setState(() {
                                      localSettings.theme = 'Light';
                                    });
                                  },
                                ),
                                leading: Radio<String>(
                                  value: 'Light',
                                  groupValue: localSettings.theme,
                                  onChanged: (value) {
                                    setState(() {
                                      localSettings.theme = value;
                                    });
                                  },
                                  activeColor: Color(0xFFFF00A3),
                                ),
                              ),
                              ListTile(
                                title: SettingsLabel(
                                  label: 'Dark',
                                  callback: () {
                                    setState(() {
                                      localSettings.theme = 'Dark';
                                    });
                                  },
                                ),
                                leading: Radio<String>(
                                  value: 'Dark',
                                  groupValue: localSettings.theme,
                                  onChanged: (value) {
                                    setState(() {
                                      localSettings.theme = value;
                                    });
                                  },
                                  activeColor: Color(0xFFFF00A3),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Divider(),
                          ),
                          Column(
                            children: [
                              Text('Network'),
                              ListTile(
                                title: SettingsLabel(
                                  label: 'Testnet',
                                  callback: () {
                                    setState(() {
                                      localSettings.network = 'testnet';
                                    });
                                  },
                                ),
                                leading: Radio<String>(
                                  value: 'testnet',
                                  groupValue: localSettings.network,
                                  onChanged: (value) {
                                    setState(() {
                                      localSettings.network = value;
                                    });
                                  },
                                  activeColor: Color(0xFFFF00A3),
                                ),
                              ),
                              ListTile(
                                title: SettingsLabel(
                                  label: 'Mainnet',
                                  callback: () {
                                    setState(() {
                                      localSettings.network = 'mainnet';
                                    });
                                  },
                                ),
                                leading: Radio<String>(
                                  value: 'mainnet',
                                  groupValue: localSettings.network,
                                  onChanged: (value) {
                                    setState(() {
                                      localSettings.network = value;
                                    });
                                  },
                                  activeColor: Color(0xFFFF00A3),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Container(
                                height: 50,
                                child: AccentButton(
                                  label: 'Cancel',
                                  callback: isEnable ? () => Navigator.of(context).pop() : null,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                            ),
                            Expanded(
                              child: Container(
                                height: 50,
                                child: PrimaryButton(
                                  label: isPending ? 'Pending...' : 'Save',
                                    isCheckLock: false,
                                    callback: !SettingsHelper.settings.compare(localSettings)
                                        ? () async {
                                      setState(() {
                                        isEnable = false;
                                      });
                                      SettingsHelper.settings = localSettings;
                                      settingsHelper.saveSettings();
                                      ThemeCubit themeCubit = BlocProvider.of<ThemeCubit>(context);
                                      AccountCubit accountCubit = BlocProvider.of<AccountCubit>(context);
                                      TokensCubit tokensCubit = BlocProvider.of<TokensCubit>(context);
                                      themeCubit.changeTheme();
                                      setState(() { isPending = true;});
                                      await accountCubit.changeNetwork(
                                        localSettings.network!,
                                      );
                                      tokensCubit.loadTokensFromStorage();
                                      Navigator.of(context).pop();
                                    } : null
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              )
            ),
          );
        } else {
          return Loader();
        }
      }
    );
  }
}

class SettingsLabel extends StatelessWidget {
  final String? label;
  final Function()? callback;

  const SettingsLabel({Key? key, this.label, this.callback}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      hoverColor: Colors.transparent,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Text(label!, style: TextStyle(fontSize: 16)),
      onTap: callback,
    );
  }
}
