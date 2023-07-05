import 'dart:math';
import 'package:flutter/services.dart';
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
  bool immersiveMode = false;
  InteractableSide interactableSide = InteractableSide.white;
  ISet<Shape> shapes = ISet();
  Color newShapeColor = const Color(0xAA15781b);
  final Color defaultShapeColor = const Color(0xAA15781b);
  double boardScale = 1.0;

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
            GestureDetector(
              onLongPress: _onLongPress,
              child: AnimatedScale(
                scale: boardScale,
                duration: const Duration(milliseconds: 200),
                child: Board(
                  size: screenWidth,
                  settings: BoardSettings(
                    pieceAssets: pieceSet.assets,
                    colorScheme: boardTheme.colors,
                    enableCoordinates: true,
                    enablePremoves: true,
                  ),
                  data: BoardData(
                    interactableSide: interactableSide,
                    validMoves: validMoves,
                    orientation: orientation,
                    fen: fen,
                    lastMove: lastMove,
                    sideToMove:
                        position.turn == dc.Side.white ? Side.white : Side.black,
                    onMove: _onUserMove,
                    onCompleteShape: _onCompleteShape,
                    isCheck: position.isCheck,
                    shapes: shapes.isNotEmpty ? shapes : null,
                    newShapeColor: newShapeColor,
                  ),
                ),
              ),
            ),


            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ElevatedButton(
                  child:
                      Text('Immersive mode: ${immersiveMode ? 'ON' : 'OFF'}'),
                  onPressed: () {
                    setState(() {
                      immersiveMode = !immersiveMode;
                    });
                    if (immersiveMode) {
                      SystemChrome.setEnabledSystemUIMode(
                          SystemUiMode.immersiveSticky);
                    } else {
                      SystemChrome.setEnabledSystemUIMode(
                          SystemUiMode.edgeToEdge);
                    }
                  },
                ),
                ElevatedButton(
                  child: Text('Orientation: ${orientation.name}'),
                  onPressed: () {
                    setState(() {
                      orientation = orientation.opposite;
                    });
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    ElevatedButton(
                      child: Text('Mode: ${interactableSide.name}'),
                      onPressed: () {
                        setState(() {
                          interactableSide =
                            (interactableSide == InteractableSide.white) ?
                            InteractableSide.drawShapes : InteractableSide.white;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      child: const Text('Clear'),
                      onPressed: () {
                        setState(() {
                          shapes = ISet();
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    Tooltip(
                      message: 'Toggles Color between a random color and default green.',
                      child: ElevatedButton(
                        child: Text('$newShapeColor'),
                        onPressed: () {
                          setState(() {
                            newShapeColor = (newShapeColor == defaultShapeColor) ?
                            Color(Random().nextInt(0x00ffffff) + 0xAA000000) :
                            defaultShapeColor;
                          });
                        },
                      ),
                    ),
                  ],
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
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
                    const SizedBox(width: 8),
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

  _onLongPress() {
    setState(() {
      interactableSide = (interactableSide == InteractableSide.drawShapes) ?
      InteractableSide.white : InteractableSide.drawShapes;
      shapes = ISet();
      boardScale = boardScale == 1.0 ? 0.98 : 1.0;
    });
  }

  @override
  void initState() {
    validMoves = dc.algebraicLegalMoves(position);
    super.initState();
  }

  void _onCompleteShape(Shape shape) {
    if (shapes.any((element) => element == shape)) {
      setState(() {
        shapes = shapes.remove(shape);
      });
      return;
    } else {
      setState(() {
        shapes = ISet(shapes.where((element) =>
        !(element.dest == shape.dest && element.orig == shape.orig))); // Removes shapes with same dest and orig
        shapes = shapes.add(shape);
      });
    }
  }

  void _onUserMove(Move move, {bool? isPremove}) async {
    final m = dc.Move.fromUci(move.uci)!;
    setState(() {
      position = position.playUnchecked(m);
      lastMove = move;
      fen = position.fen;
      validMoves = IMap(const {});
      shapes = ISet();
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
