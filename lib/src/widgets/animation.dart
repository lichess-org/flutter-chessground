import 'package:flutter/widgets.dart';
import '../models.dart';
import './piece.dart';

@Deprecated('Use AnimatedPieceTranslation instead')
typedef PieceTranslation = AnimatedPieceTranslation;

/// A widget that animates the translation of a piece from one square to another.
///
/// The piece will move from [fromCoord] to [toCoord] with the given [orientation].
/// When the animation completes, [onComplete] will be called.
/// The animation duration and curve can be customized.
class AnimatedPieceTranslation extends StatefulWidget {
  /// Creates an [AnimatedPieceTranslation] widget.
  const AnimatedPieceTranslation({
    super.key,
    required this.child,
    required this.fromCoord,
    required this.toCoord,
    required this.orientation,
    required this.onComplete,
    Duration? duration,
    Curve? curve,
  })  : duration = duration ?? const Duration(milliseconds: 150),
        curve = curve ?? Curves.easeInOutCubic;

  /// The widget to animate. Typically a [PieceWidget].
  final Widget child;

  /// The coordinate of the square the piece is moving from.
  final Coord fromCoord;

  /// The coordinate of the square the piece is moving to.
  final Coord toCoord;

  /// The orientation of the board.
  final Side orientation;

  /// Called when the animation completes.
  final void Function() onComplete;

  /// The duration of the animation.
  final Duration duration;

  /// The curve of the animation.
  final Curve curve;

  int get orientationFactor => orientation == Side.white ? 1 : -1;
  double get dx => -(toCoord.x - fromCoord.x).toDouble() * orientationFactor;
  double get dy => (toCoord.y - fromCoord.y).toDouble() * orientationFactor;

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

@Deprecated('Use AnimatedPieceFadeOut instead')
typedef PieceFadeOut = AnimatedPieceFadeOut;

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
