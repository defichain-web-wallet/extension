import 'package:defi_wallet/helpers/tokens_helper.dart';
import 'package:flutter/material.dart';

class AssetLogo extends StatelessWidget {
  final String tokenName;
  final double size;
  final bool isBorder;
  final double borderWidth;

  AssetLogo({
    Key? key,
    required this.tokenName,
    this.size = 42,
    this.borderWidth = 5,
    this.isBorder = true,
  }) : super(key: key);

  TokensHelper tokensHelper = TokensHelper();

  @override
  Widget build(BuildContext context) {
    if (tokensHelper.getImagePathByTokenName(tokenName) != null) {
      return Container(
        width: size,
        height: size,
        padding: EdgeInsets.all(borderWidth),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: isBorder ? LinearGradient(
            transform: tokensHelper.getDegRotateByTokenName(tokenName) != null
                ? GradientRotation(tokensHelper.getDegRotateByTokenName(tokenName)!)
                : null,
            stops: tokensHelper.getStopsByTokenName(tokenName),
            colors: tokenName == 'DUSD'
                ? [
              tokensHelper.getColorsByTokenName(tokenName)[0].withOpacity(0.1),
              tokensHelper.getColorsByTokenName(tokenName)[1].withOpacity(0.1),
                  ]
                : [
              tokensHelper.getColorsByTokenName(tokenName)[0].withOpacity(0.16),
              tokensHelper.getColorsByTokenName(tokenName)[1].withOpacity(0.16),
                  ],
          ) : null,
        ),
        child: Image.asset(
          tokensHelper.getImagePathByTokenName(tokenName)!,
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
            stops: tokensHelper.getStopsByTokenName(tokenName),
            colors: [
              tokensHelper.getColorsByTokenName(tokenName)[0].withOpacity(0.16),
              tokensHelper.getColorsByTokenName(tokenName)[1].withOpacity(0.16),
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
                  stops: tokensHelper.getStopsByTokenName(tokenName),
                  colors: tokensHelper.getColorsByTokenName(tokenName),
                ),
              ),
            ),
            Image.asset(
              'assets/images/tokens/default.png',
            ),
            Text(
              tokenName,
              style: TextStyle(
                fontSize: (tokenName.length < 4)
                    ? ((8 * size) / 50)
                    : (tokenName.length == 4)
                        ? ((7 * size) / 50)
                        : ((5 * size) / 50),
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
