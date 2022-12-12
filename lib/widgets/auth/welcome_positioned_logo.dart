import 'package:defi_wallet/widgets/auth/welcome_text_cover.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WelcomePositionedLogo extends StatelessWidget {
  double width;

  WelcomePositionedLogo({
    Key? key,
    this.width = 360,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (width < 360) {
      width = 360;
    }
    return Container(
      width: width,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          Positioned(
            left: -265 + ((width - 360)/2),
            top: 42.0,
            child: WelcomeTextCover(
              '欢迎,Bem-vindo,Witamy,欢迎,Bem-vindo,Witamy',
            ),
          ),
          Positioned(
            left: -310 + ((width - 360)/2),
            top: 90.0,
            child: WelcomeTextCover(
              'Welcome,欢迎,Willkommen,Welcome,欢迎,Willkommen',
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
            left: 0,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 32.5 + ((width - 360)/2)),
              width: 295,
              height: 312,
              child: Image(
                image: AssetImage(
                  'assets/welcome_logo.png',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
