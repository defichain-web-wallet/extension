import 'dart:async';
import 'dart:io';

import 'package:defi_wallet/bloc/refactoring/wallet/wallet_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/client/hive_names.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/screens/auth/signup/signup_choose_theme_screen.dart';
import 'package:defi_wallet/screens/auth/signup/signup_done_screen.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/buttons/new_primary_button.dart';
import 'package:defi_wallet/widgets/fields/input_field.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/toolbar/welcome_app_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';

class SignupAccountScreen extends StatefulWidget {
  final List<String> mnemonic;
  final String password;

  const SignupAccountScreen({
    Key? key,
    required this.password,
    required this.mnemonic,
  }) : super(key: key);

  @override
  State<SignupAccountScreen> createState() => _SignupAccountScreenState();
}

class _SignupAccountScreenState extends State<SignupAccountScreen>
    with ThemeMixin {
  TextEditingController _nameController = TextEditingController();
  File? _pickedImage;
  Uint8List _webImage = Uint8List(8);

  double boxHeight = 190;

  Future<void> _pickImage() async {
    if (!kIsWeb) {
      final ImagePicker _picker = ImagePicker();
      XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        var selected = File(image.path);
        setState(() {
          _pickedImage = selected;
        });
      } else {
        print('No image has been picked');
      }
    } else if (kIsWeb) {
      final ImagePicker _picker = ImagePicker();
      XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        var f = await image.readAsBytes();
        setState(() {
          _webImage = f;
          _pickedImage = File('a');
        });
      } else {
        print('No image has been picked');
      }
    } else {
      print('Something went wrong');
    }
  }

  Future<void> _saveImageToStorage() async {
    var box = await Hive.openBox(HiveBoxes.client);
    await box.put(HiveNames.accountAvatar, _webImage);
    await box.put(HiveNames.accountName, _nameController.text);
    await box.close();
  }

  // TODO: move to side bar for load avatar
  Future<void> _getImageToStorage() async {
    var box = await Hive.openBox(HiveBoxes.client);
    var a = await box.get(HiveNames.accountAvatar);
    if (a != null) {
      setState(() {
        _webImage = Uint8List.fromList(a.toList());
        _pickedImage = File('a');
      });
    }
    await box.close();
  }

  _createAccount() async {
    WalletCubit walletCubit = BlocProvider.of<WalletCubit>(context);
    if (_pickedImage != null) {
      _saveImageToStorage();
    }

    await walletCubit.createWallet(
      widget.mnemonic,
      widget.password,
    );

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => SignupDoneScreen(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
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
            progress: 1,
          ),
          body: Container(
            padding: authPaddingContainer,
            child: Center(
              child: StretchBox(
                child: Column(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            height: 34,
                            child: Text(
                              'Name your account',
                              style: headline3,
                            ),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          Container(
                            height: boxHeight,
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14.5),
                              color: AppColors.portageBg.withOpacity(0.07),
                            ),
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 8,
                                ),
                                Stack(
                                  children: [
                                    CircleAvatar(
                                      radius: 24,
                                      backgroundColor:
                                          AppColors.portage.withOpacity(0.15),
                                      child: _pickedImage == null
                                          ? SvgPicture.asset(
                                              'assets/icon_user.svg',
                                            )
                                          : ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              child: kIsWeb
                                                  ? Image.memory(
                                                      _webImage,
                                                      fit: BoxFit.fill,
                                                    )
                                                  : Image.file(
                                                      _pickedImage!,
                                                      fit: BoxFit.fill,
                                                    ),
                                            ),
                                    ),
                                    Padding(
                                      padding:
                                          EdgeInsets.only(top: 28, left: 28),
                                      child: MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        child: GestureDetector(
                                          onTap: () => _pickImage(),
                                          child: CircleAvatar(
                                            radius: 12,
                                            backgroundColor: isDarkTheme()
                                                ? AppColors.mirage
                                                : AppColors.white,
                                            child: Container(
                                              height: 12,
                                              width: 12,
                                              child: Image.asset(
                                                'assets/icons/camera.png',
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Container(
                                  width: double.infinity,
                                  child: Text(
                                    'Account`s Name',
                                    style: headline5,
                                  ),
                                ),
                                SizedBox(
                                  height: 6,
                                ),
                                Container(
                                  child: InputField(
                                    controller: _nameController,
                                    hintText: 'Enter your Account`s Name',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    NewPrimaryButton(
                      callback: () => Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation1, animation2) =>
                              SignupChooseThemeScreen(callback: () async {
                            await _createAccount();
                          }),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      ),
                      width: isFullScreen ? buttonFullWidth : buttonSmallWidth,
                      title: 'Continue',
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
