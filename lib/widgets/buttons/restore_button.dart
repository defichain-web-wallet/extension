import 'package:defi_wallet/widgets/buttons/new_primary_button.dart';
import 'package:flutter/material.dart';

class PendingButton extends StatefulWidget {
  final String text;
  final String pendingText;
  final callback;
  final globalKey;
  final isCheckLock;

  final double? width;

  const PendingButton(this.text, {Key? key, required this.callback, this.pendingText = 'Pending...', GlobalKey? this.globalKey, this.isCheckLock = true, this.width})
      : super(key: key);

  @override
  PendingButtonState createState() => PendingButtonState();
}

class PendingButtonState extends State<PendingButton> {
  var pending = false;

  @override
  Widget build(BuildContext context) {
    return NewPrimaryButton(
      width: widget.width ?? double.infinity,
      title: pending ? widget.pendingText : widget.text,
      callback: (!pending && widget.callback != null) ? () async => await widget.callback(this) : null,
    );
  }

  void emitPending(b) {
    setState(() {
      pending = b;
    });
  }
}
