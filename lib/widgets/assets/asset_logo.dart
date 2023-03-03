import 'package:defi_wallet/helpers/tokens_helper.dart';
import 'package:defi_wallet/models/asset_style_model.dart';
import 'package:flutter/material.dart';

class AssetLogo extends StatelessWidget {
  final AssetStyleModel assetStyle;
  final double size;
  final bool isBorder;
  final double borderWidth;

  AssetLogo({
    Key? key,
    required this.assetStyle,
    this.size = 42,
    this.borderWidth = 5,
    this.isBorder = true,
  }) : super(key: key);

  TokensHelper tokensHelper = TokensHelper();

  @override
  Widget build(BuildContext context) {
    if (assetStyle.isUniqueLogo!) {
      return Container(
        width: size,
        height: size,
        padding: EdgeInsets.all(borderWidth),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: isBorder ? LinearGradient(
            transform: assetStyle.rotateRadian != null
                ? GradientRotation(assetStyle.rotateRadian!)
                : null,
            stops: assetStyle.stops,
            colors: assetStyle.tokenName == 'DUSD'
                ? [
              assetStyle.gradientColors![0].withOpacity(0.1),
              assetStyle.gradientColors![1].withOpacity(0.1),
                  ]
                : [
              assetStyle.gradientColors![0].withOpacity(0.16),
              assetStyle.gradientColors![1].withOpacity(0.16),
                  ],
          ) : null,
        ),
        child: Image.asset(
          assetStyle.imgPath!,
        ),
      );
    } else {
      return Container(
        width: size,
        height: size,
        padding: EdgeInsets.all(borderWidth),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: isBorder ? LinearGradient(
            stops: assetStyle.stops,
            colors: [
              assetStyle.gradientColors![0].withOpacity(0.16),
              assetStyle.gradientColors![1].withOpacity(0.16),
            ],
          ) : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  stops: assetStyle.stops,
                  colors: assetStyle.gradientColors!,
                ),
              ),
            ),
            Image.asset(
              'assets/images/tokens/default.png',
            ),
            Text(
              assetStyle.tokenName!,
              style: TextStyle(
                fontSize: tokensHelper.calculateFontSizeFromAssetLogo(assetStyle.tokenName!, size),
                fontWeight: FontWeight.bold,
                color: Color(0xFFFFFFFF),
                letterSpacing: 0.93,
              ),
            ),
          ],
        ),
      );
    }
  }
}
