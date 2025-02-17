import 'dart:async';

import 'package:chessground/src/widgets/animation.dart';
import 'package:dartchess/dartchess.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import '../board_color_scheme.dart';
import '../fen.dart';
import '../models.dart';
import '../piece_set.dart';
import 'color_filter.dart';
import 'geometry.dart';
import 'highlight.dart';
import 'piece.dart';
import 'positioned_square.dart';

/// A chessboard widget that cannot be interacted with.
///
/// This widget makes use of [Scrollable.recommendDeferredLoadingForContext] to
/// avoid loading pieces when rapidly scrolling.
/// This should allow for a better scrolling experience when displaying a lot of
/// chessboards in a [ListView] or [GridView].
///
/// The [fen] property is used to describe the position of the board.
/// Pass a new FEN to update the board position. The board will animate the pieces to their new positions.
class StaticChessboard extends StatefulWidget with ChessboardGeometry {
  const StaticChessboard({
    required this.size,
    required this.orientation,
    required this.fen,
    this.lastMove,
    this.colorScheme = ChessboardColorScheme.brown,
    this.brightness = 1.0,
    this.hue = 0.0,
    this.pieceAssets = PieceSet.stauntyAssets,
    this.borderRadius = BorderRadius.zero,
    this.boxShadow = const <BoxShadow>[],
    this.enableCoordinates = false,
    this.animationDuration = const Duration(milliseconds: 200),
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

  /// Piece animation duration
  final Duration animationDuration;

  @override
  State<StaticChessboard> createState() => _StaticChessboardState();
}

class _StaticChessboardState extends State<StaticChessboard> {
  bool deferImagesLoading = false;

  /// Pieces on the board.
  Pieces pieces = {};

  /// Pieces that are currently being translated from one square to another.
  ///
  /// The key is the target square of the piece.
  TranslatingPieces translatingPieces = {};

  /// Pieces that are currently fading out.
  FadingPieces fadingPieces = {};

  @override
  void initState() {
    super.initState();
    pieces = readFen(widget.fen);
  }

  @override
  void didUpdateWidget(covariant StaticChessboard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.fen == widget.fen) {
      return;
    }

    translatingPieces = {};
    fadingPieces = {};

    final newPieces = readFen(widget.fen);

    if (widget.animationDuration > Duration.zero) {
      final (translatingPieces, fadingPieces) = preparePieceAnimations(
        pieces,
        newPieces,
      );
      this.translatingPieces = translatingPieces;
      this.fadingPieces = fadingPieces;
    }

    pieces = newPieces;
  }

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
    final background =
        widget.enableCoordinates
            ? widget.orientation == Side.white
                ? widget.colorScheme.whiteCoordBackground
                : widget.colorScheme.blackCoordBackground
            : widget.colorScheme.background;

    final List<Widget> highlightedBackground = [
      SizedBox.square(dimension: widget.size, child: background),
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
            for (final entry in fadingPieces.entries)
              PositionedSquare(
                size: widget.size,
                orientation: widget.orientation,
                square: entry.key,
                child: AnimatedPieceFadeOut(
                  duration: widget.animationDuration,
                  piece: entry.value,
                  size: widget.squareSize,
                  pieceAssets: widget.pieceAssets,
                  onComplete: () {
                    setState(() {
                      fadingPieces.remove(entry.key);
                    });
                  },
                ),
              ),
          if (!deferImagesLoading)
            for (final entry in pieces.entries)
              if (!translatingPieces.containsKey(entry.key))
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
          if (!deferImagesLoading)
            for (final entry in translatingPieces.entries)
              PositionedSquare(
                size: widget.size,
                orientation: widget.orientation,
                square: entry.key,
                child: AnimatedPieceTranslation(
                  fromSquare: entry.value.from,
                  toSquare: entry.key,
                  orientation: widget.orientation,
                  duration: widget.animationDuration,
                  onComplete: () {
                    setState(() {
                      translatingPieces.remove(entry.key);
                    });
                  },
                  child: PieceWidget(
                    piece: entry.value.piece,
                    size: widget.squareSize,
                    pieceAssets: widget.pieceAssets,
                  ),
                ),
              ),
        ],
      ),
    );

    return BrightnessHueFilter(
      hue: widget.hue,
      brightness: widget.brightness,
      child: board,
    );
  }
}
