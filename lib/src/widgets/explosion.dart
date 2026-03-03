import 'dart:math' as math;
import 'package:flutter/widgets.dart';

/// A widget that renders a procedurally-generated explosion animation.
///
/// Used to visualize atomic chess captures, where pieces surrounding a capture
/// square explode.
class ExplosionWidget extends StatefulWidget {
  /// Creates an [ExplosionWidget].
  ///
  /// [size] is the width/height of the animation canvas (typically the square
  /// size of the board, but can be larger for an overflow effect).
  /// [onComplete] is called when the animation has finished.
  const ExplosionWidget({
    super.key,
    required this.size,
    required this.onComplete,
    this.duration = const Duration(milliseconds: 600),
  });

  /// Width and height of the animation canvas.
  final double size;

  /// Called when the animation completes.
  final void Function() onComplete;

  /// Total duration of the explosion animation.
  final Duration duration;

  @override
  State<ExplosionWidget> createState() => _ExplosionWidgetState();
}

class _ExplosionWidgetState extends State<ExplosionWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onComplete();
        }
      })
      ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder:
          (context, _) => CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _ExplosionPainter(_controller.value),
          ),
    );
  }
}

/// Custom painter that draws the explosion at a given progress value [t] ∈ [0, 1].
class _ExplosionPainter extends CustomPainter {
  final double t;

  // Pre-defined particle data: (angle in radians, radial speed factor, size scale)
  // 12 particles distributed around the circle with slight variation.
  static const List<(double, double, double)> _particles = [
    (0.0, 1.00, 1.00),
    (math.pi / 6, 0.88, 0.85),
    (math.pi / 3, 0.96, 0.92),
    (math.pi / 2, 0.80, 1.10),
    (2 * math.pi / 3, 1.06, 0.82),
    (5 * math.pi / 6, 0.91, 0.95),
    (math.pi, 0.85, 1.00),
    (7 * math.pi / 6, 1.01, 0.80),
    (4 * math.pi / 3, 0.78, 0.90),
    (3 * math.pi / 2, 0.94, 1.05),
    (5 * math.pi / 3, 1.08, 0.83),
    (11 * math.pi / 6, 0.87, 1.00),
  ];

  _ExplosionPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    // maxR is half the canvas width — particles will fly to this radius.
    final maxR = size.width * 0.5;

    // 1. Central flash: pale-yellow circle that expands and fades in the first 30%.
    if (t < 0.3) {
      final ft = t / 0.3;
      canvas.drawCircle(
        center,
        maxR * 0.55 * ft,
        Paint()..color = Color.fromRGBO(255, 255, 210, (1.0 - ft) * 0.88),
      );
    }

    // 2. Fireball: orange/red circle that expands to ~75% of maxR then fades.
    final fireOpacity = (1.0 - t * 1.65).clamp(0.0, 1.0);
    if (fireOpacity > 0) {
      final expandT = Curves.easeOut.transform((t * 1.8).clamp(0.0, 1.0));
      final r = maxR * 0.75 * expandT;
      // Outer fireball body.
      canvas.drawCircle(
        center,
        r,
        Paint()..color = Color.fromRGBO(255, 70, 0, fireOpacity * 0.88),
      );
      // Brighter inner core.
      canvas.drawCircle(
        center,
        r * 0.52,
        Paint()..color = Color.fromRGBO(255, 215, 0, fireOpacity * 0.78),
      );
    }

    // 3. Expanding ring of fire that fades as it grows.
    final ringOpacity = (0.70 - t * 0.90).clamp(0.0, 1.0);
    if (ringOpacity > 0) {
      final ringR = maxR * 0.96 * t;
      canvas.drawCircle(
        center,
        ringR,
        Paint()
          ..color = Color.fromRGBO(255, 105, 0, ringOpacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.width * 0.075 * (1.0 - t * 0.6),
      );
    }

    // 4. Particles: small circles that fly outward from the center.
    for (final (i, (angle, speed, sizeScale)) in _particles.indexed) {
      // Stagger particle launch slightly (0–12 % delay based on index).
      final delay = (i % 4) * 0.04;
      final pt = ((t - delay) / (1.0 - delay)).clamp(0.0, 1.0);
      if (pt <= 0) continue;

      final opacity = (1.0 - pt * 1.45).clamp(0.0, 1.0);
      if (opacity <= 0) continue;

      final dist = maxR * speed * _easeOut(pt);
      final x = center.dx + math.cos(angle) * dist;
      final y = center.dy + math.sin(angle) * dist;
      final particleR = size.width * 0.055 * sizeScale * (1.0 - pt * 0.45);

      // Alternate particle colours: deep orange, amber, orange, crimson.
      final color = switch (i % 4) {
        0 => Color.fromRGBO(255, 60, 0, opacity),
        1 => Color.fromRGBO(255, 195, 0, opacity),
        2 => Color.fromRGBO(255, 125, 20, opacity),
        _ => Color.fromRGBO(215, 30, 0, opacity),
      };

      canvas.drawCircle(Offset(x, y), particleR, Paint()..color = color);
    }
  }

  /// Ease-out quadratic: decelerates towards end.
  double _easeOut(double t) => 1.0 - math.pow(1.0 - t, 2.0).toDouble();

  @override
  bool shouldRepaint(_ExplosionPainter oldDelegate) => t != oldDelegate.t;
}
