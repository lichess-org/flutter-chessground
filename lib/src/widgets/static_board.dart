import 'dart:async';

import 'package:dartchess/dartchess.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import '../board_color_scheme.dart';
import '../board_settings.dart';
import '../fen.dart';
import '../images.dart';
import '../models.dart';
import '../piece_set.dart';
import 'animation.dart';
import 'board_painter.dart';
import 'color_filter.dart';
import 'geometry.dart';

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
    this.pieceAssets = PieceSet.cburnettAssets,
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

  @override
  void initState() {
    super.initState();
    _gameNotifier = ValueNotifier(null);
    _piecesNotifier = ValueNotifier(readFen(widget.fen));
    _translatingPiecesNotifier = ValueNotifier({});
    _fadingPiecesNotifier = ValueNotifier({});
    _pieceAnimationController = AnimationController(
      animationBehavior: AnimationBehavior.preserve,
      duration: widget.animationDuration,
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
          lastMove: widget.lastMove,
          premove: null,
          checkSquare: null,
        );
    _imagesLoaded = ChessgroundImages.instance.isAllLoaded(widget.pieceAssets);
    if (!_imagesLoaded) _loadImages(widget.pieceAssets);
    _highlightImagesLoaded = _areHighlightImagesLoaded();
    if (!_highlightImagesLoaded) _loadHighlightImages();
  }

  Future<void> _loadImages(PieceAssets assets) async {
    final dpr = WidgetsBinding.instance.platformDispatcher.implicitView?.devicePixelRatio;
    await ChessgroundImages.instance.loadAll(assets, devicePixelRatio: dpr);
    if (mounted) setState(() => _imagesLoaded = true);
  }

  bool _areHighlightImagesLoaded() {
    final image = widget.colorScheme.lastMove.image;
    return image == null || ChessgroundImages.instance.get(image) != null;
  }

  Future<void> _loadHighlightImages() async {
    final image = widget.colorScheme.lastMove.image;
    if (image == null) return;
    final dpr = WidgetsBinding.instance.platformDispatcher.implicitView?.devicePixelRatio;
    await ChessgroundImages.instance.load(image, devicePixelRatio: dpr);
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

    if (oldWidget.pieceAssets != widget.pieceAssets) {
      _imagesLoaded = ChessgroundImages.instance.isAllLoaded(widget.pieceAssets);
      if (!_imagesLoaded) _loadImages(widget.pieceAssets);
    }

    if (oldWidget.colorScheme != widget.colorScheme) {
      _highlightImagesLoaded = _areHighlightImagesLoaded();
      if (!_highlightImagesLoaded) _loadHighlightImages();
    }

    if (oldWidget.animationDuration != widget.animationDuration) {
      _pieceAnimationController.duration = widget.animationDuration;
    }

    if (oldWidget.lastMove != widget.lastMove) {
      _highlightNotifier.update(
        selected: null,
        moveDests: const {},
        premoveDests: const {},
        occupiedSquares: const {},
        lastMove: widget.lastMove,
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

    if (widget.animationDuration > Duration.zero) {
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

    final background =
        widget.enableCoordinates
            ? widget.orientation == Side.white
                ? widget.colorScheme.whiteCoordBackground
                : widget.colorScheme.blackCoordBackground
            : widget.colorScheme.background;

    final piecesPainter = PiecesPainter(
      piecesNotifier: _piecesNotifier,
      translatingPiecesNotifier: _translatingPiecesNotifier,
      pieceAssets: widget.pieceAssets,
      squareSize: widget.squareSize,
      orientation: widget.orientation,
      draggedPieceSquareNotifier: null,
      gameNotifier: _gameNotifier,
      pendingPromotionNotifier: _noPendingPromotionNotifier,
      blindfoldMode: false,
      pieceOrientationBehavior: PieceOrientationBehavior.facingUser,
      imagesLoaded: imagesLoaded,
    );

    final fadingPiecesPainter = FadingPiecesPainter(
      fadingPiecesNotifier: _fadingPiecesNotifier,
      squareSize: widget.squareSize,
      orientation: widget.orientation,
      pieceAssets: widget.pieceAssets,
      blindfoldMode: false,
      pieceOrientationBehavior: PieceOrientationBehavior.facingUser,
      gameNotifier: _gameNotifier,
      animation: _fadeAnimation,
    );

    final translatingPiecesPainter = TranslatingPiecesPainter(
      translatingPiecesNotifier: _translatingPiecesNotifier,
      squareSize: widget.squareSize,
      orientation: widget.orientation,
      pieceAssets: widget.pieceAssets,
      blindfoldMode: false,
      pieceOrientationBehavior: PieceOrientationBehavior.facingUser,
      gameNotifier: _gameNotifier,
      animation: _translationAnimation,
    );

    final highlightsPainter = HighlightsPainter(
      interactionNotifier: _highlightNotifier,
      squareSize: widget.squareSize,
      orientation: widget.orientation,
      showLastMove: true,
      premoveColor: widget.colorScheme.validPremoves,
      lastMoveDetails: widget.colorScheme.lastMove,
      selectedDetails: widget.colorScheme.selected,
      validMoveColor: widget.colorScheme.validMoves,
      squareHighlights: const {},
      highlightImagesLoaded: _highlightImagesLoaded,
    );

    final List<Widget> highlightedBackground = [
      BrightnessHueFilter(
        hue: widget.hue,
        child: SizedBox.square(dimension: widget.size, child: background),
      ),
      CustomPaint(size: Size.square(widget.size), painter: highlightsPainter),
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
          CustomPaint(size: Size.square(widget.size), painter: fadingPiecesPainter),
          CustomPaint(size: Size.square(widget.size), painter: piecesPainter),
          CustomPaint(size: Size.square(widget.size), painter: translatingPiecesPainter),
        ],
      ),
    );

    return BrightnessHueFilter(brightness: widget.brightness, child: board);
  }
}
