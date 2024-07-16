import 'dart:async';
import 'package:flutter/widgets.dart';
import '../models.dart';

/// A widget that displays an annotation of a square on the board.
///
/// This is typically used to display move annotations, such as "!!" or "??".
class BoardAnnotation extends StatefulWidget {
  const BoardAnnotation({
    required this.annotation,
    required this.squareSize,
    required this.orientation,
    required this.squareId,
    super.key,
  });

  final Annotation annotation;
  final double squareSize;
  final Side orientation;
  final SquareId squareId;

  @override
  State<BoardAnnotation> createState() => _BoardAnnotationState();
}

class _BoardAnnotationState extends State<BoardAnnotation> {
  bool show = true;
  double scale = 0.1;

  Timer? timer;

  @override
  void initState() {
    super.initState();
    if (widget.annotation.duration != null) {
      timer = Timer(widget.annotation.duration!, () {
        setState(() {
          show = false;
        });
      });
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        scale = 1.0;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final squareOffset = Coord.fromSquareId(widget.squareId)
        .offset(widget.orientation, widget.squareSize);
    final size = widget.squareSize * 0.48;
    final onRightEdge = widget.orientation == Side.white
        ? widget.squareId[0] == 'h'
        : widget.squareId[0] == 'a';
    final offset = squareOffset.translate(
      onRightEdge
          ? widget.squareSize - (size * 0.9)
          : widget.squareSize - (size * 0.7),
      -(size * 0.3),
    );
    return Positioned(
      width: size,
      height: size,
      left: offset.dx,
      top: offset.dy,
      child: Opacity(
        opacity: show ? 1.0 : 0.0,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 150),
          scale: scale,
          child: Container(
            padding: const EdgeInsets.all(2.0),
            decoration: BoxDecoration(
              color: widget.annotation.color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF000000).withOpacity(0.5),
                  blurRadius: 1,
                  offset: const Offset(1, 1),
                ),
              ],
            ),
            child: FittedBox(
              child: Center(
                child: Text(
                  widget.annotation.symbol,
                  style: const TextStyle(
                    color: Color(0xFFFFFFFF),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
