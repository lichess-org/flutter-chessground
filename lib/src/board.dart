import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';
import 'background.dart';
import 'piece.dart';
import 'models.dart' as cg;
import 'position.dart';
import 'move_animation.dart';
import 'fen.dart';
import 'utils.dart';

const lightSquare = Color(0xfff0d9b6);
const darkSquare = Color(0xffb58863);

@immutable
class Board extends StatefulWidget {
  final double size;

  // board state
  final cg.Color orientation;
  final String fen;

  const Board({
    Key? key,
    required this.size,
    required this.orientation,
    required this.fen,
  }) : super(key: key);

  double get squareSize => size / 8;

  @override
  _BoardState createState() => _BoardState();
}

class _BoardState extends State<Board> {
  late cg.Pieces pieces;
  Map<String, Tuple2<cg.Coord, cg.Coord>> animatedPieces = {};

  @override
  void initState() {
    super.initState();
    pieces = readFen(widget.fen);
  }

  @override
  void didUpdateWidget(Board oldBoard) {
    animatedPieces = {};
    final newPieces = readFen(widget.fen);
    final List<cg.PositionedPiece> newOnSquare = [];
    final List<cg.PositionedPiece> missingOnSquare = [];
    for (final s in allSquares) {
      final oldP = pieces[s];
      final newP = newPieces[s];
      final squareCoord = squareIdToCoord(s);
      if (newP != null) {
        if (oldP != null) {
          if (newP != oldP) {
            missingOnSquare.add(cg.PositionedPiece(
                piece: oldP, squareId: s, coord: squareCoord));
            newOnSquare.add(cg.PositionedPiece(
                piece: newP, squareId: s, coord: squareCoord));
          }
        } else {
          newOnSquare.add(
              cg.PositionedPiece(piece: newP, squareId: s, coord: squareCoord));
        }
      } else if (oldP != null) {
        missingOnSquare.add(
            cg.PositionedPiece(piece: oldP, squareId: s, coord: squareCoord));
      }
    }
    for (final n in newOnSquare) {
      final fromP = closestPiece(
          n, missingOnSquare.where((m) => m.piece == n.piece).toList());
      if (fromP != null) {
        final t = Tuple2<cg.Coord, cg.Coord>(fromP.coord, n.coord);
        animatedPieces[n.squareId] = t;
      }
    }
    pieces = newPieces;
    super.didUpdateWidget(oldBoard);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: widget.size,
      child: Stack(
        children: [
          const Background(lightSquare: lightSquare, darkSquare: darkSquare),
          Stack(
            children: [
              for (final entry in pieces.entries)
                BoardPositioned(
                  size: widget.squareSize,
                  orientation: widget.orientation,
                  squareId: entry.key,
                  child: animatedPieces.containsKey(entry.key)
                      ? MoveAnimation(
                          child: UIPiece(
                            piece: entry.value,
                            size: widget.squareSize,
                          ),
                          fromCoord: animatedPieces[entry.key]!.item1,
                          toCoord: animatedPieces[entry.key]!.item2,
                          orientation: widget.orientation,
                        )
                      : UIPiece(
                          piece: entry.value,
                          size: widget.squareSize,
                        ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
