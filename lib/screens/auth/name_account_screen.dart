import 'dart:io';
import 'dart:async';

import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/client/hive_names.dart';
import 'package:defi_wallet/screens/auth/congratulations_screen.dart';
import 'package:defi_wallet/widgets/buttons/new_primary_button.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/toolbar/welcome_app_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';

class NameAccountScreen extends StatefulWidget {
  const NameAccountScreen({Key? key}) : super(key: key);

  @override
  State<NameAccountScreen> createState() => _NameAccountScreenState();
}

class _NameAccountScreenState extends State<NameAccountScreen> {
  TextEditingController _nameController = TextEditingController();
  File? _pickedImage;
  Uint8List _webImage = Uint8List(8);

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
            width: double.infinity,
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 30,
                      ),
                      Container(
                        height: 34,
                        child: Text(
                          'Name your account',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 26,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Container(
                        width: 312,
                        height: 189,
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14.5),
                          color: Color(0x129B73EE),
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
                                  backgroundColor: Color(0x269490EA),
                                  child: _pickedImage == null
                                      ? SvgPicture.asset('assets/icon_user.svg')
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
                                  padding: EdgeInsets.only(top: 28, left: 28),
                                  child: MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: GestureDetector(
                                      onTap: () {
                                        _pickImage();
                                      },
                                      child: CircleAvatar(
                                        radius: 12,
                                        backgroundColor: Color(0xffffffff),
                                        child: SvgPicture.asset(
                                            'assets/icon_photo.svg'),
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
                              height: 19,
                              // color: Colors.cyan,
                              child: Text(
                                'Account`s Name',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            Container(
                              child: TextFormField(
                                controller: _nameController,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Color(0xFFFFFFFF),
                                  hintText: 'Enter your Account`s Name',
                                  hintStyle: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xff12052F).withOpacity(0.3),
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color(0xffebe9fa),
                                      width: 1.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                NewPrimaryButton(
                  callback: () {
                    _saveImageToStorage();

                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            CongratulationsScreen(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  },
                  width: 280,
                  title: 'Continue',
                ),
                SizedBox(
                  height: 24,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
