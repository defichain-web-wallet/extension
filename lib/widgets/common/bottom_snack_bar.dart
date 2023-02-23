import 'dart:ui';

import 'package:flutter/material.dart';

class BottomSnackBar extends StatelessWidget {
  final color;

  const BottomSnackBar({
    Key? key,
    this.color = Colors.black,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SnackBar(
      elevation: 0,
      margin: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 16,
      ),
      behavior: SnackBarBehavior.floating,
      content: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0),
        child: Row(
          children: <Widget>[
            // add your preferred icon here
            Icon(
              Icons.close,
              color: Colors.white,
            ),
            // add your preferred text content here
            Text('Text'),
          ],
        ),
      ),
      backgroundColor: color.withOpacity(0.08),
    );
  }
}
