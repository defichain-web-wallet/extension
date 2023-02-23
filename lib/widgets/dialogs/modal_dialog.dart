import 'package:flutter/material.dart';

class ModalDialog extends StatelessWidget {
  final String title;
  final List<Text> listBody;
  final Function() onClose;
  final Function() onSubmit;

  const ModalDialog({
    Key? key,
    required this.title,
    required this.listBody,
    required this.onClose,
    required this.onSubmit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(
        child: ListBody(
          children: listBody,
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('Ok'),
          onPressed: () {
            onSubmit();
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
