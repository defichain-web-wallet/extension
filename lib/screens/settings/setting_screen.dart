import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/mixins/dialog_mixin.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/screens/settings/setting_language_screen.dart';
import 'package:defi_wallet/screens/settings/setting_recovery_seed_screen.dart';
import 'package:defi_wallet/services/mnemonic_service.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/account_drawer/account_drawer.dart';
import 'package:defi_wallet/widgets/dialogs/staking_add_asset_dialog.dart';
import 'package:defi_wallet/widgets/fields/custom_text_form_field.dart';
import 'package:defi_wallet/widgets/dialogs/pass_confirm_dialog.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/settings/settings_list_tile.dart';
import 'package:defi_wallet/widgets/toolbar/new_main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> with ThemeMixin, DialogMixin {
  TextEditingController searchController = TextEditingController();
  String titleText = 'Settings';

  @override
  Widget build(BuildContext context) {
    return ScaffoldWrapper(
      builder: (
        BuildContext context,
        bool isFullScreen,
        TransactionState txState,
      ) {
        return BlocBuilder<AccountCubit, AccountState>(
          builder: (context, state) {
            return Scaffold(
              drawerScrimColor: AppColors.tolopea.withOpacity(0.06),
              endDrawer: AccountDrawer(
                width: buttonSmallWidth,
              ),
              appBar: NewMainAppBar(
                isShowLogo: false,
              ),
              body: Container(
                padding: EdgeInsets.only(
                  top: 22,
                  bottom: 24,
                  left: 16,
                  right: 16,
                ),
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: isDarkTheme()
                      ? DarkColors.drawerBgColor
                      : LightColors.scaffoldContainerBgColor,
                  border: isDarkTheme()
                      ? Border.all(
                          width: 1.0,
                          color: Colors.white.withOpacity(0.05),
                        )
                      : null,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20),
                    topLeft: Radius.circular(20),
                  ),
                ),
                child: Center(
                  child: StretchBox(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  titleText,
                                  style: headline2.copyWith(
                                      fontWeight: FontWeight.w700),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            Column(
                              children: [
                                SettingsListTile(
                                  titleText: 'Recovery seed',
                                  subtitleText: 'Click to show recovery seed',
                                  onTap: () {
                                    showDialog(
                                      barrierColor: AppColors.tolopea.withOpacity(0.06),
                                      barrierDismissible: false,
                                      context: context,
                                      builder: (BuildContext contextDialog) {
                                        return PassConfirmDialog(
                                          onSubmit: (val) async {
                                            var mnemonic =
                                                await getMnemonic(val);
                                            Navigator.pushReplacement(
                                              context,
                                              PageRouteBuilder(
                                                pageBuilder: (context,
                                                        animation1,
                                                        animation2) =>
                                                    SettingRecoverySeedScreen(
                                                  mnemonic: mnemonic,
                                                ),
                                                transitionDuration:
                                                    Duration.zero,
                                                reverseTransitionDuration:
                                                    Duration.zero,
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    );
                                  },
                                ),
                                Divider(
                                  height: 28,
                                  color: Theme.of(context)
                                      .dividerColor
                                      .withOpacity(0.16),
                                ),
                                SettingsListTile(
                                  isComingSoon: true,
                                  titleText: 'Language',
                                  subtitleText:
                                      'Click to choose your main language',
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder:
                                            (context, animation1, animation2) =>
                                                SettingLanguageScreen(),
                                        transitionDuration: Duration.zero,
                                        reverseTransitionDuration:
                                            Duration.zero,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
