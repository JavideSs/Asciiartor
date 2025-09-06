import "package:flutter/material.dart";

class Responsive{
  final BuildContext context;
  final Size size;

  Responsive(this.context) : size = MediaQuery.of(context).size;

  double get width => size.width;
  double get height => size.height;

  bool get isSmall => width < 600;
  bool get isMedium => width >= 600 && width < 1200;
  bool get isLarge => width >= 1200;

  double wp(double percent) => width * percent / 100;

  double hp(double percent) => height * percent / 100;

  double sr(double size) => size * (isMedium ? 1.0 : isSmall ? 0.8 : 1.2);
}