import 'package:dartchess/dartchess.dart';
import 'package:flutter/widgets.dart';

import '../board_settings.dart';
import 'color_filter.dart';
import 'geometry.dart';
import 'board.dart';

const _coordStyle = TextStyle(
  inherit: false,
  fontWeight: FontWeight.bold,
  fontSize: 12.0,
  fontFamily: 'Roboto',
  height: 1.0,
  color: Color(0x99FFFFFF),
);

/// A bordered chessboard widget.
///
/// This widget displays a chessboard with a border around it.
///
/// In order to not display the coordinates twice, it is the responsibility of
/// the parent widget to remove coordinates in the wrapped [Chessboard].
class BorderedChessboard extends StatelessWidget with ChessboardGeometry {
  const BorderedChessboard({
    required this.size,
    required this.orientation,
    required this.border,
    required this.child,
    this.showCoordinates = true,
    this.borderRadius = BorderRadius.zero,
    this.boxShadow = const <BoxShadow>[],
    this.brightness = 1.0,
    this.contrast = 1.0,
    this.hue = 0.0,
    super.key,
  });

  @override
  final double size;

  @override
  final Side orientation;

  /// The border of the board.
  final BoardBorder border;

  /// The board child widget. Typically a [Chessboard].
  final Widget child;

  /// Whether to show coordinates on the border.
  final bool showCoordinates;

  /// Radius of the outer corners of the border.
  final BorderRadiusGeometry borderRadius;

  /// Shadow cast by the border.
  final List<BoxShadow> boxShadow;

  /// Brightness filter applied to the border color, as for the board background.
  ///
  /// See [ColorAdjustFilter.brightness].
  final double brightness;

  /// Contrast filter applied to the border color, as for the board background.
  ///
  /// See [ColorAdjustFilter.contrast].
  final double contrast;

  /// Hue filter applied to the border color, as for the board background.
  ///
  /// See [ColorAdjustFilter.hue].
  final double hue;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size + border.width * 2,
      height: size + border.width * 2,
      decoration: BoxDecoration(borderRadius: borderRadius, boxShadow: boxShadow),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: borderRadius,
              child: ColorAdjustFilter(
                brightness: brightness,
                contrast: contrast,
                hue: hue,
                child: ColoredBox(color: border.color),
              ),
            ),
          ),
          child,
          if (showCoordinates)
            Positioned(
              top: border.width,
              left: 0,
              child: _BorderRankCoordinates(
                orientation: orientation,
                width: border.width,
                height: size,
              ),
            ),
          if (showCoordinates)
            Positioned(
              bottom: 0,
              left: border.width,
              child: _BorderFileCoordinates(
                orientation: orientation,
                width: size,
                height: border.width,
              ),
            ),
        ],
      ),
    );
  }
}

/// A widget that displays the rank coordinates of a chess board.
class _BorderRankCoordinates extends StatelessWidget {
  const _BorderRankCoordinates({
    required this.orientation,
    required this.width,
    required this.height,
  });

  final Side orientation;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final ranks = orientation == Side.white ? '87654321' : '12345678';
    return SizedBox(
      width: width,
      height: height,
      child: Column(
        textDirection: TextDirection.ltr,
        children: [
          for (final rank in ranks.split(''))
            Expanded(
              child: Center(
                child: Text(
                  rank,
                  style: _coordStyle,
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.ltr,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// A widget that displays the file coordinates of a chess board.
class _BorderFileCoordinates extends StatelessWidget {
  const _BorderFileCoordinates({
    required this.orientation,
    required this.width,
    required this.height,
  });

  final Side orientation;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final files = orientation == Side.white ? 'abcdefgh' : 'hgfedcba';
    return SizedBox(
      height: height,
      width: width,
      child: Row(
        textDirection: TextDirection.ltr,
        children: [
          for (final file in files.split(''))
            Expanded(
              child: Center(
                child: Text(
                  file,
                  style: _coordStyle,
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.ltr,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
