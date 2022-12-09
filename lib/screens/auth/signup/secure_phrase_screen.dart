import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/client/hive_names.dart';
import 'package:defi_wallet/screens/auth/name_account_screen.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/auth/mnemonic_word.dart';
import 'package:defi_wallet/widgets/buttons/new_primary_button.dart';
import 'package:defi_wallet/widgets/common/jelly_link_text.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/toolbar/welcome_app_bar.dart';
import 'package:defichaindart/defichaindart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:reorderables/reorderables.dart';

class SecurePhraseScreen extends StatefulWidget {
  final String? mnemonic;

  const SecurePhraseScreen({
    Key? key,
    this.mnemonic,
  }) : super(key: key);

  @override
  State<SecurePhraseScreen> createState() => _SecurePhraseScreenState();
}

class _SecurePhraseScreenState extends State<SecurePhraseScreen> {
  static const int mnemonicStrength = 256;
  static const double mnemonicBoxWidth = 348;

  final double _progress = 0.7;
  final int fieldsLength = 24;
  final GlobalKey globalKey = GlobalKey();

  late List<String> mnemonic;
  late List<TextEditingController> controllers;
  late List<FocusNode> focusNodes;

  @override
  void initState() {
    super.initState();
    if (widget.mnemonic == null) {
      mnemonic = generateMnemonic(strength: mnemonicStrength).split(' ');
      saveSecure();
    } else {
      mnemonic = widget.mnemonic!.split(',');
    }
    controllers = List.generate(fieldsLength, (i) {
      return TextEditingController(text: mnemonic[i]);
    });
  }

  Future<void> saveSecure() async {
    var box = await Hive.openBox(HiveBoxes.client);
    await box.put(HiveNames.openedMnemonic, mnemonic.join(','));
    await box.close();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> mnemonicPhrases = List.generate(
      fieldsLength,
      (index) => MnemonicWord(
        index: index + 1,
        word: mnemonic[index],
      ),
    );
    return ScaffoldWrapper(
      builder: (
        BuildContext context,
        bool isFullScreen,
        TransactionState txState,
      ) {
        return Scaffold(
          appBar: WelcomeAppBar(
            progress: _progress,
          ),
          body: Center(
            child: Container(
              padding: const EdgeInsets.only(
                top: 30,
                bottom: 24,
                left: 12,
                right: 12,
              ),
              child: StretchBox(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      child: Column(
                        children: [
                          Text(
                            'Secure your wallet',
                            style: Theme.of(context).textTheme.headline3,
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Text(
                            'Please remember your seed phrase \n in the correct order.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headline5!.apply(
                                  color: Theme.of(context)
                                      .textTheme
                                      .headline5!
                                      .color!
                                      .withOpacity(0.6),
                                ),
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          Container(
                            width: mnemonicBoxWidth,
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
                                    text: mnemonic.join(','),
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
                                          style: jellyLink.apply(fontSizeDelta: 2),
                                        ),
                                      )
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: NewPrimaryButton(
                              title: 'Continue',
                              callback: () => Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder:
                                      (context, animation1, animation2) =>
                                          NameAccountScreen(),
                                  transitionDuration: Duration.zero,
                                  reverseTransitionDuration: Duration.zero,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    )
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
