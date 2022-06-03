import 'package:defi_wallet/screens/auth_screen/secure_wallet/widgets/create_password_screen.dart';
import 'package:defi_wallet/screens/auth_screen/secure_wallet/widgets/text_fields.dart';
import 'package:defi_wallet/services/mnemonic_service.dart';
import 'package:defi_wallet/widgets/scaffold_constrained_box.dart';
import 'package:defichaindart/defichaindart.dart';
import 'package:flutter/material.dart';
import 'package:defi_wallet/widgets/buttons/restore_button.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/toolbar/auth_app_bar.dart';
import 'package:hive/hive.dart';
import 'package:defi_wallet/client/hive_names.dart';
import 'package:defi_wallet/config/config.dart';

class RecoveryScreen extends StatefulWidget {
  final String? mnemonic;

  const RecoveryScreen({Key? key, this.mnemonic}) : super(key: key);

  @override
  _RecoveryScreenState createState() => _RecoveryScreenState();
}

class _RecoveryScreenState extends State<RecoveryScreen> {
  final int fieldsLength = 24;
  late List<TextEditingController> controllers;
  late List<FocusNode> focusNodes;
  late List<String> mnemonic;
  late bool isSavedMnemonic;
  List<int> invalidControllerIndexes = [];
  GlobalKey globalKey = GlobalKey();

  @override
  void initState() {
    isSavedMnemonic = widget.mnemonic != null;
    super.initState();
    if (widget.mnemonic == null) {
      mnemonic = List.generate(fieldsLength, (index) => '');
      saveRestore();
    } else {
      mnemonic = widget.mnemonic!.split(',');
    }
    controllers = List.generate(
        fieldsLength, (i) => TextEditingController(text: mnemonic[i]));
    focusNodes = List.generate(fieldsLength, (i) => FocusNode());
  }

  @override
  void dispose() {
    controllers.forEach((c) => c.dispose());
    focusNodes.forEach((c) => c.dispose());
    super.dispose();
  }

  Future<void> saveRestore() async {
    var box = await Hive.openBox(HiveBoxes.client);
    await box.put(HiveNames.recoveryMnemonic, mnemonic.join(','));
    await box.close();
  }

  @override
  Widget build(BuildContext context) => ScaffoldConstrainedBox(
        child: LayoutBuilder(builder: (context, constraints) {
          if (constraints.maxWidth < ScreenSizes.medium) {
            return Scaffold(
              appBar: AuthAppBar(
                controllers: controllers,
                isSavedMnemonic: isSavedMnemonic,
                isShowFullScreen: true,
              ),
              body: _buildBody(context),
            );
          } else {
            return Container(
              padding: EdgeInsets.only(top: 20),
              child: Scaffold(
                appBar: AuthAppBar(
                  isSavedMnemonic: isSavedMnemonic,
                  isSmall: false,
                ),
                body: _buildBody(context, isCustomBgColor: true),
              ),
            );
          }
        }),
      );

  Widget _buildBody(context, {isCustomBgColor = false}) => Container(
        color: isCustomBgColor ? Theme.of(context).dialogBackgroundColor : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Center(
            child: StretchBox(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Text(
                        'Restore your wallet',
                        style: Theme.of(context).textTheme.headline1,
                      ),
                      SizedBox(height: 24),
                      Text(
                        "Please enter your seed phrase in the correct order.",
                        style: Theme.of(context).textTheme.headline2,
                      ),
                    ],
                  ),
                  TextFields(
                    controllers: controllers,
                    focusNodes: focusNodes,
                    globalKey: globalKey,
                    invalidControllerIndexes: invalidControllerIndexes,
                  ),
                  StretchBox(
                    child: PendingButton(
                      'Restore wallet',
                      isCheckLock: false,
                      globalKey: globalKey,
                      callback: (parent) => _restoreWallet(parent),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      );

  List<String> _getPhrase(controllers) =>
      List.generate(controllers.length, (i) => controllers[i].text);

  List<int> getInvalidControllerIndexes(controllers) {
    List<int> indexes = [];
    for (int i = 0; i < controllers.length; i++) {
      if (!isCorrectWord(controllers[i].text)) {
        indexes.add(i);
      }
    }
    return indexes;
  }

  void _restoreWallet(parent) async {
    var phrase = _getPhrase(controllers);
    if (phrase.length >= fieldsLength) {
      parent.emitPending(true);

      var isValidPhrase = validateMnemonic(phrase.join(' '));
      if (isValidPhrase) {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => CreatePasswordScreen(
              showStep: false,
              showDoneScreen: false,
              isRecovery: true,
              mnemonic: phrase,
            ),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      } else {
        setState(() {
          invalidControllerIndexes = getInvalidControllerIndexes(controllers);
        });
        FocusScope.of(context).unfocus();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Invalid phrase',
              style: Theme.of(context).textTheme.headline5,
            ),
            backgroundColor: Theme.of(context).snackBarTheme.backgroundColor,
          ),
        );
      }

      parent.emitPending(false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please, input all fields',
            style: Theme.of(context).textTheme.headline5,
          ),
          backgroundColor: Theme.of(context).snackBarTheme.backgroundColor,
        ),
      );
    }
  }
}
