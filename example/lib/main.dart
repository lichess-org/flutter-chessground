import 'dart:math';
import 'package:board_example/board_editor_page.dart';
import 'package:flutter/material.dart';
import 'package:chessground/chessground.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:dartchess/dartchess.dart' as dc;

import 'board_theme.dart';
import 'board_thumbnails.dart';

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
        brightness: Brightness.light,
        primaryColor: Colors.blueGrey,
      ),
      home: const HomePage(title: 'Chessground Demo'),
    );
  }
}

String pieceShiftMethodLabel(PieceShiftMethod method) {
  switch (method) {
    case PieceShiftMethod.drag:
      return 'Drag';
    case PieceShiftMethod.tapTwoSquares:
      return 'Tap two squares';
    case PieceShiftMethod.either:
      return 'Either';
  }
}

enum Mode {
  botPlay,
  freePlay,
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  dc.Position<dc.Chess> position = dc.Chess.initial;
  dc.Side orientation = dc.Side.white;
  String fen = dc.kInitialBoardFEN;
  Move? lastMove;
  Move? premove;
  ValidMoves validMoves = IMap(const {});
  dc.Side sideToMove = dc.Side.white;
  PieceSet pieceSet = PieceSet.merida;
  PieceShiftMethod pieceShiftMethod = PieceShiftMethod.either;
  BoardTheme boardTheme = BoardTheme.blue;
  bool drawMode = true;
  bool pieceAnimation = true;
  bool dragMagnify = true;
  Mode playMode = Mode.botPlay;
  dc.Position<dc.Chess>? lastPos;
  ISet<Shape> shapes = ISet();

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
          title: switch (playMode) {
        Mode.botPlay => const Text('Random Bot'),
        Mode.freePlay => const Text('Free Play'),
      }),
      drawer: Drawer(
          child: ListView(
        children: [
          ListTile(
            title: const Text('Random Bot'),
            onTap: () {
              setState(() {
                playMode = Mode.botPlay;
              });
              if (position.turn == dc.Side.black) {
                _playBlackMove();
              }
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Free Play'),
            onTap: () {
              setState(() {
                playMode = Mode.freePlay;
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Board Editor'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BoardEditorPage(),
                ),
              );
            },
          ),
          ListTile(
            title: const Text('Board Thumbnails'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BoardThumbnailsPage(),
                ),
              );
            },
          ),
        ],
      )),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Chessboard(
              size: screenWidth,
              settings: ChessboardSettings(
                pieceAssets: pieceSet.assets,
                colorScheme: boardTheme.colors,
                enableCoordinates: true,
                animationDuration: pieceAnimation
                    ? const Duration(milliseconds: 200)
                    : Duration.zero,
                dragFeedbackScale: dragMagnify ? 2.0 : 1.0,
                drawShape: DrawShapeOptions(
                  enable: drawMode,
                  onCompleteShape: _onCompleteShape,
                  onClearShapes: () {
                    setState(() {
                      shapes = ISet();
                    });
                  },
                ),
                pieceShiftMethod: pieceShiftMethod,
              ),
              state: ChessboardState(
                interactableSide: playMode == Mode.botPlay
                    ? InteractableSide.white
                    : (position.turn == dc.Side.white
                        ? InteractableSide.white
                        : InteractableSide.black),
                validMoves: validMoves,
                orientation: orientation,
                opponentsPiecesUpsideDown: playMode == Mode.freePlay,
                fen: fen,
                lastMove: lastMove,
                sideToMove: position.turn == dc.Side.white
                    ? dc.Side.white
                    : dc.Side.black,
                isCheck: position.isCheck,
                premove: premove,
                shapes: shapes.isNotEmpty ? shapes : null,
              ),
              onMove: playMode == Mode.botPlay
                  ? _onUserMoveAgainstBot
                  : _onUserMoveFreePlay,
              onPremove: _onSetPremove,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    ElevatedButton(
                      child: Text('Orientation: ${orientation.name}'),
                      onPressed: () {
                        setState(() {
                          orientation = orientation.opposite;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      child:
                          Text("Magnify drag: ${dragMagnify ? 'ON' : 'OFF'}"),
                      onPressed: () {
                        setState(() {
                          dragMagnify = !dragMagnify;
                        });
                      },
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    ElevatedButton(
                      child: Text("Drawing mode: ${drawMode ? 'ON' : 'OFF'}"),
                      onPressed: () {
                        setState(() {
                          drawMode = !drawMode;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      child: Text(
                          "Piece animation: ${pieceAnimation ? 'ON' : 'OFF'}"),
                      onPressed: () {
                        setState(() {
                          pieceAnimation = !pieceAnimation;
                        });
                      },
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    ElevatedButton(
                      child: Text(
                          'Piece shift method: ${pieceShiftMethodLabel(pieceShiftMethod)}'),
                      onPressed: () => _showChoicesPicker<PieceShiftMethod>(
                        context,
                        choices: PieceShiftMethod.values,
                        selectedItem: pieceShiftMethod,
                        labelBuilder: (t) => Text(pieceShiftMethodLabel(t)),
                        onSelectedItemChanged: (PieceShiftMethod? value) {
                          setState(() {
                            if (value != null) {
                              pieceShiftMethod = value;
                            }
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
                if (playMode == Mode.freePlay)
                  Center(
                      child: IconButton(
                          onPressed: lastPos != null
                              ? () => setState(() {
                                    position = lastPos!;
                                    fen = position.fen;
                                    validMoves = legalMovesOf(position);
                                    lastPos = null;
                                  })
                              : null,
                          icon: const Icon(Icons.chevron_left_sharp))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _onCompleteShape(Shape shape) {
    if (shapes.any((element) => element == shape)) {
      setState(() {
        shapes = shapes.remove(shape);
      });
      return;
    } else {
      setState(() {
        shapes = shapes.add(shape);
      });
    }
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
    validMoves = legalMovesOf(position);
    super.initState();
  }

  void _onSetPremove(Move? move) {
    setState(() {
      premove = move;
    });
  }

  void _onUserMoveFreePlay(Move move, {bool? isDrop, bool? isPremove}) {
    lastPos = position;
    final m = dc.Move.fromUci(move.uci)!;
    setState(() {
      position = position.playUnchecked(m);
      lastMove = move;
      fen = position.fen;
      validMoves = legalMovesOf(position);
    });
  }

  void _onUserMoveAgainstBot(Move move, {bool? isDrop, bool? isPremove}) async {
    lastPos = position;
    final m = dc.Move.fromUci(move.uci)!;
    setState(() {
      position = position.playUnchecked(m);
      lastMove = move;
      fen = position.fen;
      validMoves = IMap(const {});
    });
    await _playBlackMove();
  }

  Future<void> _playBlackMove() async {
    Future.delayed(const Duration(milliseconds: 100)).then((value) {
      setState(() {});
    });
    if (!position.isGameOver) {
      final random = Random();
      await Future.delayed(Duration(milliseconds: random.nextInt(1000) + 500));
      final allMoves = [
        for (final entry in position.legalMoves.entries)
          for (final dest in entry.value.squares)
            dc.NormalMove(from: entry.key, to: dest)
      ];
      if (allMoves.isNotEmpty) {
        final mv = (allMoves..shuffle()).first;
        setState(() {
          position = position.playUnchecked(mv);
          lastMove = Move(
              from: SquareId(dc.toAlgebraic(mv.from)),
              to: SquareId(dc.toAlgebraic(mv.to)));
          fen = position.fen;
          validMoves = legalMovesOf(position);
        });
        lastPos = position;
      }
    }
  }
}
