import 'dart:async';

import 'package:dartchess/dartchess.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import '../board_color_scheme.dart';
import '../fen.dart';
import '../models.dart';
import '../piece_set.dart';
import 'change_colors.dart';
import 'geometry.dart';
import 'highlight.dart';
import 'piece.dart';
import 'positioned_square.dart';

/// A chessboard widget whose position is static.
///
/// This widget makes use of [Scrollable.recommendDeferredLoadingForContext] to
/// avoid loading pieces when rapidly scrolling.
/// This should allow for a better scrolling experience when displaying a lot of
/// chessboards in a [ListView] or [GridView].
class StaticChessboard extends StatefulWidget with ChessboardGeometry {
  const StaticChessboard({
    required this.size,
    required this.orientation,
    required this.fen,
    this.lastMove,
    this.colorScheme = ChessboardColorScheme.brown,
    this.brightness = 0.0,
    this.hue = 0.0,
    this.pieceAssets = PieceSet.stauntyAssets,
    this.borderRadius = BorderRadius.zero,
    this.boxShadow = const <BoxShadow>[],
    this.enableCoordinates = false,
    super.key,
  });

  /// Size of the board in logical pixels.
  @override
  final double size;

  /// Side by which the board is oriented.
  @override
  final Side orientation;

  /// FEN string describing the position of the board.
  final String fen;

  /// Last move played, used to highlight corresponding squares.
  final Move? lastMove;

  /// Theme of the board
  final ChessboardColorScheme colorScheme;

  /// Brightness adjustment of the board
  final double brightness;

  /// Hue adjustment of the board
  final double hue;

  /// Piece set
  final PieceAssets pieceAssets;

  /// Border radius of the board
  final BorderRadiusGeometry borderRadius;

  /// Box shadow of the board
  final List<BoxShadow> boxShadow;

  /// Whether to show board coordinates
  final bool enableCoordinates;

  @override
  State<StaticChessboard> createState() => _StaticChessboardState();
}

class _StaticChessboardState extends State<StaticChessboard> {
  bool deferImagesLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    verifyRecommendedDeferredLoading();
  }

  void verifyRecommendedDeferredLoading() {
    if (!mounted) return;

    if (Scrollable.recommendDeferredLoadingForContext(context)) {
      deferImagesLoading = true;
      SchedulerBinding.instance.scheduleFrameCallback((_) {
        scheduleMicrotask(() => verifyRecommendedDeferredLoading());
      });
    } else {
      setState(() => deferImagesLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final background = widget.enableCoordinates
        ? widget.orientation == Side.white
            ? widget.colorScheme.whiteCoordBackground
            : widget.colorScheme.blackCoordBackground
        : widget.colorScheme.background;

    final List<Widget> highlightedBackground = [
      SizedBox.square(
        dimension: widget.size,
        child: background,
      ),
      if (widget.lastMove != null)
        for (final square in widget.lastMove!.squares)
          PositionedSquare(
            size: widget.size,
            orientation: widget.orientation,
            square: square,
            child: SquareHighlight(details: widget.colorScheme.lastMove),
          ),
    ];
    final board = SizedBox.square(
      dimension: widget.size,
      child: Stack(
        alignment: Alignment.topLeft,
        clipBehavior: Clip.none,
        children: [
          if (widget.boxShadow.isNotEmpty ||
              widget.borderRadius != BorderRadius.zero)
            Container(
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                borderRadius: widget.borderRadius,
                boxShadow: widget.boxShadow,
              ),
              child: Stack(
                alignment: Alignment.topLeft,
                children: highlightedBackground,
              ),
            )
          else
            ...highlightedBackground,
          if (!deferImagesLoading)
            for (final entry in readFen(widget.fen).entries)
              PositionedSquare(
                size: widget.size,
                orientation: widget.orientation,
                square: entry.key,
                child: PieceWidget(
                  piece: entry.value,
                  size: widget.squareSize,
                  pieceAssets: widget.pieceAssets,
                ),
              ),
        ],
      ),
    );

    return widget.hue != 0 || widget.brightness != 0
        ? ChangeColors(
            hue: widget.hue,
            brightness: widget.brightness,
            child: board,
          )
        : board;
  }
}
