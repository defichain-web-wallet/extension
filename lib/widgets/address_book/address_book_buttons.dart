import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:flutter/material.dart';

class AddressBookButtons extends StatefulWidget {
  final Function() editCallback;
  final Function() deleteCallback;

  const AddressBookButtons({
    Key? key,
    required this.editCallback,
    required this.deleteCallback,
  }) : super(key: key);

  @override
  _AddressBookButtonsState createState() => _AddressBookButtonsState();
}

class _AddressBookButtonsState extends State<AddressBookButtons> {
  bool isEnterEdit = false;
  bool isEnterDelete = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MouseRegion(
          onEnter: (event) {
            setState(() {
              isEnterEdit = true;
            });
          },
          onExit: (event) {
            setState(() {
              isEnterEdit = false;
            });
          },
          child: IconButton(
            icon: Icon(Icons.edit),
            iconSize: 18,
            color: isEnterEdit ? AppTheme.pinkColor : Color(0xffbdbdbd),
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
            onPressed: widget.editCallback,
          ),
        ),
        MouseRegion(
          onEnter: (event) {
            setState(() {
              isEnterDelete = true;
            });
          },
          onExit: (event) {
            setState(() {
              isEnterDelete = false;
            });
          },
          child: IconButton(
            icon: Icon(Icons.delete),
            iconSize: 18,
            color: isEnterDelete ? Colors.red : Color(0xffbdbdbd),
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
            onPressed: widget.deleteCallback,
          ),
        ),
      ],
    );
  }
}
