import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/mixins/storage_phrase_mixin.dart';
import 'package:defi_wallet/screens/auth/signup/name_account_screen.dart';
import 'package:defi_wallet/screens/auth/welcome_screen.dart';
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

class _SecurePhraseScreenState extends State<SecurePhraseScreen>
    with StoragePhraseMixin {
  static const int _mnemonicStrength = 256;
  static const double _mnemonicBoxWidth = 348;

  final double _progress = 0.7;
  final int _fieldsLength = 24;

  late List<String> _mnemonic;

  @override
  void initState() {
    super.initState();
    if (widget.mnemonic == null) {
      _mnemonic = generateMnemonic(strength: _mnemonicStrength).split(' ');
      savePhraseToStorage(_mnemonic.join(','));
    } else {
      _mnemonic = widget.mnemonic!.split(',');
    }
  }

  void _onResetSavedPhrase() {
    if (widget.mnemonic != null) {
      clearPhraseInStorage();

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => WelcomeScreen(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> mnemonicPhrases = List.generate(
      _fieldsLength,
      (index) => MnemonicWord(
        index: index + 1,
        word: _mnemonic[index],
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
            onBack: () => _onResetSavedPhrase(),
          ),
          body: Center(
            child: Container(
              padding: authPaddingContainer.copyWith(
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
                            width: _mnemonicBoxWidth,
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
                                    text: _mnemonic.join(','),
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
