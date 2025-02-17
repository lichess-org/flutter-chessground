import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Change the brightness and hue of the child widget.
///
/// The brightness and hue are applied to the child widget using a [ColorFilter].
class BrightnessHueFilter extends StatelessWidget {
  const BrightnessHueFilter({
    this.brightness = 1.0,
    this.hue = 0.0,
    required this.child,
    super.key,
  });

  /// Apply a linear multiplier to the child, making it appear brighter or darker.
  ///
  /// A value under 1.0 darkens the Widget, while a value over 1.0 brightens it.
  /// A value of 0.0 will make it completely black.
  /// Default value is 1.0.
  final double brightness;

  /// Rotates the hue of the child by the given angle in degrees.
  ///
  /// A positive hue rotation increases the hue value, while a negative rotation decreases the hue value.
  /// Default value is 0.0.
  final double hue;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (brightness == 1.0 && hue == 0.0) {
      return child;
    }
    List<double> matrix = _baseMatrix;
    if (brightness != 1.0) {
      matrix = _brightnessFilter(matrix, value: brightness);
    }
    if (hue != 0.0) {
      matrix = _hueFilter(matrix, value: hue);
    }
    return ColorFiltered(
      colorFilter: ColorFilter.matrix(matrix.sublist(0, 20)),
      child: child,
    );
  }
}

List<double> _brightnessFilter(List<double> matrix, {required double value}) {
  return _multiplyMatrix5(matrix, <double>[
    // dart format off
    value, 0, 0, 0, 0,
    0, value, 0, 0, 0,
    0, 0, value, 0, 0,
    0, 0, 0, 1, 0,
    0, 0, 0, 0, 1,
    // dart format on
  ]);
}

/// Check: https://stackoverflow.com/questions/64639589/how-to-adjust-hue-saturation-and-brightness-of-an-image-in-flutter
List<double> _hueFilter(List<double> matrix, {required double value}) {
  final double v = math.pi * (value / 180.0);
  final double cosVal = math.cos(v);
  final double sinVal = math.sin(v);
  const double lumR = 0.213;
  const double lumG = 0.715;
  const double lumB = 0.072;

  return _multiplyMatrix5(matrix, <double>[
    (lumR + (cosVal * (1 - lumR))) + (sinVal * (-lumR)),
    (lumG + (cosVal * (-lumG))) + (sinVal * (-lumG)),
    (lumB + (cosVal * (-lumB))) + (sinVal * (1 - lumB)),
    0,
    0,
    (lumR + (cosVal * (-lumR))) + (sinVal * 0.143),
    (lumG + (cosVal * (1 - lumG))) + (sinVal * 0.14),
    (lumB + (cosVal * (-lumB))) + (sinVal * (-0.283)),
    0,
    0,
    (lumR + (cosVal * (-lumR))) + (sinVal * (-(1 - lumR))),
    (lumG + (cosVal * (-lumG))) + (sinVal * lumG),
    (lumB + (cosVal * (1 - lumB))) + (sinVal * lumB),
    0,
    0,
    0,
    0,
    0,
    1,
    0,
    0,
    0,
    0,
    0,
    1,
  ]);
}

const List<double> _baseMatrix = [
  // dart format off
  1, 0, 0, 0, 0,
  0, 1, 0, 0, 0,
  0, 0, 1, 0, 0,
  0, 0, 0, 1, 0,
  0, 0, 0, 0, 1,
  // dart format on
];

/// Check: https://github.com/openkraken/kraken/blob/main/kraken/lib/src/css/filter.dart
/// Calc 5x5 matrix multiplication.
List<double> _multiplyMatrix5(List<double> a, List<double> b) {
  if (a.length != b.length) {
    throw ArgumentError('Matrix length should be same.');
  }

  if (a.length != 25) {
    throw ArgumentError('Matrix5 size is not correct.');
  }

  final a00 = a[0];
  final a01 = a[1];
  final a02 = a[2];
  final a03 = a[3];
  final a04 = a[4];
  final a10 = a[5];
  final a11 = a[6];
  final a12 = a[7];
  final a13 = a[8];
  final a14 = a[9];
  final a20 = a[10];
  final a21 = a[11];
  final a22 = a[12];
  final a23 = a[13];
  final a24 = a[14];
  final a30 = a[15];
  final a31 = a[16];
  final a32 = a[17];
  final a33 = a[18];
  final a34 = a[19];
  final a40 = a[20];
  final a41 = a[21];
  final a42 = a[22];
  final a43 = a[23];
  final a44 = a[24];

  final b00 = b[0];
  final b01 = b[1];
  final b02 = b[2];
  final b03 = b[3];
  final b04 = b[4];
  final b10 = b[5];
  final b11 = b[6];
  final b12 = b[7];
  final b13 = b[8];
  final b14 = b[9];
  final b20 = b[10];
  final b21 = b[11];
  final b22 = b[12];
  final b23 = b[13];
  final b24 = b[14];
  final b30 = b[15];
  final b31 = b[16];
  final b32 = b[17];
  final b33 = b[18];
  final b34 = b[19];
  final b40 = b[20];
  final b41 = b[21];
  final b42 = b[22];
  final b43 = b[23];
  final b44 = b[24];

  return [
    // dart format off
    a00 * b00 + a01 * b10 + a02 * b20 + a03 * b30 + a04 * b40,
    a00 * b01 + a01 * b11 + a02 * b21 + a03 * b31 + a04 * b41,
    a00 * b02 + a01 * b12 + a02 * b22 + a03 * b32 + a04 * b42,
    a00 * b03 + a01 * b13 + a02 * b23 + a03 * b33 + a04 * b43,
    a00 * b04 + a01 * b14 + a02 * b24 + a03 * b34 + a04 * b44,
    a10 * b00 + a11 * b10 + a12 * b20 + a13 * b30 + a14 * b40,
    a10 * b01 + a11 * b11 + a12 * b21 + a13 * b31 + a14 * b41,
    a10 * b02 + a11 * b12 + a12 * b22 + a13 * b32 + a14 * b42,
    a10 * b03 + a11 * b13 + a12 * b23 + a13 * b33 + a14 * b43,
    a10 * b04 + a11 * b14 + a12 * b24 + a13 * b34 + a14 * b44,
    a20 * b00 + a21 * b10 + a22 * b20 + a23 * b30 + a24 * b40,
    a20 * b01 + a21 * b11 + a22 * b21 + a23 * b31 + a24 * b41,
    a20 * b02 + a21 * b12 + a22 * b22 + a23 * b32 + a24 * b42,
    a20 * b03 + a21 * b13 + a22 * b23 + a23 * b33 + a24 * b43,
    a20 * b04 + a21 * b14 + a22 * b24 + a23 * b34 + a24 * b44,
    a30 * b00 + a31 * b10 + a32 * b20 + a33 * b30 + a34 * b40,
    a30 * b01 + a31 * b11 + a32 * b21 + a33 * b31 + a34 * b41,
    a30 * b02 + a31 * b12 + a32 * b22 + a33 * b32 + a34 * b42,
    a30 * b03 + a31 * b13 + a32 * b23 + a33 * b33 + a34 * b43,
    a30 * b04 + a31 * b14 + a32 * b24 + a33 * b34 + a34 * b44,
    a40 * b00 + a41 * b10 + a42 * b20 + a43 * b30 + a44 * b40,
    a40 * b01 + a41 * b11 + a42 * b21 + a43 * b31 + a44 * b41,
    a40 * b02 + a41 * b12 + a42 * b22 + a43 * b32 + a44 * b42,
    a40 * b03 + a41 * b13 + a42 * b23 + a43 * b33 + a44 * b43,
    a40 * b04 + a41 * b14 + a42 * b24 + a43 * b34 + a44 * b44,
    // dart format on
  ];
}
