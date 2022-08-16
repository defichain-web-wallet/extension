import 'package:defi_wallet/client/hive_names.dart';
import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/screens/auth_screen/confirmation_mnemonic.dart';
import 'package:defi_wallet/screens/auth_screen/secure_wallet/widgets/text_fields.dart';
import 'package:defi_wallet/widgets/buttons/primary_button.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_constrained_box.dart';
import 'package:defi_wallet/widgets/toolbar/auth_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:defichaindart/defichaindart.dart';
import 'package:hive/hive.dart';

class SecureScreen extends StatefulWidget {
  final String? mnemonic;

  const SecureScreen({Key? key, this.mnemonic}) : super(key: key);

  @override
  _SecureScreenState createState() => _SecureScreenState();
}

class _SecureScreenState extends State<SecureScreen> {
  static const int mnemonicStrength = 256;
  final int fieldsLength = 24;
  late List<String> mnemonic;
  late List<TextEditingController> controllers;
  late List<FocusNode> focusNodes;
  final GlobalKey globalKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    if (widget.mnemonic == null) {
      mnemonic = generateMnemonic(strength: mnemonicStrength).split(' ');
      saveSecure();
    } else {
      mnemonic = widget.mnemonic!.split(',');
    }
    controllers = List.generate(
        fieldsLength, (i) => TextEditingController(text: mnemonic[i]));
    focusNodes = List.generate(fieldsLength, (i) => FocusNode());

    for (var i = 0; i < 24; i++) {
      focusNodes[i].addListener(() {
        if (focusNodes[i].hasFocus) {
          controllers[i].selection = TextSelection(
              baseOffset: 0, extentOffset: controllers[i].text.length);
        }
      });
    }
  }

  @override
  void dispose() {
    controllers.forEach((c) => c.dispose());
    focusNodes.forEach((c) => c.dispose());
    super.dispose();
  }

  Future<void> saveSecure() async {
    var box = await Hive.openBox(HiveBoxes.client);
    await box.put(HiveNames.openedMnemonic, mnemonic.join(','));
    await box.close();
  }

  @override
  Widget build(BuildContext context) => ScaffoldConstrainedBox(
        child: LayoutBuilder(builder: (context, constraints) {
          if (constraints.maxWidth < ScreenSizes.medium) {
            return Scaffold(
              appBar: AuthAppBar(
                isSavedMnemonic: widget.mnemonic != null,
                isShowFullScreen: true,
              ),
              body: _buildBody(context),
            );
          } else {
            return Container(
              padding: EdgeInsets.only(top: 20),
              child: Scaffold(
                appBar: AuthAppBar(
                  isSavedMnemonic: widget.mnemonic != null,
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Text(
                      '2/4',
                      style: Theme.of(context).textTheme.headline2,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Secure your wallet',
                      style: Theme.of(context).textTheme.headline1,
                    ),
                    SizedBox(height: 24),
                    Text(
                      "Write down your seed phrase.",
                      style: Theme.of(context).textTheme.headline2,
                    ),
                  ],
                ),
                TextFields(
                  readOnly: true,
                  controllers: controllers,
                  focusNodes: focusNodes,
                  globalKey: globalKey,
                  enabled: true,
                ),
                StretchBox(
                  child: PrimaryButton(
                    isCheckLock: false,
                    label: 'Continue',
                    callback: () async {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation1, animation2) =>
                              ConfirmationMnemonic(mnemonic: mnemonic),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
