import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/client/hive_names.dart';
import 'package:defi_wallet/screens/auth/name_account_screen.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/auth/mnemonic_word.dart';
import 'package:defi_wallet/widgets/buttons/new_primary_button.dart';
import 'package:defi_wallet/widgets/fields/defi_text_form_field.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/toolbar/welcome_app_bar.dart';
import 'package:defichaindart/defichaindart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:reorderables/reorderables.dart';

class RecoveryScreen extends StatefulWidget {
  final String? mnemonic;

  const RecoveryScreen({
    Key? key,
    this.mnemonic,
  }) : super(key: key);

  @override
  State<RecoveryScreen> createState() => _RecoveryScreenState();
}

class _RecoveryScreenState extends State<RecoveryScreen> {
  static const int mnemonicStrength = 256;

  final double _progress = 0.7;
  final int fieldsLength = 24;
  bool isViewTextFeld = true;
  final GlobalKey globalKey = GlobalKey();
  final FocusNode _focusNode = FocusNode();
  final TextEditingController controller = TextEditingController();

  late List<String> mnemonic;
  late List<String> mnemonicLocal;
  late List<TextEditingController> controllers;
  late List<FocusNode> focusNodes;
  late List<Widget> mnemonicPhrasesWidgets;

  late bool isSavedMnemonic;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
    });
    mnemonicLocal = [];
    isSavedMnemonic = widget.mnemonic != null;
    super.initState();
    if (widget.mnemonic == null) {
      mnemonic = generateMnemonic(strength: mnemonicStrength).split(' ');
      // saveSecure();
    } else {
      mnemonic = widget.mnemonic!.split(',');
    }
  }

  generateMnemonicWidgets() {
    return List.generate(
      mnemonicLocal.length,
      (index) => MnemonicWord(
        index: index + 1,
        word: mnemonicLocal[index],
      ),
    );
  }

  Future<void> saveRestore() async {
    var box = await Hive.openBox(HiveBoxes.client);
    await box.put(HiveNames.recoveryMnemonic, mnemonic.join(','));
    await box.close();
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      String word = mnemonicLocal.removeAt(oldIndex);
      mnemonicLocal.insert(newIndex, word);
      generateMnemonicWidgets();
    });
  }

  _onFieldSubmitted(s) {
    setState(() {
      if(controller.text != ''){
        mnemonicLocal.add(s);
      }
      controller.text = '';
      mnemonicLocal.forEach((element) {
        print(element);
      });
      if (mnemonicLocal.length < 24) {
        FocusScope.of(context)
            .requestFocus(_focusNode);
      } else {
        isViewTextFeld = false;
      }
    });
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
                            'Please enter your seed phrase in the correct order.',
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
                            height: 32,
                          ),
                          Container(
                            width: 328,
                            child: ReorderableWrap(
                              alignment: WrapAlignment.center,
                              spacing: 6.0,
                              runSpacing: 6.0,
                              enableReorder: true,
                              needsLongPressDraggable: false,
                              padding: const EdgeInsets.all(0),
                              children: generateMnemonicWidgets(),
                              onReorder: _onReorder,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      child: Container(
                        child: isViewTextFeld
                            ? DefiTextFormField(
                                controller: controller,
                                onFieldSubmitted: _onFieldSubmitted,
                                autofocus: true,
                                focusNode: _focusNode,
                          readOnly: !isViewTextFeld,
                              )
                            : NewPrimaryButton(
                          callback: () {},
                        ),
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
