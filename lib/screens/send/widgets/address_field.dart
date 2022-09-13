import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/screens/send/select_address_from_address_book.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:flutter/material.dart';

class AddressField extends StatefulWidget {
  final TextEditingController? addressController;
  final Function(String)? onChanged;
  final bool isBorder;

  const AddressField({
    Key? key,
    this.addressController,
    this.onChanged,
    this.isBorder = false,
  }) : super(key: key);

  @override
  State<AddressField> createState() => _AddressFieldState();
}

class _AddressFieldState extends State<AddressField> {
  bool isPinkIcon = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        // border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Focus(
        onFocusChange: (focused) {
          setState(() {
            isPinkIcon = focused;
          });
        },
        child: TextField(
          textAlignVertical: TextAlignVertical.center,
          style: Theme.of(context).textTheme.button,
          decoration: InputDecoration(
            filled: true,
            fillColor: Theme.of(context).cardColor,
            hoverColor: Theme.of(context).inputDecorationTheme.hoverColor,
            // border: OutlineInputBorder(
            //   borderRadius: BorderRadius.circular(10),
            //   borderSide: BorderSide(
            //     color: Theme.of(context).dividerColor,
            //   ),
            // ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: widget.isBorder ? Theme.of(context).dividerColor : Colors.transparent,
                // color: Theme.of(context).dividerColor,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppTheme.pinkColor),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 10),
            suffixIcon: IconButton(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
              icon: Image(
                image: isPinkIcon
                    ? AssetImage('assets/images/address_book_pink.png')
                    : SettingsHelper.settings.theme == 'Light'
                        ? AssetImage('assets/images/address_book_gray.png')
                        : AssetImage('assets/images/address_book_white.png'),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) =>
                        SelectAddressFromAddressBook(),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
              },
            ),
          ),
          onChanged: widget.onChanged,
          controller: widget.addressController,
        ),
      ),
    );
  }
}
