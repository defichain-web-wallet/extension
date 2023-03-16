import 'package:flutter/material.dart';

class AssetStyleModel {
  String? tokenName;
  String? imgPath;
  bool? isUniqueLogo;
  double? rotateRadian;
  List<Color>? gradientColors;
  List<double>? stops;

  AssetStyleModel({
    this.tokenName,
    this.imgPath,
    this.isUniqueLogo,
    this.gradientColors,
    this.rotateRadian,
    this.stops,
  });
}
