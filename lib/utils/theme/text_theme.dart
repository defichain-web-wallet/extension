part of 'theme.dart';

TextTheme createTextTheme(Color textColor) {
  return TextTheme(
    headline1: headline1,
    headline2: headline2,
    headline3: headline3,
    headline4: headline4,
    headline5: headline5,
    headline6: headline6,
    subtitle1: subtitle1,
    subtitle2: subtitle2,
    button: button,
    bodyText1: bodyText1,
    caption: caption,
  ).apply(
    fontFamily: fontFamily,
    bodyColor: textColor,
    displayColor: textColor,
  );
}