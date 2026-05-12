import 'package:flutter/material.dart';

class Responsive {
  final BuildContext context;
  Responsive(this.context);

  Size get _size => MediaQuery.of(context).size;
  double get w => _size.width;
  double get h => _size.height;

  bool get isPhone => w < 600;
  bool get isTablet => w >= 600 && w < 1024;
  bool get isDesktop => w >= 1024;

  double clamp(double min, double value, double max) =>
      value < min ? min : (value > max ? max : value);

  double featuredCardHeight() => clamp(220, h * 0.32, 360);
  double featuredCardWidth() => clamp(240, w * 0.78, 420);
  double featuredImageHeight() => clamp(140, h * 0.20, 220);

  double serviceTileHeight() => clamp(150, h * 0.18, 220);
  double serviceTileWidth() => clamp(160, w * 0.45, 240);
}
