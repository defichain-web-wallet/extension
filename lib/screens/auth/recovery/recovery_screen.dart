import 'package:crypt/crypt.dart';
import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/client/hive_names.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/models/settings_model.dart';
import 'package:defi_wallet/screens/auth/password_screen.dart';
import 'package:defi_wallet/screens/home/home_screen.dart';
import 'package:defi_wallet/services/logger_service.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/auth/mnemonic_word.dart';
import 'package:defi_wallet/widgets/buttons/new_primary_button.dart';
import 'package:defi_wallet/widgets/fields/defi_text_form_field.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/toolbar/welcome_app_bar.dart';
import 'package:defichaindart/defichaindart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  static const double _mnemonicBoxWidth = 328;

  final int _fieldsLength = 24;
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _wordController = TextEditingController();

  late List<String> _mnemonic;
  late bool _isHoverMnemonicBox;

  bool _isViewTextField = true;
  bool _incorrectPhrase = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {});
    _mnemonic = [];
    super.initState();
  }

  void _onSubmitRecovery() async {
    SettingsHelper.settings.apiName = ApiName.auto;
    SettingsHelper().saveSettings();
    bool isValidPhrase = validateMnemonic(_mnemonic.join(' '));
    if (isValidPhrase) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => PasswordScreen(
            isShownProgressBar: false,
            onSubmitted: (String password) async {
              try {
                AccountCubit accountCubit =
                    BlocProvider.of<AccountCubit>(context);

                var box = await Hive.openBox(HiveBoxes.client);
                var encryptedPassword = Crypt.sha256(password).toString();
                await box.put(HiveNames.password, encryptedPassword);
                await box.close();

                await accountCubit.restoreAccount(_mnemonic, password);
                LoggerService.invokeInfoLogg('user  was recover wallet');
              } catch (err) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Something error',
                      style: Theme.of(context).textTheme.headline5,
                    ),
                    backgroundColor:
                        Theme.of(context).snackBarTheme.backgroundColor,
                  ),
                );
              }

              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation1, animation2) => HomeScreen(
                    isLoadTokens: true,
                  ),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
            },
          ),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    } else {
      setState(() {
        _incorrectPhrase = true;
      });
    }
  }

  void _onEnterHover(PointerEvent details) {
    setState(() => _isHoverMnemonicBox = true);
  }

  void _onExitHover(PointerEvent details) {
    setState(() => _isHoverMnemonicBox = false);
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      String word = _mnemonic.removeAt(oldIndex);
      _mnemonic.insert(newIndex, word);
    });
  }

  void _onFieldSubmitted(String word) {
    setState(() {
      if (_wordController.text != '') {
        _mnemonic.add(word);
      }
      _wordController.text = '';

      if (_mnemonic.length < 24) {
        FocusScope.of(context).requestFocus(_focusNode);
      } else {
        _isViewTextField = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> mnemonicWidgets = List.generate(
      _mnemonic.length,
      (index) => MouseRegion(
        cursor: SystemMouseCursors.grab,
        child: MnemonicWord(
          index: index + 1,
          word: _mnemonic[index],
          incorrect: _incorrectPhrase,
        ),
      ),
    );
    return ScaffoldWrapper(
      builder: (
        BuildContext context,
        bool isFullScreen,
        TransactionState txState,
      ) {
        return Scaffold(
          appBar: WelcomeAppBar(),
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
                            style: Theme.of(context).textTheme.headline3!,
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
                          MouseRegion(
                            onEnter: _onEnterHover,
                            onExit: _onExitHover,
                            child: Container(
                              width: _mnemonicBoxWidth,
                              child: ReorderableWrap(
                                alignment: WrapAlignment.center,
                                spacing: 6.0,
                                runSpacing: 6.0,
                                enableReorder: true,
                                needsLongPressDraggable: false,
                                padding: const EdgeInsets.all(0),
                                children: mnemonicWidgets,
                                onNoReorder: (index) {
                                  if (!_isHoverMnemonicBox) {
                                    setState(() {
                                      _mnemonic.removeAt(index);

                                      if (_mnemonic.length < 24) {
                                        FocusScope.of(context)
                                            .requestFocus(_focusNode);
                                        _isViewTextField = true;
                                      }
                                    });
                                  }
                                },
                                onReorder: _onReorder,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      child: _isViewTextField
                          ? DefiTextFormField(
                              controller: _wordController,
                              onFieldSubmitted: _onFieldSubmitted,
                              autofocus: true,
                              focusNode: _focusNode,
                              readOnly: !_isViewTextField,
                              onChanged: (String value) {
                                try {
                                  List<String> phraseFromClipboard =
                                      value.split(' ');
                                  if (phraseFromClipboard.length ==
                                      _fieldsLength) {
                                    setState(() {
                                      _mnemonic = phraseFromClipboard;
                                      _wordController.text = '';
                                      _isViewTextField = false;
                                    });
                                  }
                                } catch (err) {
                                  print(err);
                                }
                              },
                            )
                          : NewPrimaryButton(
                              title: 'Restore Wallet',
                              width: isFullScreen
                                  ? buttonFullWidth
                                  : buttonSmallWidth,
                              callback: _onSubmitRecovery,
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
