import 'package:crypt/crypt.dart';
import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/client/hive_names.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/models/settings_model.dart';
import 'package:defi_wallet/screens/auth/password_screen.dart';
import 'package:defi_wallet/screens/home/home_screen.dart';
import 'package:defi_wallet/services/logger_service.dart';
import 'package:defi_wallet/services/mnemonic_service.dart';
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

class _RecoveryScreenState extends State<RecoveryScreen> with ThemeMixin {
  static const double _mnemonicBoxWidth = 328;
  static final RegExp _regExpPhraseSeparators = RegExp('[ .,;:|/-]+');
  static final String _replaceComaSeparator = ',';

  final int _fieldsLength = 24;
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _wordController = TextEditingController();
  final FocusNode _confirmFocusNode = FocusNode();

  late List<String> _mnemonic;
  late List<int> _invalidWordIndexes = [];
  late bool _isHoverMnemonicBox;

  bool _isViewTextField = true;
  bool _incorrectPhraseOrder = false;
  bool _onStartedReorder = false;

  int? _editableWordIndex;

  @override
  void dispose() {
    _focusNode.dispose();
    _wordController.dispose();
    _confirmFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {});
    _confirmFocusNode.addListener(() { });
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
        if (_invalidWordIndexes.isEmpty) {
          _incorrectPhraseOrder = true;
        }
        _onStartedReorder = true;
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
      _onStartedReorder = false;
    });
  }

  void _onChangeTextField(String value) {
    try {
      String phraseBySeparator = value.replaceAll(
        _regExpPhraseSeparators,
        _replaceComaSeparator,
      );
      List<String> phraseFromClipboard = phraseBySeparator.split(
        _replaceComaSeparator,
      );
      bool isEmptyNextItem = phraseFromClipboard[_fieldsLength].isEmpty;

      if (phraseFromClipboard.length == _fieldsLength + 1 && isEmptyNextItem) {
        phraseFromClipboard.removeWhere(
          (element) => element.isEmpty,
        );
        setState(() {
          _mnemonic = phraseFromClipboard;
          _wordController.text = '';
          _isViewTextField = false;
          _confirmFocusNode.requestFocus();
        });
      }
    } catch (err) {
      print(err);
    }
  }

  void _onFieldSubmitted(String word) {
    try {
      if (_editableWordIndex != null) {
        setState(() {
          _mnemonic[_editableWordIndex!] = word;
          _wordController.text = '';
          _editableWordIndex = null;
          if (_mnemonic.length < 24) {
            _focusNode.requestFocus();
          } else {
            _invalidWordIndexes = getInvalidControllerIndexes();
            _isViewTextField = false;
            _confirmFocusNode.requestFocus();
          }
        });
      } else {
        setState(() {
          if (_wordController.text != '') {
            final phraseBySeparator = _wordController.text.replaceAll(
              _regExpPhraseSeparators,
              _replaceComaSeparator,
            );
            var s = (phraseBySeparator.split(_replaceComaSeparator));
            s.forEach((element) {
              if (element != '') {
                _mnemonic.add(element);
              }
            });
          }
          _wordController.text = '';

          if (_mnemonic.length < 24 || _invalidWordIndexes.isNotEmpty) {
            _focusNode.requestFocus();
          } else {
            _invalidWordIndexes = getInvalidControllerIndexes();
            _isViewTextField = false;
            _confirmFocusNode.requestFocus();
          }
        });
      }
    } catch (err) {
      print(err);
    }
  }

  List<int> getInvalidControllerIndexes() {
    List<int> indexes = [];
    for (int i = 0; i < _mnemonic.length; i++) {
      if (!isCorrectWord(_mnemonic[i])) {
        indexes.add(i);
      }
    }
    return indexes;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> mnemonicWidgets = List.generate(
      _mnemonic.length,
      (index) => MouseRegion(
        cursor: SystemMouseCursors.grab,
        child: GestureDetector(
          onTap: () {
            setState(() {
              _isViewTextField = true;
              _onStartedReorder = false;
              _wordController.text = _mnemonic[index];
              _editableWordIndex = index;
              _focusNode.requestFocus();
            });
          },
          child: MnemonicWord(
            index: index + 1,
            word: _mnemonic[index],
            incorrect:
                _invalidWordIndexes.contains(index) || _incorrectPhraseOrder,
          ),
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
                                onReorderStarted: (index) {
                                  setState(() {
                                    _onStartedReorder = true;
                                  });
                                },
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
                                      _onStartedReorder = false;
                                      _editableWordIndex = null;

                                      if (_mnemonic.length < 24) {
                                        _isViewTextField = true;
                                        _focusNode.requestFocus();
                                      }
                                    });
                                  } else {
                                    setState(() {
                                      _onStartedReorder = false;
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
                    if (_onStartedReorder)
                      Container(
                        height: 44,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            width: 1,
                            color:
                                Theme.of(context).dividerColor.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 14,
                              height: 15,
                              child: SvgPicture.asset(
                                'assets/icons/trash.svg',
                                color: isDarkTheme()
                                    ? DarkColors.iconDragBoxColor
                                    : LightColors.iconDragBoxColor,
                              ),
                            ),
                            SizedBox(
                              width: 16,
                            ),
                            Text(
                              'Drag word here to remove',
                              style: Theme.of(context)
                                  .textTheme
                                  .headline6!
                                  .copyWith(
                                  color: Theme.of(context)
                                      .textTheme
                                      .headline6!
                                      .color!
                                      .withOpacity(0.24)),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        child: _isViewTextField
                            ? DefiTextFormField(
                                controller: _wordController,
                                onFieldSubmitted: _onFieldSubmitted,
                                autofocus: true,
                                focusNode: _focusNode,
                                readOnly: !_isViewTextField,
                                onChanged: _onChangeTextField,
                              )
                            : NewPrimaryButton(
                                focusNode: _confirmFocusNode,
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
