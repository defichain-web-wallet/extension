import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/screens/settings/setting_screen.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/account_drawer/account_drawer.dart';
import 'package:defi_wallet/widgets/auth/mnemonic_word.dart';
import 'package:defi_wallet/widgets/buttons/new_primary_button.dart';
import 'package:defi_wallet/widgets/common/jelly_link_text.dart';
import 'package:defi_wallet/widgets/common/page_title.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/toolbar/new_main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:reorderables/reorderables.dart';

class SettingRecoverySeedScreen extends StatefulWidget {
  final List<String> mnemonic;

  const SettingRecoverySeedScreen({
    Key? key,
    required this.mnemonic,
  }) : super(key: key);

  @override
  State<SettingRecoverySeedScreen> createState() =>
      _SettingRecoverySeedScreenState();
}

class _SettingRecoverySeedScreenState extends State<SettingRecoverySeedScreen>
    with ThemeMixin {
  String titleText = 'Recovery seed';

  @override
  Widget build(BuildContext context) {
    List<Widget> mnemonicPhrases = List.generate(
      widget.mnemonic.length,
      (index) => MnemonicWord(
        index: index + 1,
        word: widget.mnemonic[index],
      ),
    );
    return ScaffoldWrapper(
      builder: (
        BuildContext context,
        bool isFullScreen,
        TransactionState txState,
      ) {
        return Scaffold(
          drawerScrimColor: AppColors.tolopea.withOpacity(0.06),
          endDrawer: isFullScreen ? null : AccountDrawer(
            width: buttonSmallWidth,
          ),
          appBar: isFullScreen ? null : NewMainAppBar(
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        PageTitle(
                          title: titleText,
                          isFullScreen: isFullScreen,
                        ),
                        SizedBox(
                          height: 32,
                        ),
                        Container(
                          width: 348,
                          child: ReorderableWrap(
                            alignment: WrapAlignment.center,
                            spacing: 6.0,
                            runSpacing: 6.0,
                            enableReorder: false,
                            padding: const EdgeInsets.all(0),
                            onReorder: (int oldIndex, int newIndex) => null,
                            children: mnemonicPhrases,
                          ),
                        ),
                        SizedBox(
                          height: 24,
                        ),
                        Container(
                          child: InkWell(
                            onTap: () async {
                              await Clipboard.setData(
                                ClipboardData(
                                  text: widget.mnemonic.join(','),
                                ),
                              );
                            },
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  WidgetSpan(
                                    child: SvgPicture.asset(
                                      'assets/icons/copy.svg',
                                      width: 18,
                                      height: 18,
                                    ),
                                  ),
                                  WidgetSpan(
                                    child: SizedBox(
                                      width: 12,
                                    ),
                                  ),
                                  WidgetSpan(
                                    child: JellyLinkText(
                                      child: Text(
                                        'Copy to clipboard',
                                        style: jellyLink.apply(
                                          fontSizeDelta: 2,
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    NewPrimaryButton(
                      width: buttonSmallWidth,
                      callback: () {
                        Navigator.pushReplacement(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation1, animation2) =>
                                SettingScreen(),
                            transitionDuration: Duration.zero,
                            reverseTransitionDuration: Duration.zero,
                          ),
                        );
                      },
                      title: 'Confirm',
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
