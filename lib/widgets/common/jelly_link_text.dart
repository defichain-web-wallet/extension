import 'package:flutter/material.dart';

class JellyLinkText extends StatelessWidget {
  final List<Color> colors = [Color(0xFFFF00A3), Color(0xFFBC00C0)];
  final double rectangle = 1.4;
  final Widget child;

  JellyLinkText({Key? key, required this.child}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        final Map<String, Alignment> map = {};
        map['begin'] = Alignment.topRight;
        map['end'] = Alignment.bottomLeft;

        return LinearGradient(
          begin: map['begin']!,
          end: map['end']!,
          colors: colors,
          transform: GradientRotation(rectangle),
        ).createShader(bounds);
      },
      child: child,
    );
  }
}
