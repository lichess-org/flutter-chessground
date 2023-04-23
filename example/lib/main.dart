import 'dart:math';
import 'package:flutter/material.dart';
import 'package:chessground/chessground.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart'
    hide Tuple2;
import 'package:dartchess/dartchess.dart' as dc;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chessground Demo',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.blueGrey,
      ),
      home: const MyHomePage(title: 'Chessground Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  dc.Position<dc.Chess> position = dc.Chess.initial;
  Side orientation = Side.white;
  String fen = dc.kInitialBoardFEN;
  Move? lastMove;
  ValidMoves validMoves = IMap(const {});
  Side sideToMove = Side.white;
  PieceSet pieceSet = PieceSet.merida;
  BoardTheme boardTheme = BoardTheme.blue;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Board(
              size: screenWidth,
              settings: BoardSettings(
                pieceAssets: pieceSet.assets,
                colorScheme: boardTheme.colors,
                enableCoordinates: true,
                enablePremoves: true,
              ),
              data: BoardData(
                interactableSide: InteractableSide.white,
                validMoves: validMoves,
                orientation: orientation,
                fen: fen,
                lastMove: lastMove,
                shapes: ISet<Shape>({
                  Shape(orig: 'd2', dest: 'd3', color: Color(0xFF003088)),
                  Shape(orig: 'g1', dest: 'f3', color: Color(0xFF003088)),
                  Shape(orig: 'f7', dest: 'f5', color: Color(0xFF003088)),
                }),
                sideToMove:
                    position.turn == dc.Side.white ? Side.white : Side.black,
                onMove: _onUserMove,
              ),
            ),
            Column(
              children: [
                ElevatedButton(
                  child: Text('Orientation: ${orientation.name}'),
                  onPressed: () {
                    setState(() {
                      orientation = orientation.opposite;
                    });
                  },
                ),
                ElevatedButton(
                  child: Text('Piece set: ${pieceSet.label}'),
                  onPressed: () => _showChoicesPicker<PieceSet>(
                    context,
                    choices: PieceSet.values,
                    selectedItem: pieceSet,
                    labelBuilder: (t) => Text(t.label),
                    onSelectedItemChanged: (PieceSet? value) {
                      setState(() {
                        if (value != null) {
                          pieceSet = value;
                        }
                      });
                    },
                  ),
                ),
                ElevatedButton(
                  child: Text('Board theme: ${boardTheme.label}'),
                  onPressed: () => _showChoicesPicker<BoardTheme>(
                    context,
                    choices: BoardTheme.values,
                    selectedItem: boardTheme,
                    labelBuilder: (t) => Text(t.label),
                    onSelectedItemChanged: (BoardTheme? value) {
                      setState(() {
                        if (value != null) {
                          boardTheme = value;
                        }
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showChoicesPicker<T extends Enum>(
    BuildContext context, {
    required List<T> choices,
    required T selectedItem,
    required Widget Function(T choice) labelBuilder,
    required void Function(T choice) onSelectedItemChanged,
  }) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.only(top: 12),
          scrollable: true,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: choices.map((value) {
              return RadioListTile<T>(
                title: labelBuilder(value),
                value: value,
                groupValue: selectedItem,
                onChanged: (value) {
                  if (value != null) onSelectedItemChanged(value);
                  Navigator.of(context).pop();
                },
              );
            }).toList(growable: false),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    validMoves = dc.algebraicLegalMoves(position);
    super.initState();
  }

  void _onUserMove(Move move, {bool? isPremove}) async {
    final m = dc.Move.fromUci(move.uci)!;
    setState(() {
      position = position.playUnchecked(m);
      lastMove = move;
      fen = position.fen;
      validMoves = IMap(const {});
    });
    Future.delayed(const Duration(milliseconds: 100)).then((value) {
      setState(() {});
    });
    if (!position.isGameOver) {
      final random = Random();
      await Future.delayed(Duration(milliseconds: random.nextInt(5500) + 500));
      final allMoves = [
        for (final entry in position.legalMoves.entries)
          for (final dest in entry.value.squares)
            dc.NormalMove(from: entry.key, to: dest)
      ];
      if (allMoves.isNotEmpty) {
        final mv = (allMoves..shuffle()).first;
        setState(() {
          position = position.playUnchecked(mv);
          lastMove =
              Move(from: dc.toAlgebraic(mv.from), to: dc.toAlgebraic(mv.to));
          fen = position.fen;
          validMoves = dc.algebraicLegalMoves(position);
        });
      }
    }
  }
}
