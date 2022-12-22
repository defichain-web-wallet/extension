import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LogoHelper {
  Widget getLogo() {
    return SvgPicture.asset(
      SettingsHelper.settings.theme == 'Light'
          ? 'assets/jelly_logo.svg'
          : 'assets/jelly_logo_dark.svg',
    );
  }
}
