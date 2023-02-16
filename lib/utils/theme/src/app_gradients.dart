part of '../theme.dart';

LinearGradient historyTypeIconGradient = LinearGradient(
  transform: GradientRotation(3.4),
  stops: [0.5, 100],
  colors: [
    AppColors.pinkColor.withOpacity(0.15),
    AppColors.electricViolet.withOpacity(0.15),
  ],
);

getGradient(
  Color firstColor,
  Color secondColor, {
  bool isOpasity = false,
}) {
  return LinearGradient(
    transform: GradientRotation(3.4),
    stops: [0.0817, 0.9243],
    colors: isOpasity ? [
      firstColor.withOpacity(0.15),
      secondColor.withOpacity(0.15),
    ] : [
      firstColor,
      secondColor,
    ],
  );
}
