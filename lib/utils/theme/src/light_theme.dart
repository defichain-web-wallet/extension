part of '../theme.dart';

ThemeData createLightTheme() {
  return ThemeData(
    snackBarTheme: SnackBarThemeData(
      backgroundColor: Colors.white,
      actionTextColor: Colors.black,
    ),
    scaffoldBackgroundColor: Color(0xffEDEDED),
    dialogBackgroundColor: Color(0xffFAFAFA),
    primaryColorLight: Color(0xFF5D5D5D),
    selectedRowColor: Color(0xFFFAFAFA),
    shadowColor: Colors.grey[300]!,
    cardColor: Colors.white,
    backgroundColor: Colors.white,
    secondaryHeaderColor: AppColors.lightGreyColor,
    colorScheme: ColorScheme.light(
      primary: AppColors.pinkColor,
      primaryVariant: AppColors.pinkColor,
    ),
    iconTheme: IconThemeData(
      color: Colors.black,
    ),
    textTheme: createTextTheme(AppColors.darkTextColor),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        primary: Colors.white,
        onPrimary: AppColors.darkTextColor,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: AppColors.lightGreyColor,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        textStyle: TextStyle(
          color: AppColors.darkTextColor,
          fontFamily: 'RedHatDisplay',
          fontSize: 16,
          fontWeight: FontWeight.normal,
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
        color: AppColors.darkTextColor,
      ),
      actionsIconTheme: IconThemeData(
        color: AppColors.darkTextColor,
      ),
      foregroundColor: Color(0xFFEDEDED),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          width: 1,
          color: Color(0xFFF0EEF6),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          width: 1,
          color: AppColors.pinkColor,
        ),
      ),
      fillColor: Color(0xFFF6F4FC),
    ),
    textSelectionTheme:
        TextSelectionThemeData(selectionColor: Color(0xFF7D7D7D)),
  ).copyWith(splashColor: Colors.transparent);
}
