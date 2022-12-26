import 'package:defi_wallet/widgets/auth/welcome_text_cover.dart';
import 'package:flutter/material.dart';

class WelcomePositionedLogo extends StatelessWidget {
  final double width;
  final double imgWidth;
  final double titleSpace;
  final String title;

  WelcomePositionedLogo({
    Key? key,
    this.width = 360,
    this.imgWidth = 295,
    this.titleSpace = 310,
    this.title = 'Welcome',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    late double screenWidth;

    if (width < 360) {
      screenWidth = 360;
    } else {
      screenWidth = width;
    }

    return Container(
      width: screenWidth,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          Positioned(
            left: -265 + ((screenWidth - 360)/2),
            top: 42.0,
            child: WelcomeTextCover(
              '欢迎,Bem-vindo,Witamy,欢迎,Bem-vindo,Witamy',
            ),
          ),
          Positioned(
            left: -titleSpace + ((screenWidth - 360)/2),
            top: 90.0,
            child: WelcomeTextCover(
              'Welcome,欢迎,Willkommen,$title,欢迎,Willkommen',
              wordSelectId: 3,
            ),
          ),
          Positioned(
            left: -370 + ((width - 360)/2),
            top: 136.0,
            child: WelcomeTextCover(
              'Bonjour,Benvenuto,어서 오십시오,Bonjour,Benvenuto,어서 오십시오',
            ),
          ),
          Positioned(
            top: 120,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 32.5 + ((screenWidth - 360)/2)),
                width: imgWidth,
                child: Image(
                  image: AssetImage(
                    'assets/welcome_logo.png',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
