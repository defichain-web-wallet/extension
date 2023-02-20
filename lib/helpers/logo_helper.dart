import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LogoHelper {
  Widget getLogo() {
    return SvgPicture.asset(
      'assets/jelly_logo.svg'
    );
  }
}
