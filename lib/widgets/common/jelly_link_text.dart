import 'package:flutter/material.dart';

import '../../utils/theme/theme.dart';

class JellyLinkText extends StatelessWidget {
  final List<Color> colors = [Color(0xFFFF00A3), Color(0xFFBC00C0)];
  final double rectangle = 3.4;
  final Widget child;

  JellyLinkText({Key? key, required this.child}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        final Map<String, Alignment> map = {};
        map['begin'] = Alignment.topRight;
        map['end'] = Alignment.bottomLeft;

        // linear-gradient(199.84deg, #FF00A3 0.53%, #BC00C0 100.59%);

        return LinearGradient(
          stops: [0.5, 100.5],
          colors: colors,
          transform: GradientRotation(3.4),
        ).createShader(bounds);
      },
      child: child,
    );
  }
}
