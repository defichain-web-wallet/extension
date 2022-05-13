import 'package:defi_wallet/widgets/buttons/primary_button.dart';
import 'package:flutter/material.dart';

class PendingButton extends StatefulWidget {
  final String text;
  final String pendingText;
  final callback;
  final globalKey;
  final isCheckLock;

  const PendingButton(this.text,
      {Key? key,
      required this.callback,
      this.pendingText = 'Pending...',
      GlobalKey? this.globalKey,
      this.isCheckLock = true})
      : super(key: key);

  @override
  PendingButtonState createState() => PendingButtonState();
}

class PendingButtonState extends State<PendingButton> {
  var pending = false;

  @override
  Widget build(BuildContext context) {
    return PrimaryButton(
      label: pending ? widget.pendingText : widget.text,
      globalKey: widget.globalKey,
      isCheckLock: widget.isCheckLock,
      callback: (!pending && widget.callback != null)
          ? () async => widget.callback(this)
          : null,
    );
  }

  void emitPending(b) {
    setState(() {
      pending = b;
    });
  }
}
