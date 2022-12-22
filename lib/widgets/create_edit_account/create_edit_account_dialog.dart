import 'dart:io';
import 'dart:ui';

import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/buttons/accent_button.dart';
import 'package:defi_wallet/widgets/buttons/new_primary_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

class CreateEditAccountDialog extends StatefulWidget {
  final bool isEdit;
  final int? index;
  final String? name;
  final Function(String s)? callback;

  const CreateEditAccountDialog({
    Key? key,
    this.isEdit = false,
    this.index,
    this.name,
    this.callback,
  }) : super(key: key);

  @override
  State<CreateEditAccountDialog> createState() =>
      _CreateEditAccountDialogState();
}

class _CreateEditAccountDialogState extends State<CreateEditAccountDialog> {
  TextEditingController _nameController = TextEditingController();
  File? _pickedImage;
  Uint8List _webImage = Uint8List(8);
  String editTitleText = 'Edit account';
  String editSubtitleText = 'You can change your avatar and name';
  String createTitleText = 'Create account';
  String createSubtitleText = 'How do you want to name this new Account';
  late double contentHeight;
  late String titleText;
  late String subtitleText;

  @override
  void initState() {
    if (widget.name != null) {
      _nameController.text = widget.name!;
    }
    contentHeight = widget.isEdit ? 293 : 220;
    titleText = widget.isEdit ? editTitleText : createTitleText;
    subtitleText = widget.isEdit ? editSubtitleText : createSubtitleText;
    super.initState();
  }

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

  acceptEdit() async {
    Navigator.pop(context);
  }

  acceptCreate() async {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountCubit, AccountState>(
      builder: (BuildContext context, state) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0),
          child: AlertDialog(
            elevation: 0.0,
            shape: RoundedRectangleBorder(
              side: BorderSide.none,
              borderRadius: BorderRadius.circular(20),
            ),
            actionsPadding: EdgeInsets.symmetric(
              vertical: 24,
              horizontal: 14,
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 104,
                    child: AccentButton(
                      callback: () {
                        Navigator.pop(context);
                      },
                      label: 'Cancel',
                    ),
                  ),
                  NewPrimaryButton(
                    width: 104,
                    callback: () {
                      if (_nameController.text.length > 3) {
                        widget.callback!(_nameController.text);
                        Navigator.pop(context);
                         // AccountCubit accountCubit =
                         // BlocProvider.of<AccountCubit>(context);
                         // accountCubit.updateAccountDetails();
                      }
                    },
                    title: 'Confirm',
                  ),
                ],
              ),
            ],
            contentPadding: EdgeInsets.only(
              top: 16,
              bottom: 0,
              left: 16,
              right: 16,
            ),
            content: Container(
              width: 280,
              height: contentHeight,
              child: Stack(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(
                            Icons.close,
                            size: 16,
                            color:
                                Theme.of(context).dividerColor.withOpacity(0.5),
                          ),
                        ),
                      )
                    ],
                  ),
                  Container(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 8,
                        ),
                        Row(
                          children: [
                            Text(
                              titleText,
                              style: headline2.copyWith(
                                  fontWeight: FontWeight.w700),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Row(
                          children: [
                            Text(
                              subtitleText,
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle1!
                                  .copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .subtitle1!
                                        .color!
                                        .withOpacity(0.6),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 24, horizontal: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Theme.of(context)
                                  .selectedRowColor
                                  .withOpacity(0.07),
                            ),
                            child: Column(
                              children: [
                                if (widget.isEdit)
                                  Container(
                                    child: Stack(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: _pickedImage == null
                                                ? LinearGradient(
                                                    colors: [
                                                      AppColors.redViolet
                                                          .withOpacity(0.16),
                                                      AppColors.razzmatazz
                                                          .withOpacity(0.16),
                                                    ],
                                                  )
                                                : null,
                                          ),
                                          child: CircleAvatar(
                                            radius: 24,
                                            backgroundColor: Colors.transparent,
                                            child: _pickedImage == null
                                                ? GradientText(
                                                    'K',
                                                    style: headline6.copyWith(
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        fontFamily:
                                                            'Red Hat Display'),
                                                    gradientType:
                                                        GradientType.linear,
                                                    gradientDirection:
                                                        GradientDirection.btt,
                                                    colors: [
                                                      AppColors.electricViolet,
                                                      AppColors.hollywoodCerise,
                                                    ],
                                                  )
                                                : ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
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
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(
                                              top: 28, left: 28),
                                          child: MouseRegion(
                                            cursor: SystemMouseCursors.click,
                                            child: GestureDetector(
                                              onTap: () => _pickImage(),
                                              child: CircleAvatar(
                                                radius: 12,
                                                backgroundColor:
                                                    AppColors.white,
                                                child: SvgPicture.asset(
                                                    'assets/icon_photo.svg'),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                if (widget.isEdit)
                                  SizedBox(
                                    height: 20,
                                  ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Account`s Name',
                                      style: headline5,
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 6,
                                ),
                                Container(
                                  height: 44,
                                  child: TextFormField(
                                    controller: _nameController,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: AppColors.white,
                                      hintText: 'Enter your Account`s Name',
                                      hintStyle: passwordField.copyWith(
                                        color: AppColors.darkTextColor
                                            .withOpacity(0.3),
                                      ),
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: AppColors.portage
                                              .withOpacity(0.12),
                                          width: 1.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
