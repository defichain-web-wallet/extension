import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/client/hive_names.dart';
import 'package:defi_wallet/screens/auth/name_account_screen.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/auth/mnemonic_word.dart';
import 'package:defi_wallet/widgets/buttons/new_primary_button.dart';
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
  final GlobalKey globalKey = GlobalKey();

  late List<String> mnemonic;
  late List<TextEditingController> controllers;
  late List<FocusNode> focusNodes;
  late List<Widget> mnemonicPhrasesWidgets;

  late bool isSavedMnemonic;


  @override
  void initState() {
    super.initState();
    isSavedMnemonic = widget.mnemonic != null;
    super.initState();
    if (widget.mnemonic == null) {
      mnemonic = generateMnemonic(strength: mnemonicStrength).split(' ');
      // saveSecure();
    } else {
      mnemonic = widget.mnemonic!.split(',');
    }
    mnemonicPhrasesWidgets = List.generate(
      fieldsLength,
          (index) => MnemonicWord(
        index: index,
        word: mnemonic[index],
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
      print('oldIndex $oldIndex');
      print('newIndex $newIndex');

      String targetWord = mnemonic.removeAt(oldIndex);
      mnemonic.insert(newIndex, targetWord);

      Widget row = mnemonicPhrasesWidgets.removeAt(oldIndex);
      mnemonicPhrasesWidgets.insert(newIndex, row);
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
          body: Container(
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
                          child: ReorderableWrap(
                            alignment: WrapAlignment.center,
                            spacing: 6.0,
                            runSpacing: 6.0,
                            enableReorder: true,
                            needsLongPressDraggable: false,
                            padding: const EdgeInsets.all(0),
                            children: mnemonicPhrasesWidgets,
                            onReorder: _onReorder,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    child: Container(
                      child: TextFormField(
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                          hintText: 'Enter your seed phrase',
                          hintStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xff12052F).withOpacity(0.3),
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color(0xffebe9fa), width: 1.0),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
