part of '../theme.dart';

ThemeData createLightTheme() {
  return ThemeData(
    snackBarTheme: SnackBarThemeData(
      backgroundColor: Colors.white,
      actionTextColor: Colors.black,
    ),
    scaffoldBackgroundColor: LightColors.scaffoldBgColor,
    dialogBackgroundColor: Color(0xffFAFAFA),
    primaryColorLight: Color(0xFF5D5D5D),
    selectedRowColor: AppColors.portageBg,
    shadowColor: AppColors.darkTextColor.withOpacity(0.08),
    cardColor: Colors.white,
    backgroundColor: LightColors.cardColor,
    secondaryHeaderColor: AppColors.lightGreyColor,
    colorScheme: ColorScheme.light(
      primary: AppColors.pinkColor
    ),
    iconTheme: IconThemeData(
      color: Colors.black,
    ),
    textTheme: createTextTheme(AppColors.darkTextColor),
    listTileTheme: ListTileThemeData(
      selectedColor: Colors.white,
      tileColor: AppColors.appAssetEntryBorder,
    ),
    drawerTheme: DrawerThemeData(
      backgroundColor: LightColors.drawerBgColor,
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        textStyle: MaterialStatePropertyAll(button),
        padding: MaterialStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
        shadowColor: Colors.black.withOpacity(0.35),
        elevation: 8,
      ),
    ),
    dividerColor: AppColors.darkTextColor,
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
      hoverColor: Colors.transparent,
      contentPadding:
          const EdgeInsets.symmetric(vertical: 2.0, horizontal: 10.0),
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
      hintStyle: TextStyle(
        color: AppColors.blackRock.withOpacity(0.3),
      ),
      fillColor: Colors.white.withOpacity(0.65),
    ),
    textSelectionTheme: TextSelectionThemeData(
      selectionColor: LightColors.inputTextSelectionColor,
    ),
  ).copyWith(splashColor: Colors.transparent);
}
