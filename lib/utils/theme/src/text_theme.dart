part of '../theme.dart';

TextTheme createTextTheme(Color textColor) {
  return TextTheme(
    headline1: applyGeneralColor(headline1, textColor),
    headline2: headline2.apply(color: AppColors.moonRaker),
    headline3: applyGeneralColor(headline3, textColor),
    headline4: applyGeneralColor(headline4, textColor),
    headline5: applyGeneralColor(headline5, textColor),
    headline6: applyGeneralColor(headline6, textColor),
    subtitle1: applyGeneralColor(subtitle1, textColor),
    subtitle2: applyGeneralColor(subtitle2, textColor),
    button: button,
    bodyText1: bodyText1,
    caption: caption,
  ).apply(
    fontFamily: fontFamily,
  );
}

TextStyle applyGeneralColor(TextStyle textStyle, Color color) =>
    textStyle.apply(color: color);
