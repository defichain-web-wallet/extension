part of '../theme.dart';

ThemeData createDarkTheme() {
  return ThemeData(
    snackBarTheme: SnackBarThemeData(
      backgroundColor: Color(0xff333436),
      actionTextColor: Colors.white,
    ),
    primaryColorLight: Color(0xFF545556),
    selectedRowColor: AppColors.portageBg,
    backgroundColor: Color(0xff333436),
    secondaryHeaderColor: Color(0xff333436),
    scaffoldBackgroundColor: DarkColors.scaffoldBgColor,
    dialogBackgroundColor: Color(0xFF1C1D1F),
    shadowColor: Colors.transparent,
    cardColor: Colors.white.withOpacity(0.04),
    colorScheme: ColorScheme.dark(
      primary: AppColors.pinkColor,
      primaryVariant: AppColors.pinkColor,
    ),
    iconTheme: IconThemeData(
      color: Colors.white,
    ),
    textTheme: createTextTheme(AppColors.white),
    listTileTheme: ListTileThemeData(
      selectedColor: Colors.white.withOpacity(0.06),
      tileColor: Colors.white.withOpacity(0.05),
    ),
    drawerTheme: DrawerThemeData(
      backgroundColor: DarkColors.drawerBgColor,
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        textStyle: MaterialStatePropertyAll(button),
        padding: MaterialStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        ),
        shape: MaterialStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(buttonBorderRadius),
            ),
            side: BorderSide(
              color: Colors.transparent,
            ),
          ),
        ),
        backgroundColor: MaterialStatePropertyAll(
          AppColors.purplePizzazz.withOpacity(0.1),
        ),
        shadowColor: MaterialStatePropertyAll(Colors.transparent),
      ),
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
