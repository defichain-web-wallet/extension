import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/theme/theme_cubit.dart';
import 'package:defi_wallet/bloc/tokens/tokens_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_bloc.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/models/settings_model.dart';
import 'package:defi_wallet/screens/auth_screen/lock_screen.dart';
import 'package:defi_wallet/screens/settings/preview_seed.dart';
import 'package:defi_wallet/widgets/buttons/accent_button.dart';
import 'package:defi_wallet/widgets/buttons/primary_button.dart';
import 'package:defi_wallet/widgets/modal_dialog.dart';
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
  bool isShowWarning = true;
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
                          : toolbarHeight),
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
            })));
  }

  Widget _buildBody(context, {isCustomBgColor = false}) {
    return BlocBuilder<AccountCubit, AccountState>(builder: (context, state) {
      if (state.status == AccountStatusList.success ||
          state.status == AccountStatusList.failure) {
        AccountState accountCubit =
            BlocProvider.of<AccountCubit>(context).state;
        return Container(
          color:
              isCustomBgColor ? Theme.of(context).dialogBackgroundColor : null,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Center(
              child: StretchBox(
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Container(
                        child: Column(
                          children: [
                            Column(
                              children: [
                                Text('Seed'),
                                SizedBox(
                                  height: 6,
                                ),
                                if (accountCubit.mnemonic!.length > 0)
                                  ListTile(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                          pageBuilder: (context, animation1,
                                                  animation2) =>
                                              LockScreen(
                                            redirectTo: PreviewSeed(
                                              mnemonic: accountCubit.mnemonic!,
                                            ),
                                          ),
                                          transitionDuration: Duration.zero,
                                          reverseTransitionDuration:
                                              Duration.zero,
                                        ),
                                      );
                                    },
                                    title: Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: Text(
                                        'Recovery seed',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline3,
                                      ),
                                    ),
                                    subtitle:
                                        Text('Click to show recovery seed'),
                                  )
                                else
                                  Container(
                                    padding: const EdgeInsets.only(top: 12),
                                    child: Text(
                                      'To access this feature, you need to reinstall the wallet.',
                                      style:
                                          Theme.of(context).textTheme.headline4,
                                    ),
                                  ),
                                SizedBox(
                                  height: 6,
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Divider(),
                            ),
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
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Divider(),
                            ),
                            Column(
                              children: [
                                Text('API'),
                                ListTile(
                                  title: SettingsLabel(
                                    label: 'Auto',
                                    hint: '(recommended)',
                                    callback: () {
                                      setState(() {
                                        localSettings.apiName = ApiName.auto;
                                      });
                                    },
                                  ),
                                  leading: Radio<ApiName>(
                                    value: ApiName.auto,
                                    groupValue: localSettings.apiName,
                                    onChanged: (value) {
                                      setState(() {
                                        localSettings.apiName = value;
                                      });
                                    },
                                    activeColor: Color(0xFFFF00A3),
                                  ),
                                ),
                                ListTile(
                                  title: SettingsLabel(
                                    label: 'Ocean',
                                    callback: () {
                                      setState(() {
                                        localSettings.apiName = ApiName.ocean;
                                      });
                                    },
                                  ),
                                  leading: Radio<ApiName>(
                                    value: ApiName.ocean,
                                    groupValue: localSettings.apiName,
                                    onChanged: (value) {
                                      setState(() {
                                        localSettings.apiName = value;
                                      });
                                    },
                                    activeColor: Color(0xFFFF00A3),
                                  ),
                                ),
                                ListTile(
                                  title: SettingsLabel(
                                    label: 'MyDefichain',
                                    callback: () {
                                      setState(() {
                                        localSettings.apiName = ApiName.myDefi;
                                      });
                                    },
                                  ),
                                  leading: Radio<ApiName>(
                                    value: ApiName.myDefi,
                                    groupValue: localSettings.apiName,
                                    onChanged: (value) {
                                      setState(() {
                                        localSettings.apiName = value;
                                      });
                                    },
                                    activeColor: Color(0xFFFF00A3),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
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
                              callback: isEnable
                                  ? () => Navigator.of(context).pop()
                                  : null,
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
                                callback: !SettingsHelper.settings
                                        .compare(localSettings)
                                    ? () {
                                        if (!SettingsHelper.settings
                                                .isCompareApiName(
                                                    localSettings) &&
                                            localSettings.apiName !=
                                                ApiName.auto) {
                                          _showMyDialog();
                                        } else {
                                          submit();
                                        }
                                      }
                                    : null),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          )),
        );
      } else {
        return Loader();
      }
    });
  }

  submit() async {
    setState(() {
      isEnable = false;
    });
    SettingsHelper.settings = localSettings;
    settingsHelper.saveSettings();
    ThemeCubit themeCubit = BlocProvider.of<ThemeCubit>(context);
    AccountCubit accountCubit = BlocProvider.of<AccountCubit>(context);
    TokensCubit tokensCubit = BlocProvider.of<TokensCubit>(context);
    themeCubit.changeTheme();
    setState(() {
      isPending = true;
    });
    await accountCubit.changeNetwork(
      localSettings.network!,
    );
    await tokensCubit.loadTokensFromStorage();
    await tokensCubit.loadTokens();
    Navigator.of(context).pop();
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ModalDialog(
          title: 'Change settings?',
          listBody: <Text>[
            Text('Are you sure you want to change the api?'),
            Text(
                'This can lead to unstable operations of send, swap, history and etc.'),
          ],
          onClose: () {
            print('onClose');
          },
          onSubmit: () {
            submit();
          },
        );
      },
    );
  }
}

class SettingsLabel extends StatelessWidget {
  final String? label;
  final String? hint;
  final Function()? callback;

  const SettingsLabel({
    Key? key,
    this.label,
    this.callback,
    this.hint = '',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      hoverColor: Colors.transparent,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: RichText(
        text: TextSpan(children: [
          TextSpan(
            text: label!,
            style: Theme.of(context).textTheme.headline5,
          ),
          TextSpan(
            text: ' $hint',
            style: Theme.of(context).textTheme.subtitle1!.apply(
                  color: Colors.grey.shade500,
                ),
          ),
        ]),
      ),
      onTap: callback,
    );
  }
}
