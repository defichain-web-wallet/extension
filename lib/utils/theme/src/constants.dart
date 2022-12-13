part of '../theme.dart';

const fontFamily = "RedHatDisplay";

const double buttonHeight = 48.0;
const double buttonSmallWidth = 280.0;
const double buttonFullWidth = double.infinity;
const double boxSmallWidth = 312;
const double boxFullWidth = double.infinity;
const double buttonBorderRadius = 12.0;
const double inputBorderRadius = 12.0;


const headline1 = TextStyle(fontWeight: FontWeight.w900, fontSize: 32);
const headline2 = TextStyle(fontWeight: FontWeight.w900, fontSize: 28);
const headline3 = TextStyle(fontWeight: FontWeight.w700, fontSize: 26);
const headline4 = TextStyle(fontWeight: FontWeight.w700, fontSize: 18);
const headline5 = TextStyle(fontWeight: FontWeight.w600, fontSize: 14);
const headline6 = TextStyle(fontWeight: FontWeight.w600, fontSize: 16);

const subtitle1 = TextStyle(fontWeight: FontWeight.w400, fontSize: 13);
const subtitle2 = TextStyle(fontWeight: FontWeight.w400, fontSize: 9);

const button = TextStyle(
  fontWeight: FontWeight.w600,
  fontSize: 14,
);

const bodyText1 = TextStyle(
  fontWeight: FontWeight.w400,
  fontSize: 14,
  decorationColor: Color(0xff545556),
);

const bodyText2 = TextStyle(
  fontWeight: FontWeight.w400,
  fontSize: 13,
);

const caption = TextStyle(
  fontWeight: FontWeight.w400,
  height: 1.5,
  fontSize: 9,
  decorationColor: Color(0xff12052F),
);

const authPaddingContainer = const EdgeInsets.only(
  top: 32,
  bottom: 24,
  left: 24,
  right: 24,
);

final jellyLink = TextStyle(
  color: AppColors.pinkColor,
  decorationColor: AppColors.pinkColor,
  fontSize: 12,
  fontWeight: FontWeight.w400,
  fontFamily: fontFamily,
);

const passwordField = TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.w600,
);

const gradientButton = LinearGradient(
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
  colors: [
    AppColors.electricViolet,
    AppColors.hollywoodCerise,
  ],
);

const gradientBottomToUpCenter = LinearGradient(
  begin: Alignment.bottomCenter,
  end: Alignment.topCenter,
  colors: [
    AppColors.electricViolet,
    AppColors.hollywoodCerise,
  ],
);

const gradientWrongMnemonicWord = LinearGradient(
  begin: Alignment.bottomCenter,
  end: Alignment.topCenter,
  colors: [
    AppColors.redViolet,
    AppColors.razzmatazz,
  ],
  transform: GradientRotation(4.7),
);

const gradientGray = LinearGradient(
  colors: [
    AppColors.electricViolet,
    AppColors.hollywoodCerise,
  ],
);

LinearGradient gradientDisableButton = LinearGradient(
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
  colors: [
    AppColors.pinkColor.withOpacity(0.3),
    AppColors.electricViolet.withOpacity(0.3),
  ],
  transform: GradientRotation(4.7),
);

const noSelectBorder = Border(
  top: BorderSide(color: AppColors.noSelectLight1),
  bottom: BorderSide(color: AppColors.noSelectLight1),
  left: BorderSide(color: AppColors.noSelectLight1),
  right: BorderSide(color: AppColors.noSelectLight1),
);
