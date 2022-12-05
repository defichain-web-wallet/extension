part of '../theme.dart';

const fontFamily = "IBM Plex Sans";

const headline1 = TextStyle(fontWeight: FontWeight.w400, fontSize: 30);
const headline2 = TextStyle(fontWeight: FontWeight.w400, fontSize: 16);
const headline3 = TextStyle(fontWeight: FontWeight.w400, fontSize: 14);
const headline4 = TextStyle(fontWeight: FontWeight.w400, fontSize: 14);
const headline5 = TextStyle(fontWeight: FontWeight.w400, fontSize: 14);
const headline6 = TextStyle(fontWeight: FontWeight.w400, fontSize: 14);

const subtitle1 = TextStyle(fontWeight: FontWeight.w400, fontSize: 12);
const subtitle2 = TextStyle(fontWeight: FontWeight.w400, fontSize: 9);

const button = TextStyle(fontWeight: FontWeight.w400, fontSize: 14, decorationColor: Color(0xff545556));

const bodyText1 = TextStyle(fontWeight: FontWeight.w400, fontSize: 19, decorationColor: Color(0xff545556));

const caption = TextStyle(fontWeight: FontWeight.w400, fontSize: 11, decorationColor: Color(0xff12052F));

abstract class AppColors {
  static const white = Colors.white;
  static const black = Colors.black;
  static const grey = Colors.grey;
  static const pink = Colors.pink;

  static const lightGreyColor = Color(0xffEDEDED);
  static const pinkColor = Color(0xffFF00A3);
  static const redErrorColor = Color(0xffD92E2E);
  static const darkTextColor = Color(0xff132235);
  static const shadowColor = Color(0xff131415);

  static const darkerGrey = Color(0xFF6C6C6C);
  static const darkestGrey = Color(0xFF626262);
  static const lighterGrey = Color(0xFF959595);
  static const lightGrey = Color(0xFF5d5d5d);

  static const lighterDark = Color(0xFF272727);
  static const lightDark = Color(0xFF1b1b1b);
}