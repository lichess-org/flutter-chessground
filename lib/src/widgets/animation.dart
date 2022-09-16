import 'package:flutter/material.dart';
import '../models.dart' as cg;
import './piece.dart';

class PieceTranslation extends StatefulWidget {
  const PieceTranslation({
    Key? key,
    required this.child,
    required this.fromCoord,
    required this.toCoord,
    required this.orientation,
    required this.onComplete,
    Duration? duration,
    Curve? curve,
  })  : duration = duration ?? const Duration(milliseconds: 150),
        curve = curve ?? Curves.easeInOutCubic,
        super(key: key);

  final Widget child;
  final cg.Coord fromCoord;
  final cg.Coord toCoord;
  final cg.Color orientation;
  final void Function() onComplete;
  final Duration duration;
  final Curve curve;

  int get orientationFactor => orientation == cg.Color.white ? 1 : -1;
  double get dx => -(toCoord.x - fromCoord.x).toDouble() * orientationFactor;
  double get dy => (toCoord.y - fromCoord.y).toDouble() * orientationFactor;

  @override
  State<PieceTranslation> createState() => _PieceTranslationState();
}

class _PieceTranslationState extends State<PieceTranslation> with SingleTickerProviderStateMixin {
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
  ).animate(CurvedAnimation(
    parent: _controller,
    curve: widget.curve,
  ));

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

class PieceFade extends StatefulWidget {
  const PieceFade({
    Key? key,
    required this.piece,
    required this.size,
    required this.onComplete,
    this.pieceSet,
    Duration? duration,
    Curve? curve,
  })  : duration = duration ?? const Duration(milliseconds: 150),
        curve = curve ?? Curves.easeInQuad,
        super(key: key);

  final cg.Piece piece;
  final double size;
  final cg.PieceSet? pieceSet;
  final Duration duration;
  final Curve curve;
  final void Function() onComplete;

  @override
  State<PieceFade> createState() => _PieceFadeState();
}

class _PieceFadeState extends State<PieceFade> with TickerProviderStateMixin {
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
  ).animate(CurvedAnimation(
    parent: _controller,
    curve: widget.curve,
  ));

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
      animatedOpacity: _animation,
      pieceSet: widget.pieceSet,
    );
  }
}
