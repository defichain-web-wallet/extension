import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class GradientSvgIcon extends StatelessWidget {
  final String assetName;
  final double width;
  final double height;

  GradientSvgIcon(
    this.assetName, {
    this.width = 16,
    this.height = 16,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: DefaultAssetBundle.of(context).loadString(assetName),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.hasData) {
          return ShaderMask(
            child: SvgPicture.string(
              snapshot.data!,
              width: width,
              height: height,
              fit: BoxFit.contain,
              semanticsLabel: 'SVG icon',
            ),
            shaderCallback: (Rect bounds) {
              return LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                tileMode: TileMode.clamp,
                colors: [
                  AppColors.electricViolet,
                  AppColors.pinkColor,
                ],
                stops: [
                  0.005,
                  1,
                ],
                transform: GradientRotation(199.84 * 3.1416 / 180),
              ).createShader(bounds);
            },
            blendMode: BlendMode.srcATop,
          );
        } else {
          return SizedBox();
        }
      },
    );
  }
}
