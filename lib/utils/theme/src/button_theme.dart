part of '../theme.dart';

OutlinedButtonThemeData createButtonTheme(Color textColor) {
  return OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      textStyle: button,
      padding: const EdgeInsets.symmetric(
        horizontal: 22,
        vertical: 16,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(buttonBorderRadius),
        ),
        side: BorderSide(
          color: Colors.transparent,
        ),
      ),
      backgroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
    ),
  );
}
