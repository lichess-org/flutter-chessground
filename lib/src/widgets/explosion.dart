import 'dart:math' as math;

import 'package:dartchess/dartchess.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/widgets.dart';

class _ActiveExplosion {
  final Square square;
  final AnimationController controller;
  _ActiveExplosion(this.square, this.controller);
  double get progress => controller.value;
}

/// Manages active explosion animations, notifying listeners on every frame tick.
class ExplosionSetNotifier extends ChangeNotifier {
  static const _defaultDuration = Duration(milliseconds: 600);

  final TickerProvider _vsync;
  final Duration _duration;
  final List<_ActiveExplosion> _active = [];

  ExplosionSetNotifier({required TickerProvider vsync, Duration duration = _defaultDuration})
    : _vsync = vsync,
      _duration = duration;

  int get activeExplosionCount => _active.length;

  void trigger(ISet<Square> squares) {
    for (final square in squares) {
      final ctrl = AnimationController(duration: _duration, vsync: _vsync);
      final explosion = _ActiveExplosion(square, ctrl);
      _active.add(explosion);
      ctrl.addListener(notifyListeners);
      ctrl.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _active.remove(explosion);
          ctrl.removeListener(notifyListeners);
          ctrl.dispose();
          notifyListeners();
        }
      });
      ctrl.forward();
    }
  }

  @override
  void dispose() {
    for (final e in _active) {
      e.controller.removeListener(notifyListeners);
      e.controller.dispose();
    }
    super.dispose();
  }
}

/// Paints all active explosion animations onto a full-board canvas.
class ExplosionsPainter extends CustomPainter {
  final ExplosionSetNotifier notifier;
  final double squareSize;
  final Side orientation;

  ExplosionsPainter({required this.notifier, required this.squareSize, required this.orientation})
    : super(repaint: notifier);

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

  @override
  void paint(Canvas canvas, Size size) {
    for (final explosion in notifier._active) {
      final file =
          orientation == Side.white ? explosion.square.file.value : 7 - explosion.square.file.value;
      final rank =
          orientation == Side.white ? 7 - explosion.square.rank.value : explosion.square.rank.value;
      final center = Offset((file + 0.5) * squareSize, (rank + 0.5) * squareSize);
      // 0.75 × squareSize = half of 1.5× squareSize, matching the previous OverflowBox radius.
      _paintExplosion(canvas, center, squareSize * 0.75, explosion.progress);
    }
  }

  @override
  bool shouldRepaint(ExplosionsPainter old) =>
      old.squareSize != squareSize || old.orientation != orientation;

  static void _paintExplosion(Canvas canvas, Offset center, double maxR, double t) {
    final diameter = maxR * 2;

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
      canvas.drawCircle(center, r, Paint()..color = Color.fromRGBO(255, 70, 0, fireOpacity * 0.88));
      canvas.drawCircle(
        center,
        r * 0.52,
        Paint()..color = Color.fromRGBO(255, 215, 0, fireOpacity * 0.78),
      );
    }

    // 3. Expanding ring of fire that fades as it grows.
    final ringOpacity = (0.70 - t * 0.90).clamp(0.0, 1.0);
    if (ringOpacity > 0) {
      canvas.drawCircle(
        center,
        maxR * 0.96 * t,
        Paint()
          ..color = Color.fromRGBO(255, 105, 0, ringOpacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = diameter * 0.075 * (1.0 - t * 0.6),
      );
    }

    // 4. Particles: small circles that fly outward from the center.
    for (final (i, (angle, speed, sizeScale)) in _particles.indexed) {
      final delay = (i % 4) * 0.04;
      final pt = ((t - delay) / (1.0 - delay)).clamp(0.0, 1.0);
      if (pt <= 0) continue;

      final opacity = (1.0 - pt * 1.45).clamp(0.0, 1.0);
      if (opacity <= 0) continue;

      final dist = maxR * speed * _easeOut(pt);
      final particleR = diameter * 0.055 * sizeScale * (1.0 - pt * 0.45);

      final color = switch (i % 4) {
        0 => Color.fromRGBO(255, 60, 0, opacity),
        1 => Color.fromRGBO(255, 195, 0, opacity),
        2 => Color.fromRGBO(255, 125, 20, opacity),
        _ => Color.fromRGBO(215, 30, 0, opacity),
      };

      canvas.drawCircle(
        Offset(center.dx + math.cos(angle) * dist, center.dy + math.sin(angle) * dist),
        particleR,
        Paint()..color = color,
      );
    }
  }

  static double _easeOut(double t) => 1.0 - math.pow(1.0 - t, 2.0).toDouble();
}
