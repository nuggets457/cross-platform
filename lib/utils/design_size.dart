import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Uses a 1080 x 2400 reference canvas to scale spacing and sizing
/// proportionally across different phone sizes.
class DesignSize {
  static const double referenceWidth = 1080;
  static const double referenceHeight = 2400;

  static double w(BuildContext context, double value) {
    final width = MediaQuery.of(context).size.width;
    return value * (width / referenceWidth);
  }

  static double h(BuildContext context, double value) {
    final height = MediaQuery.of(context).size.height;
    return value * (height / referenceHeight);
  }

  static double r(BuildContext context, double value) {
    return math.min(w(context, value), h(context, value));
  }
}
