import 'dart:ui';

import 'package:defi_wallet/helpers/addresses_helper.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/buttons/accent_button.dart';
import 'package:defi_wallet/widgets/buttons/new_primary_button.dart';
import 'package:flutter/material.dart';

class CreateEditContactDialog extends StatefulWidget {
  final bool isEdit;
  final Function()? deleteCallback;
  final Function(String name, String address) confirmCallback;
  final String contactName;
  final String address;

  const CreateEditContactDialog({
    Key? key,
    this.isEdit = false,
    this.deleteCallback,
    required this.confirmCallback,
    this.contactName = '',
    this.address = '',
  }) : super(key: key);

  @override
  State<CreateEditContactDialog> createState() =>
      _CreateEditContactDialogState();
}

class _CreateEditContactDialogState extends State<CreateEditContactDialog> {
  AddressesHelper addressHelper = AddressesHelper();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  String editTitleText = 'Edit contact';
  String createTitleText = 'New contact';
  String titleContactName = 'Contact`s Name';
  String hintContactName = 'Enter Contact`s Name';
  String hintAddress = 'Enter Address';
  String titleAddress = 'Address';
  String subtitleText = 'Enter name and address';
  String titleDeleteContact = 'Delete contact';
  bool isValidAddress = false;
  late String titleText;
  late double contentHeight;
  late bool isEnable;

  @override
  void initState() {
    _nameController.text = widget.contactName;
    _addressController.text = widget.address;
    contentHeight = widget.isEdit ? 336 : 299;
    titleText = widget.isEdit ? editTitleText : createTitleText;
    checkButtonStatus();
    super.initState();
  }

  checkButtonStatus() {
    setState(() {
      if (_nameController.text.length > 3 &&
          _addressController.text.isNotEmpty &&
          isValidAddress) {
        isEnable = true;
      } else {
        isEnable = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0),
      child: AlertDialog(
        insetPadding: EdgeInsets.all(24),
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
                callback: isEnable
                    ? () {
                        widget.confirmCallback!(
                          _nameController.text,
                          _addressController.text,
                        );
                      }
                    : null,
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
                        color: Theme.of(context).dividerColor.withOpacity(0.5),
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
                          style:
                              headline2.copyWith(fontWeight: FontWeight.w700),
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
                          style: Theme.of(context).textTheme.headline5!.apply(
                                color: Theme.of(context)
                                    .textTheme
                                    .headline5!
                                    .color!
                                    .withOpacity(0.6),
                              ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Expanded(
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 24, horizontal: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Theme.of(context)
                              .selectedRowColor
                              .withOpacity(0.07),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  titleContactName,
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
                                  hintText: hintContactName,
                                  hintStyle: passwordField.copyWith(
                                    color: AppColors.darkTextColor
                                        .withOpacity(0.3),
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color:
                                          AppColors.portage.withOpacity(0.12),
                                      width: 1.0,
                                    ),
                                  ),
                                ),
                                onChanged: (value) async {
                                  isValidAddress = await addressHelper
                                      .validateAddress(_addressController.text);
                                  checkButtonStatus();
                                },
                              ),
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  titleAddress,
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
                                controller: _addressController,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: AppColors.white,
                                  hintText: hintAddress,
                                  hintStyle: passwordField.copyWith(
                                    color: AppColors.darkTextColor
                                        .withOpacity(0.3),
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color:
                                          AppColors.portage.withOpacity(0.12),
                                      width: 1.0,
                                    ),
                                  ),
                                ),
                                onChanged: (value) async {
                                  isValidAddress = await addressHelper
                                      .validateAddress(_addressController.text);
                                  checkButtonStatus();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (widget.isEdit)
                      Column(
                        children: [
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: widget.deleteCallback,
                                child: MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: Text(
                                    'Delete contact',
                                    style: subtitle1.copyWith(
                                        color: AppColors.razzmatazz,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
