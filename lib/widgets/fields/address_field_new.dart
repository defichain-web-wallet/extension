import 'package:defi_wallet/models/address_book_model.dart';
import 'package:defi_wallet/widgets/dialogs/address_book_dialog.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AddressFieldNew extends StatefulWidget {
  final TextEditingController controller;
  final AddressBookModel contact;
  final Function(String)? onChange;
  final Function()? clearPrefix;
  final Function(AddressBookModel contact)? getContact;
  final Function(String address)? getAddress;
  final Function(String address)? onSubmit;
  final FocusNode? focusNode;

  AddressFieldNew({
    Key? key,
    required this.controller,
    required this.contact,
    this.focusNode,
    this.onChange,
    this.clearPrefix,
    this.getContact,
    this.getAddress,
    this.onSubmit,
  }) : super(key: key);

  @override
  State<AddressFieldNew> createState() => _AddressFieldNewState();
}

class _AddressFieldNewState extends State<AddressFieldNew> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
            focusNode: widget.focusNode,
            onFieldSubmitted: widget.onSubmit,
            controller: widget.controller,
            onChanged: widget.onChange,
            decoration: InputDecoration(
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
                                    color: AppColors.darkTextColor
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
                          barrierColor: Color(0x0f180245),
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
                      child: SvgPicture.asset(
                        'assets/icons/address_book_icon.svg',
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
