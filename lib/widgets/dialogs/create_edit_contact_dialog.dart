import 'dart:ui';

import 'package:defi_wallet/bloc/refactoring/wallet/wallet_cubit.dart';
import 'package:defi_wallet/helpers/addresses_helper.dart';
import 'package:defi_wallet/mixins/snack_bar_mixin.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/models/network/network_name.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/buttons/accent_button.dart';
import 'package:defi_wallet/widgets/buttons/new_primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateEditContactDialog extends StatefulWidget {
  final bool isEdit;
  final bool isDisableEditAddress;
  final Function()? deleteCallback;
  final Function(String name, String address, NetworkTypeModel network)
      confirmCallback;
  final String contactName;
  final String address;

  const CreateEditContactDialog({
    Key? key,
    this.isEdit = false,
    this.isDisableEditAddress = false,
    this.deleteCallback,
    required this.confirmCallback,
    this.contactName = '',
    this.address = '',
  }) : super(key: key);

  @override
  State<CreateEditContactDialog> createState() =>
      _CreateEditContactDialogState();
}

class _CreateEditContactDialogState extends State<CreateEditContactDialog>
    with ThemeMixin, SnackBarMixin {
  AddressesHelper addressHelper = AddressesHelper();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  FocusNode nameFocusNode = FocusNode();
  FocusNode addressFocusNode = FocusNode();
  FocusNode submitFocusNode = FocusNode();
  final formKey = GlobalKey<FormState>();
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
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    nameFocusNode.dispose();
    addressFocusNode.dispose();
    submitFocusNode.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void initState() {
    _nameController.text = widget.contactName;
    _addressController.text = widget.address;
    contentHeight = widget.isEdit ? 356 : 329;
    titleText = widget.isEdit ? editTitleText : createTitleText;
    checkButtonStatus();
    super.initState();
  }

  checkButtonStatus() {
    setState(() {
      if (_nameController.text.length > 0 &&
          _addressController.text.isNotEmpty) {
        isEnable = true;
      } else {
        isEnable = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final walletCubit = BlocProvider.of<WalletCubit>(context);
    final activeNetwork = walletCubit.state.activeNetwork;
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0),
      child: AlertDialog(
        backgroundColor: isDarkTheme()
            ? DarkColors.drawerBgColor
            : LightColors.drawerBgColor,
        shape: RoundedRectangleBorder(
          side: isDarkTheme()
              ? BorderSide(color: DarkColors.drawerBorderColor)
              : BorderSide.none,
          borderRadius: BorderRadius.circular(20),
        ),
        insetPadding: EdgeInsets.all(24),
        elevation: 0.0,
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
                focusNode: submitFocusNode,
                width: 104,
                callback: isEnable
                    ? () async {
                        bool isValid = activeNetwork.checkAddress(
                          _addressController.text,
                        );
                        setState(() {
                          isValidAddress = isValid;
                        });
                        if (formKey.currentState!.validate()) {
                          widget.confirmCallback!(
                            _nameController.text,
                            _addressController.text,
                            activeNetwork.networkType,
                          );
                        }
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
                        child: Form(
                          key: formKey,
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
                                  focusNode: nameFocusNode,
                                  controller: _nameController,
                                  autofocus: true,
                                  decoration: InputDecoration(
                                    hoverColor: Theme.of(context)
                                        .inputDecorationTheme
                                        .hoverColor,
                                    filled: true,
                                    fillColor: Theme.of(context)
                                        .inputDecorationTheme
                                        .fillColor,
                                    enabledBorder: Theme.of(context)
                                        .inputDecorationTheme
                                        .enabledBorder,
                                    focusedBorder: Theme.of(context)
                                        .inputDecorationTheme
                                        .focusedBorder,
                                    hintStyle: passwordField.copyWith(
                                      color: isDarkTheme()
                                          ? DarkColors.hintTextColor
                                          : LightColors.hintTextColor,
                                    ),
                                    hintText: hintContactName,
                                  ),
                                  onChanged: (value) async {
                                    checkButtonStatus();
                                  },
                                  onFieldSubmitted: (val) {
                                    if (widget.isDisableEditAddress) {
                                      submitFocusNode.requestFocus();
                                    } else {
                                      addressFocusNode.requestFocus();
                                    }
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
                              TextFormField(
                                readOnly: widget.isDisableEditAddress,
                                focusNode: addressFocusNode,
                                controller: _addressController,
                                decoration: InputDecoration(
                                  errorStyle: TextStyle(
                                    backgroundColor: Colors.transparent,
                                    color: Colors.pink,
                                    fontSize: 12,
                                  ),
                                  hoverColor: Theme.of(context)
                                      .inputDecorationTheme
                                      .hoverColor,
                                  filled: true,
                                  fillColor: Theme.of(context)
                                      .inputDecorationTheme
                                      .fillColor,
                                  enabledBorder: Theme.of(context)
                                      .inputDecorationTheme
                                      .enabledBorder,
                                  focusedBorder: Theme.of(context)
                                      .inputDecorationTheme
                                      .focusedBorder,
                                  hintStyle: passwordField.copyWith(
                                    color: isDarkTheme()
                                        ? DarkColors.hintTextColor
                                        : LightColors.hintTextColor,
                                  ),
                                  hintText: hintAddress,
                                ),
                                onChanged: (value) async {
                                  checkButtonStatus();
                                },
                                validator: (val) {
                                  return isValidAddress
                                      ? null
                                      : "Incorrect address";
                                },
                                onFieldSubmitted: (val) {
                                  submitFocusNode.requestFocus();
                                },
                              ),
                            ],
                          ),
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
