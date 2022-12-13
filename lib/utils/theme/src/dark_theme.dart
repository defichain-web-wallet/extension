part of '../theme.dart';

ThemeData createDarkTheme() {
  return ThemeData(
    snackBarTheme: SnackBarThemeData(
      backgroundColor: Color(0xff333436),
      actionTextColor: Colors.white,
    ),
    primaryColorLight: Color(0xFF545556),
    backgroundColor: Color(0xff333436),
    secondaryHeaderColor: Color(0xff333436),
    scaffoldBackgroundColor: AppColors.shadowColor,
    dialogBackgroundColor: Color(0xFF1C1D1F),
    selectedRowColor: Color(0xFF2A83C4),
    shadowColor: Colors.transparent,
    cardColor: Color(0xff333436),
    colorScheme: ColorScheme.dark(
      primary: AppColors.pinkColor,
      primaryVariant: AppColors.pinkColor,
    ),
    iconTheme: IconThemeData(
      color: Colors.white,
    ),
    textTheme: createTextTheme(AppColors.white),
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
          fontFamily: "RedHatDisplay",
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
        shadowColor: Colors.black.withOpacity(0.35),
        elevation: 8,
      ),
    ),
    dividerColor: Color(0xFFffffff),
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: Color(0xff333436),
      shadowColor: Colors.black.withOpacity(0.35),
      titleTextStyle:
      TextStyle(color: Colors.white, fontFamily: 'RedHatDisplay'),
      actionsIconTheme: IconThemeData(
        color: Colors.white,
      ),
      foregroundColor: Colors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(inputBorderRadius),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(inputBorderRadius),
        borderSide: BorderSide(
          width: 1,
          color: Color(0xFFF0EEF6),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(inputBorderRadius),
        borderSide: BorderSide(
          width: 1,
          color: AppColors.pinkColor,
        ),
      ),
      fillColor: Color(0xFFF6F4FC),
    ),
    textSelectionTheme:
    TextSelectionThemeData(selectionColor: Color(0xFFF0F0F0)),
  );
}