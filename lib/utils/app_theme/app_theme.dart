import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static const Color pinkColor = Color(0xffFF00A3);
  static const Color redErrorColor = Color(0xffD92E2E);
  static const Color lightGreyColor = Color(0xffEDEDED);
  static const Color darkTextColor = Color(0xff132235);
  static const Color shadowColor = Color(0xff131415);

  static const String mainFontFamily = 'Roboto';

  // Текст - ссылка в стиле DEFI (розовая с нижним подчеркиванием)
  static TextStyle get defiUnderlineText {
    return TextStyle(
      color: pinkColor,
      decorationColor: pinkColor,
      fontFamily: mainFontFamily,
      fontSize: 12,
      fontWeight: FontWeight.w500,
      decoration: TextDecoration.underline,
    );
  }

  // Кнопка в стиле DEFI (розовая)
  static ButtonStyle get defiButton {
    return ElevatedButton.styleFrom(
      primary: pinkColor,
      onPrimary: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      textStyle: TextStyle(
        color: Colors.white,
        fontFamily: mainFontFamily,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
      shadowColor: Colors.black.withOpacity(0.35),
      elevation: 8,
    );
  }

  // Светлая тема
  static ThemeData get lightTheme {
    return ThemeData(
      snackBarTheme: SnackBarThemeData(
        backgroundColor: Colors.white,
        actionTextColor: Colors.black,
      ),
      scaffoldBackgroundColor: Color(0xffFAFAFA),
      dialogBackgroundColor: Color(0xffFFFFFF),
      selectedRowColor: Color(0xFFFAFAFA),
      shadowColor: Colors.grey[300]!,
      cardColor: Colors.white,
      backgroundColor: Colors.white,
      secondaryHeaderColor: lightGreyColor,
      colorScheme: ColorScheme.light(
        primary: pinkColor,
        primaryVariant: pinkColor,
      ),
      iconTheme: IconThemeData(
        color: Colors.black,
      ),
      textTheme: TextTheme(
        headline1: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.normal,
        ),
        headline2: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
        headline3: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
        headline4: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
        headline5: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
        headline6: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
        subtitle1: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
        subtitle2: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          decoration: TextDecoration.underline,
        ),
        button: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          decorationColor: Colors.transparent,
        ),
        bodyText1: TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.normal,
          decorationColor: Colors.grey.withOpacity(0.3),
        ),
      ).apply(
        fontFamily: mainFontFamily,
        bodyColor: darkTextColor,
        displayColor: darkTextColor,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          primary: Colors.white,
          onPrimary: darkTextColor,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: lightGreyColor,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: TextStyle(
            color: darkTextColor,
            fontFamily: mainFontFamily,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          shadowColor: Colors.black.withOpacity(0.35),
          elevation: 8,
        ),
      ),
      dividerColor: Color(0xFFEDEDED),
      appBarTheme: AppBarTheme(
        elevation: 5,
        backgroundColor: Colors.white,
        shadowColor: Colors.black.withOpacity(0.35),
        titleTextStyle: TextStyle(
          color: darkTextColor,
        ),
        actionsIconTheme: IconThemeData(
          color: darkTextColor,
        ),
        foregroundColor: Color(0xFFEDEDED),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  // Темная тема
  static ThemeData get darkTheme {
    return ThemeData(
      snackBarTheme: SnackBarThemeData(
        backgroundColor: Color(0xff333436),
        actionTextColor: Colors.white,
      ),
      backgroundColor: Color(0xff333436),
      secondaryHeaderColor: Color(0xff333436),
      scaffoldBackgroundColor: AppTheme.shadowColor,
      dialogBackgroundColor: Color(0xFF1C1D1F),
      selectedRowColor: Color(0xFF1C1D1F),
      shadowColor: Colors.transparent,
      cardColor: Color(0xff1C1D1F),
      colorScheme: ColorScheme.dark(
        primary: pinkColor,
        primaryVariant: pinkColor,
      ),
      iconTheme: IconThemeData(
        color: Colors.white,
      ),
      textTheme: TextTheme(
        headline1: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.bold,
        ),
        headline2: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        headline3: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        headline4: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
        headline5: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
        headline6: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        subtitle1: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        subtitle2: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          decoration: TextDecoration.underline,
        ),
        button: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          decorationColor: Color(0xff545556),
        ),
        bodyText1: TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.bold,
          decorationColor: Colors.grey.withOpacity(0.7),
        ),
      ).apply(
        fontFamily: mainFontFamily,
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          primary: Color(0xff1C1D1F),
          onPrimary: Colors.white,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: Colors.white,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: TextStyle(
            color: Colors.white,
            fontFamily: mainFontFamily,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          shadowColor: Colors.black.withOpacity(0.35),
          elevation: 8,
        ),
      ),
      dividerColor: Color(0xFF545556),
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: Color(0xff333436),
        shadowColor: Colors.black.withOpacity(0.35),
        titleTextStyle: TextStyle(
          color: Colors.white,
        ),
        actionsIconTheme: IconThemeData(
          color: Colors.white,
        ),
        foregroundColor: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
