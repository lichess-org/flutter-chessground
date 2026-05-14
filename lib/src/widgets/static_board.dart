import 'dart:async';

import 'package:dartchess/dartchess.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import '../board_color_scheme.dart';
import '../fen.dart';
import '../images.dart';
import '../models.dart';
import '../piece_set.dart';
import 'animation.dart';
import 'board_painter.dart';
import 'color_filter.dart';
import 'geometry.dart';
import 'highlight.dart';
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

class _StaticChessboardState extends State<StaticChessboard>
    with SingleTickerProviderStateMixin {
  bool _deferImagesLoading = false;
  bool _imagesLoaded = false;

  /// Pieces on the board.
  Pieces pieces = {};

  /// Pieces that are currently being translated from one square to another.
  ///
  /// The key is the target square of the piece.
  TranslatingPieces translatingPieces = {};

  /// Pieces that are currently fading out.
  FadingPieces fadingPieces = {};

  late final AnimationController _pieceAnimationController;
  late final CurvedAnimation _translationAnimation;
  late final CurvedAnimation _fadeAnimation;

  @override
  void initState() {
    super.initState();
    pieces = readFen(widget.fen);
    _pieceAnimationController = AnimationController(
      animationBehavior: AnimationBehavior.preserve,
      duration: widget.animationDuration,
      vsync: this,
    );
    _translationAnimation = CurvedAnimation(
      parent: _pieceAnimationController,
      curve: Curves.easeInOutCubic,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _pieceAnimationController,
      curve: Curves.easeInQuad,
    );
    _imagesLoaded = ChessgroundImages.instance.isAllLoaded(widget.pieceAssets);
    if (!_imagesLoaded) _loadImages(widget.pieceAssets);
  }

  Future<void> _loadImages(PieceAssets assets) async {
    final dpr = WidgetsBinding.instance.platformDispatcher.implicitView?.devicePixelRatio;
    await ChessgroundImages.instance.loadAll(assets, devicePixelRatio: dpr);
    if (mounted) setState(() => _imagesLoaded = true);
  }

  @override
  void dispose() {
    _fadeAnimation.dispose();
    _translationAnimation.dispose();
    _pieceAnimationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant StaticChessboard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.pieceAssets != widget.pieceAssets) {
      _imagesLoaded = ChessgroundImages.instance.isAllLoaded(widget.pieceAssets);
      if (!_imagesLoaded) _loadImages(widget.pieceAssets);
    }

    if (oldWidget.animationDuration != widget.animationDuration) {
      _pieceAnimationController.duration = widget.animationDuration;
    }

    if (oldWidget.fen == widget.fen) {
      return;
    }

    translatingPieces = {};
    fadingPieces = {};

    final newPieces = readFen(widget.fen);

    if (widget.animationDuration > Duration.zero) {
      final (translatingPieces, fadingPieces) = preparePieceAnimations(pieces, newPieces);
      this.translatingPieces = translatingPieces;
      this.fadingPieces = fadingPieces;
    }

    if (translatingPieces.isNotEmpty || fadingPieces.isNotEmpty) {
      _pieceAnimationController.forward(from: 0.0);
    } else {
      _pieceAnimationController.stop();
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
      _deferImagesLoading = true;
      SchedulerBinding.instance.scheduleFrameCallback((_) {
        scheduleMicrotask(() => verifyRecommendedDeferredLoading());
      });
    } else {
      setState(() => _deferImagesLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final imagesLoaded = _imagesLoaded && !_deferImagesLoading;

    final background =
        widget.enableCoordinates
            ? widget.orientation == Side.white
                ? widget.colorScheme.whiteCoordBackground
                : widget.colorScheme.blackCoordBackground
            : widget.colorScheme.background;

    final piecesPainter = PiecesPainter(
      pieces: pieces,
      pieceAssets: widget.pieceAssets,
      squareSize: widget.squareSize,
      orientation: widget.orientation,
      draggedPieceSquare: null,
      translatingPieceSquares: translatingPieces.keys.toSet(),
      promotionMoveFrom: null,
      blindfoldMode: false,
      upsideDownSquares: const {},
      imagesLoaded: imagesLoaded,
    );

    final fadingPiecesPainter = FadingPiecesPainter(
      fadingPieces: fadingPieces,
      squareSize: widget.squareSize,
      orientation: widget.orientation,
      pieceAssets: widget.pieceAssets,
      blindfoldMode: false,
      upsideDownSquares: const {},
      animation: _fadeAnimation,
    );

    final translatingPiecesPainter = TranslatingPiecesPainter(
      translatingPieces: translatingPieces,
      squareSize: widget.squareSize,
      orientation: widget.orientation,
      pieceAssets: widget.pieceAssets,
      blindfoldMode: false,
      upsideDownSquares: const {},
      animation: _translationAnimation,
    );

    final List<Widget> highlightedBackground = [
      RepaintBoundary(
        child: BrightnessHueFilter(
          hue: widget.hue,
          child: SizedBox.square(dimension: widget.size, child: background),
        ),
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
          if (widget.boxShadow.isNotEmpty || widget.borderRadius != BorderRadius.zero)
            Container(
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                borderRadius: widget.borderRadius,
                boxShadow: widget.boxShadow,
              ),
              child: Stack(alignment: Alignment.topLeft, children: highlightedBackground),
            )
          else
            ...highlightedBackground,
          RepaintBoundary(
            child: SizedBox.square(
              key: const ValueKey('board-fading-pieces'),
              dimension: widget.size,
              child: CustomPaint(painter: fadingPiecesPainter),
            ),
          ),
          RepaintBoundary(
            child: SizedBox.square(
              key: const ValueKey('board-pieces'),
              dimension: widget.size,
              child: CustomPaint(painter: piecesPainter),
            ),
          ),
          RepaintBoundary(
            child: SizedBox.square(
              key: const ValueKey('board-translating-pieces'),
              dimension: widget.size,
              child: CustomPaint(painter: translatingPiecesPainter),
            ),
          ),
        ],
      ),
    );

    return RepaintBoundary(
      child: BrightnessHueFilter(brightness: widget.brightness, child: board),
    );
  }
}
