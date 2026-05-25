import 'dart:async';

import 'package:dartchess/dartchess.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import '../board_settings.dart';
import '../fen.dart';
import '../images.dart';
import '../models.dart';
import 'animation.dart';
import 'board_border.dart';
import 'board_painter.dart';
import 'color_filter.dart';
import 'geometry.dart';
import 'highlight.dart';
import 'shape.dart';

/// A chessboard widget that cannot be interacted with (other than an optional
/// [onTouchedSquare] callback).
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
    required double size,
    required this.orientation,
    required this.fen,
    this.lastMove,
    this.settings = const StaticChessboardSettings(),
    this.shapes = const {},
    this.squareHighlights = const {},
    this.onTouchedSquare,
    super.key,
  }) : _size = size;

  /// Visual size of the board, including the optional border.
  final double _size;

  /// Visual size of the board, excluding the optional border.
  @override
  double get size => _size - (settings.border?.width ?? 0) * 2;

  /// Side by which the board is oriented.
  @override
  final Side orientation;

  /// FEN string describing the position of the board.
  final String fen;

  /// Last move played, used to highlight corresponding squares.
  final Move? lastMove;

  /// Visual settings of the board.
  final StaticChessboardSettings settings;

  /// Optional set of [Shape] to be drawn on the board.
  final Set<Shape> shapes;

  /// Squares to highlight on the board.
  final Map<Square, SquareHighlight> squareHighlights;

  /// Called after a square has been touched, with the touched square.
  final void Function(Square)? onTouchedSquare;

  @override
  State<StaticChessboard> createState() => _StaticChessboardState();
}

class _StaticChessboardState extends State<StaticChessboard> with SingleTickerProviderStateMixin {
  bool _deferImagesLoading = false;
  bool _imagesLoaded = false;
  bool _highlightImagesLoaded = false;
  late final BoardHighlightNotifier _highlightNotifier;

  late final ValueNotifier<GameData?> _gameNotifier;
  late final ValueNotifier<Pieces> _piecesNotifier;
  late final ValueNotifier<TranslatingPieces> _translatingPiecesNotifier;
  late final ValueNotifier<FadingPieces> _fadingPiecesNotifier;
  final ValueNotifier<NormalMove?> _noPendingPromotionNotifier = ValueNotifier(null);

  Pieces get pieces => _piecesNotifier.value;
  TranslatingPieces get translatingPieces => _translatingPiecesNotifier.value;
  FadingPieces get fadingPieces => _fadingPiecesNotifier.value;

  late final AnimationController _pieceAnimationController;
  late final CurvedAnimation _translationAnimation;
  late final CurvedAnimation _fadeAnimation;

  StaticChessboardSettings get settings => widget.settings;

  @override
  void initState() {
    super.initState();
    _gameNotifier = ValueNotifier(null);
    _piecesNotifier = ValueNotifier(readFen(widget.fen));
    _translatingPiecesNotifier = ValueNotifier({});
    _fadingPiecesNotifier = ValueNotifier({});
    _pieceAnimationController = AnimationController(
      animationBehavior: AnimationBehavior.preserve,
      duration: settings.animationDuration,
      vsync: this,
    );
    _translationAnimation = CurvedAnimation(
      parent: _pieceAnimationController,
      curve: Curves.easeInOutCubic,
    );
    _fadeAnimation = CurvedAnimation(parent: _pieceAnimationController, curve: Curves.easeInQuad);
    _highlightNotifier =
        BoardHighlightNotifier()..update(
          selected: null,
          moveDests: const {},
          premoveDests: const {},
          occupiedSquares: const {},
          lastMove: settings.showLastMove ? widget.lastMove : null,
          premove: null,
          checkSquare: null,
        );
    _imagesLoaded = ChessgroundImages.instance.isAllLoaded(settings.pieceAssets);
    if (!_imagesLoaded) _loadImages(settings.pieceAssets);
    _highlightImagesLoaded = _areHighlightImagesLoaded();
    if (!_highlightImagesLoaded) _loadHighlightImages();
  }

  Future<void> _loadImages(PieceAssets assets) async {
    final dpr = WidgetsBinding.instance.platformDispatcher.implicitView?.devicePixelRatio;
    await ChessgroundImages.instance.loadAll(assets, devicePixelRatio: dpr);
    if (mounted) setState(() => _imagesLoaded = true);
  }

  bool _areHighlightImagesLoaded() {
    final lastMoveImage = settings.colorScheme.lastMove.image;
    if (lastMoveImage != null && ChessgroundImages.instance.get(lastMoveImage) == null) {
      return false;
    }
    for (final highlight in widget.squareHighlights.values) {
      final image = highlight.details.image;
      if (image != null && ChessgroundImages.instance.get(image) == null) {
        return false;
      }
    }
    return true;
  }

  Future<void> _loadHighlightImages() async {
    final dpr = WidgetsBinding.instance.platformDispatcher.implicitView?.devicePixelRatio;
    final images = <AssetImage>[];
    final lastMoveImage = settings.colorScheme.lastMove.image;
    if (lastMoveImage != null) images.add(lastMoveImage);
    for (final highlight in widget.squareHighlights.values) {
      final image = highlight.details.image;
      if (image != null) images.add(image);
    }
    if (images.isEmpty) return;
    await Future.wait<void>([
      for (final img in images) ChessgroundImages.instance.load(img, devicePixelRatio: dpr),
    ]);
    if (mounted) setState(() => _highlightImagesLoaded = true);
  }

  @override
  void dispose() {
    _gameNotifier.dispose();
    _piecesNotifier.dispose();
    _translatingPiecesNotifier.dispose();
    _fadingPiecesNotifier.dispose();
    _highlightNotifier.dispose();
    _noPendingPromotionNotifier.dispose();
    _fadeAnimation.dispose();
    _translationAnimation.dispose();
    _pieceAnimationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant StaticChessboard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.settings.pieceAssets != settings.pieceAssets) {
      _imagesLoaded = ChessgroundImages.instance.isAllLoaded(settings.pieceAssets);
      if (!_imagesLoaded) _loadImages(settings.pieceAssets);
    }

    if (oldWidget.settings.colorScheme != settings.colorScheme ||
        oldWidget.squareHighlights != widget.squareHighlights) {
      _highlightImagesLoaded = _areHighlightImagesLoaded();
      if (!_highlightImagesLoaded) _loadHighlightImages();
    }

    if (oldWidget.settings.animationDuration != settings.animationDuration) {
      _pieceAnimationController.duration = settings.animationDuration;
    }

    if (oldWidget.lastMove != widget.lastMove ||
        oldWidget.settings.showLastMove != settings.showLastMove) {
      _highlightNotifier.update(
        selected: null,
        moveDests: const {},
        premoveDests: const {},
        occupiedSquares: const {},
        lastMove: settings.showLastMove ? widget.lastMove : null,
        premove: null,
        checkSquare: null,
      );
    }

    if (oldWidget.fen == widget.fen) {
      return;
    }

    _translatingPiecesNotifier.value = {};
    _fadingPiecesNotifier.value = {};

    final newPieces = readFen(widget.fen);

    if (settings.animationDuration > Duration.zero) {
      final (tp, fp) = preparePieceAnimations(pieces, newPieces);
      _translatingPiecesNotifier.value = tp;
      _fadingPiecesNotifier.value = fp;
    }

    if (translatingPieces.isNotEmpty || fadingPieces.isNotEmpty) {
      _pieceAnimationController.forward(from: 0.0);
    } else {
      _pieceAnimationController.stop();
    }

    _piecesNotifier.value = newPieces;
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
    final hasBorder = settings.border != null;

    final background =
        !hasBorder && settings.enableCoordinates
            ? widget.orientation == Side.white
                ? settings.colorScheme.whiteCoordBackground
                : settings.colorScheme.blackCoordBackground
            : settings.colorScheme.background;

    final piecesPainter = PiecesPainter(
      piecesNotifier: _piecesNotifier,
      translatingPiecesNotifier: _translatingPiecesNotifier,
      pieceAssets: settings.pieceAssets,
      squareSize: widget.squareSize,
      orientation: widget.orientation,
      draggedPieceSquareNotifier: null,
      gameNotifier: _gameNotifier,
      pendingPromotionNotifier: _noPendingPromotionNotifier,
      blindfoldMode: settings.blindfoldMode,
      pieceOrientationBehavior: settings.pieceOrientationBehavior,
      imagesLoaded: imagesLoaded,
    );

    final fadingPiecesPainter = FadingPiecesPainter(
      fadingPiecesNotifier: _fadingPiecesNotifier,
      squareSize: widget.squareSize,
      orientation: widget.orientation,
      pieceAssets: settings.pieceAssets,
      blindfoldMode: settings.blindfoldMode,
      pieceOrientationBehavior: settings.pieceOrientationBehavior,
      gameNotifier: _gameNotifier,
      animation: _fadeAnimation,
    );

    final translatingPiecesPainter = TranslatingPiecesPainter(
      translatingPiecesNotifier: _translatingPiecesNotifier,
      squareSize: widget.squareSize,
      orientation: widget.orientation,
      pieceAssets: settings.pieceAssets,
      blindfoldMode: settings.blindfoldMode,
      pieceOrientationBehavior: settings.pieceOrientationBehavior,
      gameNotifier: _gameNotifier,
      animation: _translationAnimation,
    );

    final Map<Square, HighlightDetails> customHighlights = {
      for (final MapEntry(key: square, value: highlight) in widget.squareHighlights.entries)
        square: highlight.details,
    };

    final highlightsPainter = HighlightsPainter(
      interactionNotifier: _highlightNotifier,
      squareSize: widget.squareSize,
      orientation: widget.orientation,
      showLastMove: settings.showLastMove,
      premoveColor: settings.colorScheme.validPremoves,
      lastMoveDetails: settings.colorScheme.lastMove,
      selectedDetails: settings.colorScheme.selected,
      validMoveColor: settings.colorScheme.validMoves,
      squareHighlights: customHighlights,
      highlightImagesLoaded: _highlightImagesLoaded,
    );

    final List<Widget> highlightedBackground = [
      BrightnessHueFilter(
        hue: settings.hue,
        child: SizedBox.square(dimension: widget.size, child: background),
      ),
      CustomPaint(size: Size.square(widget.size), painter: highlightsPainter),
    ];

    Widget board = SizedBox.square(
      key: const ValueKey('board-container'),
      dimension: widget.size,
      child: Stack(
        alignment: Alignment.topLeft,
        clipBehavior: Clip.none,
        children: [
          if (!hasBorder &&
              (settings.boxShadow.isNotEmpty || settings.borderRadius != BorderRadius.zero))
            Container(
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                borderRadius: settings.borderRadius,
                boxShadow: settings.boxShadow,
              ),
              child: Stack(alignment: Alignment.topLeft, children: highlightedBackground),
            )
          else
            ...highlightedBackground,
          CustomPaint(size: Size.square(widget.size), painter: fadingPiecesPainter),
          CustomPaint(size: Size.square(widget.size), painter: piecesPainter),
          CustomPaint(size: Size.square(widget.size), painter: translatingPiecesPainter),
          for (final shape in widget.shapes)
            BoardShapeWidget(shape: shape, size: widget.size, orientation: widget.orientation),
        ],
      ),
    );

    if (widget.onTouchedSquare != null) {
      board = Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (event) {
          final square = widget.offsetSquare(event.localPosition);
          if (square != null) widget.onTouchedSquare!(square);
        },
        child: board,
      );
    }

    if (hasBorder) {
      board = BorderedChessboard(
        size: widget.size,
        orientation: widget.orientation,
        border: settings.border!,
        showCoordinates: settings.enableCoordinates,
        child: board,
      );
    }

    return BrightnessHueFilter(brightness: settings.brightness, child: board);
  }
}
