import 'package:defi_wallet/config/config.dart';
import 'package:flutter/material.dart';

class ScaffoldConstrainedBox extends StatefulWidget {
  final child;

  const ScaffoldConstrainedBox({Key? key, this.child}) : super(key: key);

  @override
  State<ScaffoldConstrainedBox> createState() => _ScaffoldConstrainedBoxState();
}

class _ScaffoldConstrainedBoxState extends State<ScaffoldConstrainedBox> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Align(
        alignment: Alignment.center,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: ScreenSizes.medium),
          child: widget.child,
        ),
      ),
    );
  }
}
