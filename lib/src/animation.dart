import 'package:flutter/material.dart';
import 'models.dart' as cg;

class PieceTranslation extends StatefulWidget {
  final Widget child;
  final cg.Coord fromCoord;
  final cg.Coord toCoord;
  final cg.Color orientation;
  final Duration duration;
  final Curve curve;

  const PieceTranslation({
    Key? key,
    required this.child,
    required this.fromCoord,
    required this.toCoord,
    required this.orientation,
    Duration? duration,
    Curve? curve,
  })  : duration = duration ?? const Duration(milliseconds: 150),
        curve = curve ?? Curves.easeInOutCubic,
        super(key: key);

  int get orientationFactor => orientation == cg.Color.white ? 1 : -1;
  double get dx => -(toCoord.x - fromCoord.x).toDouble() * orientationFactor;
  double get dy => (toCoord.y - fromCoord.y).toDouble() * orientationFactor;

  @override
  State<PieceTranslation> createState() => _PieceTranslationState();
}

class _PieceTranslationState extends State<PieceTranslation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: widget.duration,
    vsync: this,
  )..forward();
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

class PieceFading extends StatefulWidget {
  final Widget child;

  const PieceFading({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<PieceFading> createState() => _PieceFadingState();
}

class _PieceFadingState extends State<PieceFading>
    with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 200),
    vsync: this,
  )..reverse();
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInCubic,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: widget.child,
    );
  }
}
