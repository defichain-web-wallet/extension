import 'package:flutter/material.dart';

class CancelButton extends StatelessWidget {
  final Function()? callback;

  const CancelButton({Key? key, this.callback}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: IconButton(
        highlightColor: Colors.transparent,
        focusColor: Colors.transparent,
        iconSize: 20,
        splashRadius: 18,
        icon: Icon(Icons.close, color: Theme.of(context).iconTheme.color),
        onPressed: callback ?? () => Navigator.of(context).pop(),
      ),
    );
  }
}
