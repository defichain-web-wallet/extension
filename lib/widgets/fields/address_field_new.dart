import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/models/address_book_model.dart';
import 'package:defi_wallet/widgets/dialogs/address_book_dialog.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AddressFieldNew extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode addressFocusNode;
  final AddressBookModel contact;
  final Function(String)? onChange;
  final Function()? clearPrefix;
  final Function(AddressBookModel contact)? getContact;
  final Function(String address)? getAddress;

  AddressFieldNew({
    Key? key,
    required this.controller,
    required this.addressFocusNode,
    required this.contact,
    this.onChange,
    this.clearPrefix,
    this.getContact,
    this.getAddress,
  }) : super(key: key);

  @override
  State<AddressFieldNew> createState() => _AddressFieldNewState();
}

class _AddressFieldNewState extends State<AddressFieldNew> with ThemeMixin{

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              'Address',
              style: Theme.of(context).textTheme.headline5,
            ),
          ],
        ),
        SizedBox(
          height: 6,
        ),
        Container(
          width: double.infinity,
          child: TextFormField(
            controller: widget.controller,
            onChanged: widget.onChange,
            decoration: InputDecoration(
                hoverColor: Theme.of(context).inputDecorationTheme.hoverColor,
                filled: true,
                fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                enabledBorder: Theme.of(context).inputDecorationTheme.enabledBorder,
                focusedBorder: Theme.of(context).inputDecorationTheme.focusedBorder,
                hintStyle: passwordField.copyWith(
                  color: isDarkTheme() ? DarkColors.hintTextColor : LightColors.hintTextColor,
                ),
                prefixIcon: (widget.contact.name != null &&
                        widget.controller.text == '')
                    ? Padding(
                        padding: const EdgeInsets.only(
                            top: 6.0, bottom: 6, left: 16),
                        child: Container(
                          constraints: BoxConstraints(maxWidth: 280),
                          padding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          width: (widget.contact.name!.length * 8) + 44,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(9.6),
                            border: Border.all(
                                color: AppColors.portage.withOpacity(0.12)),
                            color: AppColors.portage.withOpacity(0.07),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  widget.contact.name!,
                                  style: Theme.of(context).textTheme.headline6,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  onTap: widget.clearPrefix,
                                  child: Icon(
                                    Icons.close,
                                    color: isDarkTheme() ? AppColors.white.withOpacity(0.5) : AppColors.darkTextColor
                                        .withOpacity(0.5),
                                    size: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : null,
                suffixIcon: Padding(
                  padding: EdgeInsets.only(right: 18, top: 15, bottom: 15),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        showDialog(
                          barrierColor: AppColors.tolopea.withOpacity(0.06),
                          barrierDismissible: false,
                          context: context,
                          builder: (BuildContext context) {
                            return AddressBookDialog(
                              getContact: widget.getContact,
                              getAddress: widget.getAddress,
                            );
                          },
                        );
                      },
                      child: Image.asset(
                        'assets/images/address_book.png',
                        width: 16, height: 16,
                      ),
                    ),
                  ),
                ),
                hintText: widget.contact.name != null
                    ? null
                    : 'Enter address or choose from Address Book'),
          ),
        ),
      ],
    );
  }
}
