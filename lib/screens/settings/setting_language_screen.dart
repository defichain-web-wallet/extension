import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/account_drawer/account_drawer.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/toolbar/new_main_app_bar.dart';
import 'package:flutter/material.dart';

class SettingLanguageScreen extends StatefulWidget {
  const SettingLanguageScreen({Key? key}) : super(key: key);

  @override
  State<SettingLanguageScreen> createState() => _SettingLanguageScreenState();
}

class _SettingLanguageScreenState extends State<SettingLanguageScreen> with ThemeMixin{
  String titleText = 'Language';
  @override
  Widget build(BuildContext context) {
    return ScaffoldWrapper(
      builder: (
          BuildContext context,
          bool isFullScreen,
          TransactionState txState,
          ) {
            return Scaffold(
              drawerScrimColor: Color(0x0f180245),
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
                      ? DarkColors.scaffoldContainerBgColor
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
                              height: 8,
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
  }
}
