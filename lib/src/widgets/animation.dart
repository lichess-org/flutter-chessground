import 'package:dartchess/dartchess.dart';
import 'package:flutter/widgets.dart';
import '../models.dart';
import './piece.dart';

/// A Map of the pieces that are being translated on the board.
///
/// The keys are the squares the pieces are moving to, and the values are the pieces and the squares they are moving from.
typedef TranslatingPieces = Map<Square, ({Piece piece, Square from})>;

/// A Map of the pieces that are being faded out on the board.
///
/// Corresponds to the pieces that are no longer on the board after a position change.
typedef FadingPieces = Map<Square, Piece>;

/// Returns the pieces that need to be animated by comparing the old and new positions.
(TranslatingPieces, FadingPieces) preparePieceAnimations(
  Pieces oldPosition,
  Pieces newPosition, {
  NormalMove? lastDrop,
}) {
  final Map<Square, ({Piece piece, Square from})> translatingPieces = {};
  final Map<Square, Piece> fadingPieces = {};
  final List<(Piece, Square)> newOnSquare = [];
  final List<(Piece, Square)> missingOnSquare = [];
  final Set<Square> animatedOrigins = {};
  for (final s in Square.values) {
    if (s == lastDrop?.from || s == lastDrop?.to) {
      continue;
    }
    final oldP = oldPosition[s];
    final newP = newPosition[s];
    if (newP != null) {
      if (oldP != null) {
        if (newP != oldP) {
          missingOnSquare.add((oldP, s));
          newOnSquare.add((newP, s));
        }
      } else {
        newOnSquare.add((newP, s));
      }
    } else if (oldP != null) {
      missingOnSquare.add((oldP, s));
    }
  }
  for (final (newPiece, newPieceSquare) in newOnSquare) {
    // find the closest square that the piece was on before
    final fromSquare = _closestSquare(
      newPieceSquare,
      missingOnSquare.where((m) => m.$1 == newPiece).map((e) => e.$2),
    );
    if (fromSquare != null) {
      translatingPieces[newPieceSquare] = (piece: newPiece, from: fromSquare);
      animatedOrigins.add(fromSquare);
    }
  }
  for (final (missingPiece, missingPieceSquare) in missingOnSquare) {
    if (!animatedOrigins.contains(missingPieceSquare)) {
      fadingPieces[missingPieceSquare] = missingPiece;
    }
  }

  return (translatingPieces, fadingPieces);
}

/// Returns the closest square to the target square from a list of squares.
Square? _closestSquare(Square square, Iterable<Square> squares) {
  if (squares.isEmpty) return null;
  return squares.reduce((a, b) {
    final aDist = _distanceSq(square, a);
    final bDist = _distanceSq(square, b);
    return aDist < bDist ? a : b;
  });
}

int _distanceSq(Square pos1, Square pos2) {
  final dx = pos1.file - pos2.file;
  final dy = pos1.rank - pos2.rank;
  return dx * dx + dy * dy;
}

/// A widget that animates the translation of a piece from one square to another.
///
/// The piece will move from [fromSquare] to [toSquare] with the given [orientation].
/// When the animation completes, [onComplete] will be called.
/// The animation duration and curve can be customized.
class AnimatedPieceTranslation extends StatefulWidget {
  /// Creates an [AnimatedPieceTranslation] widget.
  const AnimatedPieceTranslation({
    super.key,
    required this.child,
    required this.fromSquare,
    required this.toSquare,
    required this.orientation,
    required this.onComplete,
    Duration? duration,
    Curve? curve,
  })  : duration = duration ?? const Duration(milliseconds: 150),
        curve = curve ?? Curves.easeInOutCubic;

  /// The widget to animate. Typically a [PieceWidget].
  final Widget child;

  /// The square the piece is moving from.
  final Square fromSquare;

  /// The square the piece is moving to.
  final Square toSquare;

  /// The orientation of the board.
  final Side orientation;

  /// Called when the animation completes.
  final void Function() onComplete;

  /// The duration of the animation.
  final Duration duration;

  /// The curve of the animation.
  final Curve curve;

  int get orientationFactor => orientation == Side.white ? 1 : -1;
  double get dx =>
      -(toSquare.file - fromSquare.file).toDouble() * orientationFactor;
  double get dy =>
      (toSquare.rank - fromSquare.rank).toDouble() * orientationFactor;

  @override
  State<AnimatedPieceTranslation> createState() => _PieceTranslationState();
}

class _PieceTranslationState extends State<AnimatedPieceTranslation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: widget.duration,
    vsync: this,
  )
    ..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete();
      }
    })
    ..forward();
  late final Animation<Offset> _offsetAnimation = Tween<Offset>(
    begin: Offset(widget.dx, widget.dy),
    end: Offset.zero,
  ).animate(
    CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: widget.child,
    );
  }
}

/// A widget that plays a fade out animation on a piece.
class AnimatedPieceFadeOut extends StatefulWidget {
  /// Creates an [AnimatedPieceFadeOut] widget.
  const AnimatedPieceFadeOut({
    super.key,
    required this.piece,
    required this.size,
    required this.onComplete,
    required this.pieceAssets,
    this.blindfoldMode = false,
    this.upsideDown = false,
    Duration? duration,
    Curve? curve,
  })  : duration = duration ?? const Duration(milliseconds: 150),
        curve = curve ?? Curves.easeInQuad;

  /// The piece to fade out.
  final Piece piece;

  /// The size of the piece.
  final double size;

  /// The assets used to render the piece.
  final PieceAssets pieceAssets;

  /// If `true` the piece will be hidden.
  final bool blindfoldMode;

  /// If `true` the piece will be displayed upside down.
  final bool upsideDown;

  /// The duration of the animation.
  final Duration duration;

  /// The curve of the animation.
  final Curve curve;

  /// Called when the animation completes.
  final void Function() onComplete;

  @override
  State<AnimatedPieceFadeOut> createState() => _PieceFadeOutState();
}

class _PieceFadeOutState extends State<AnimatedPieceFadeOut>
    with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: widget.duration,
    vsync: this,
  )
    ..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete();
      }
    })
    ..forward();
  late final Animation<double> _animation = Tween<double>(
    begin: 1.0,
    end: 0.0,
  ).animate(
    CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PieceWidget(
      piece: widget.piece,
      size: widget.size,
      opacity: _animation,
      pieceAssets: widget.pieceAssets,
      blindfoldMode: widget.blindfoldMode,
      upsideDown: widget.upsideDown,
    );
  }
}
