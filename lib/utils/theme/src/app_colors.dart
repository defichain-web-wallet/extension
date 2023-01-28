part of '../theme.dart';

abstract class AppColors {
  static const white = Colors.white;
  static const black = Colors.black;
  static const grey = Colors.grey;
  static const pink = Colors.pink;

  static const blackRock = Color(0xFF12052F);
  static const moonRaker = Color(0xFFDDD2F3);
  static const lavenderPurple = Color(0xFF9988BE);
  static const portage = Color(0xFF9490EA);
  static const portageBg = Color(0xFF9B73EE);
  static const whiteLilac = Color(0xFFEBEDF8);
  static const hollywoodCerise = Color(0xFFFF00A3);
  static const hollywoodCeriseAlpha = Color(0xFFFF00A3);
  static const electricViolet = Color(0xFFBC00C0);
  static const wineBerry = Color(0xFF51153A);
  static const redViolet = Color(0xFFEE1798);
  static const electricVioletAlpha = Color(0xFFBC00C0);
  static const razzmatazz = Color(0xFFEE1771);
  static const purplePizzazz = Color(0xFFFF00E5);
  static const purpleHeart = Color(0xFF6326E4);
  static const malachite = Color(0xff00CF21);
  static const viridian = Color(0xff498F69);
  static const ebony = Color(0xFF120C23);
  static const mirage = Color(0xFF1B162C);

  static const textPrimaryColor = blackRock;

  // input
  static const inputSuffixIconColor = white;

  static const lightGreyColor = Color(0xFFEDEDED);
  static const pinkColor = Color(0xFFFF00A3);
  static const redErrorColor = Color(0xFFD92E2E);
  static const darkTextColor = textPrimaryColor;
  static const shadowColor = Color(0xFF131415);
  static const toogleBgLight = purpleHeart;

  static const darkerGrey = Color(0xFF6C6C6C);
  static const darkestGrey = Color(0xFF626262);
  static const lighterGrey = Color(0xFF959595);
  static const lightGrey = Color(0xFF5d5d5d);

  static const lighterDark = Color(0xFF272727);
  static const lightDark = Color(0xFF1b1b1b);

  static const noSelectLight1 = Color(0xFF9B73EE);
  static const noSelectLight2 = textPrimaryColor;

  static const appSelectorBorderColor = Color(0xFFEFEDF8);
  static const selectLight = portageBg;
  static const appAssetEntryBorder = whiteLilac;

  static const networkMarkColor = Color(0xFF00CF21);

  static const txStatusDone = malachite;
  static const txStatusPending = portage;
  static const txStatusError = razzmatazz;

  static const receivedIconColor = malachite;

  // Circle avatars of accounts. Must be min 10 items
  static const accountColors = [
    Color(0xFFD300AC),
    Color(0xFF30D55F),
    Color(0xFFF06217),
    Color(0xFF2B27CC),
    Color(0xFFD71824),
    Color(0xFFCDBD20),
    Color(0xFF00BFA5),
    Color(0xFF8E24AA),
    Color(0xFF388E3C),
    Color(0xFF827717),
  ];
}