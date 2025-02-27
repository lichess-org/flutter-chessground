import 'dart:async';
import 'dart:math';
import 'package:board_example/board_editor_page.dart';
import 'package:flutter/material.dart';
import 'package:chessground/chessground.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:dartchess/dartchess.dart';

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
  inputMove,
  freePlay,
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Position position = Chess.initial;
  Side orientation = Side.white;
  String fen = kInitialBoardFEN;
  NormalMove? lastMove;
  NormalMove? promotionMove;
  NormalMove? premove;
  ValidMoves validMoves = IMap(const {});
  Side sideToMove = Side.white;
  PieceSet pieceSet = PieceSet.gioco;
  PieceShiftMethod pieceShiftMethod = PieceShiftMethod.either;
  DragTargetKind dragTargetKind = DragTargetKind.circle;
  BoardTheme boardTheme = BoardTheme.brown;
  bool drawMode = true;
  bool pieceAnimation = true;
  bool dragMagnify = true;
  Mode playMode = Mode.botPlay;
  Position? lastPos;
  ISet<Shape> shapes = ISet();
  bool showBorder = false;
  int moveCount = 0;
  String pgn = '';

  void _resetGame() {
    setState(() {
      position = Chess.initial;
      fen = kInitialBoardFEN;
      lastMove = null;
      promotionMove = null;
      premove = null;
      validMoves = makeLegalMoves(position);
      sideToMove = Side.white;
      lastPos = null;
      shapes = ISet();
      moveCount = 0;
      pgn = ''; // 重置 PGN
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    final settingsWidgets = [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          ElevatedButton(
            child: Text("Magnify drag: ${dragMagnify ? 'ON' : 'OFF'}"),
            onPressed: () {
              setState(() {
                dragMagnify = !dragMagnify;
              });
            },
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            child: Text('Drag target: ${dragTargetKind.name}'),
            onPressed: () => _showChoicesPicker<DragTargetKind>(
              context,
              choices: DragTargetKind.values,
              selectedItem: dragTargetKind,
              labelBuilder: (t) => Text(t.name),
              onSelectedItemChanged: (DragTargetKind value) {
                setState(() {
                  dragTargetKind = value;
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
            child: Text('Orientation: ${orientation.name}'),
            onPressed: () {
              setState(() {
                orientation = orientation.opposite;
              });
            },
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            child: Text("Piece animation: ${pieceAnimation ? 'ON' : 'OFF'}"),
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
            child:
                Text('Piece Shift: ${pieceShiftMethodLabel(pieceShiftMethod)}'),
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
          ElevatedButton(
            child: Text("Show border: ${showBorder ? 'ON' : 'OFF'}"),
            onPressed: () {
              setState(() {
                showBorder = !showBorder;
              });
            },
          ),
        ],
      ),
      if (playMode == Mode.freePlay)
        Center(
            child: IconButton(
                onPressed: lastPos != null
                    ? () => setState(() {
                          position = lastPos!;
                          fen = position.fen;
                          validMoves = makeLegalMoves(position);
                          lastPos = null;
                        })
                    : null,
                icon: const Icon(Icons.chevron_left_sharp))),
    ];

    final inputMoveWidgets = [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          decoration: const InputDecoration(
            labelText: 'Enter move in UCI format',
          ),
          onSubmitted: (String value) {
            final move = NormalMove.fromUci(value);
            _playMove(move);
            _tryPlayPremove();
          },
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: switch (playMode) {
          Mode.botPlay => const Text('機器人'),
          Mode.inputMove => const Text('Enter opponent move'),
          Mode.freePlay => const Text('與對手下棋'),
        },
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetGame,
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              title: const Text('Random Bot'),
              onTap: () {
                setState(() {
                  playMode = Mode.botPlay;
                  _resetGame(); // Reset the game when switching to botPlay mode
                });
                if (position.turn == Side.black) {
                  _playBlackMove();
                }
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Enter opponent move'),
              onTap: () {
                setState(() {
                  playMode = Mode.inputMove;
                  _resetGame(); // Reset the game when switching to inputMove mode
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Free Play'),
              onTap: () {
                setState(() {
                  playMode = Mode.freePlay;
                  _resetGame(); // Reset the game when switching to freePlay mode
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
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('PGN: $pgn', style: const TextStyle(fontSize: 18)),
          ),
          Chessboard(
            size: screenWidth,
            settings: ChessboardSettings(
              pieceAssets: pieceSet.assets,
              colorScheme: boardTheme.colors,
              border: showBorder
                  ? BoardBorder(
                      width: 16.0,
                      color: _darken(boardTheme.colors.darkSquare, 0.2),
                    )
                  : null,
              enableCoordinates: true,
              animationDuration: pieceAnimation
                  ? const Duration(milliseconds: 200)
                  : Duration.zero,
              dragFeedbackScale: dragMagnify ? 2.0 : 1.0,
              dragTargetKind: dragTargetKind,
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
              autoQueenPromotionOnPremove: false,
              pieceOrientationBehavior: playMode == Mode.freePlay
                  ? PieceOrientationBehavior.opponentUpsideDown
                  : PieceOrientationBehavior.facingUser,
            ),
            orientation: orientation,
            fen: fen,
            lastMove: lastMove,
            game: GameData(
              playerSide:
                  (playMode == Mode.botPlay || playMode == Mode.inputMove)
                      ? PlayerSide.white
                      : (position.turn == Side.white
                          ? PlayerSide.white
                          : PlayerSide.black),
              validMoves: validMoves,
              sideToMove: position.turn == Side.white ? Side.white : Side.black,
              isCheck: position.isCheck,
              promotionMove: promotionMove,
              onMove:
                  playMode == Mode.botPlay ? _onUserMoveAgainstBot : _playMove,
              onPromotionSelection: _onPromotionSelection,
              premovable: (
                onSetPremove: _onSetPremove,
                premove: premove,
              ),
            ),
            shapes: shapes.isNotEmpty ? shapes : null,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children:
                playMode == Mode.inputMove ? inputMoveWidgets : settingsWidgets,
          ),
        ],
      ),
    );
  }

  void _tryPlayPremove() {
    if (premove != null) {
      Timer.run(() {
        _playMove(premove!, isPremove: true);
      });
    }
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
    validMoves = makeLegalMoves(position);
    super.initState();
  }

  void _onSetPremove(NormalMove? move) {
    setState(() {
      premove = move;
    });
  }

  void _onPromotionSelection(Role? role) {
    if (role == null) {
      _onPromotionCancel();
    } else if (promotionMove != null) {
      if (playMode == Mode.botPlay) {
        _onUserMoveAgainstBot(promotionMove!.withPromotion(role));
      } else {
        _playMove(promotionMove!.withPromotion(role));
      }
    }
  }

  void _onPromotionCancel() {
    setState(() {
      promotionMove = null;
    });
  }

  void _playMove(NormalMove move, {bool? isDrop, bool? isPremove}) {
    lastPos = position;
    if (isPromotionPawnMove(move)) {
      setState(() {
        promotionMove = move;
      });
    } else if (position.isLegal(move)) {
      setState(() {
        pgn += ' ${_moveToPgn(move)}';
        position = position.playUnchecked(move);
        lastMove = move;
        fen = position.fen;
        validMoves = makeLegalMoves(position);
        promotionMove = null;
        if (isPremove == true) {
          premove = null;
        }
        moveCount++;
      });
      _checkGameOver();
    }
  }

  void _onUserMoveAgainstBot(NormalMove move, {isDrop}) async {
    lastPos = position;
    if (isPromotionPawnMove(move)) {
      setState(() {
        promotionMove = move;
      });
    } else {
      setState(() {
        pgn += ' ${_moveToPgn(move)}';
        position = position.playUnchecked(move);
        lastMove = move;
        fen = position.fen;
        validMoves = IMap(const {});
        promotionMove = null;
        moveCount++;
      });
      await _playBlackMove();
      _tryPlayPremove();
      _checkGameOver();
    }
  }

  void _checkGameOver() {
    if (position.isGameOver) {
      String result;
      if (position.isCheckmate) {
        result = position.turn == Side.white ? 'Black wins by checkmate' : 'White wins by checkmate';
      } else if (position.isStalemate) {
        result = 'Draw by stalemate';
      } else if (position.isInsufficientMaterial) {
        result = 'Draw by insufficient material';
      } else {
        result = 'Draw';
      }

      showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Game Over'),
            content: Text(result),
            actions: <Widget>[
              TextButton(
                child: const Text('Play Again'),
                onPressed: () {
                  Navigator.of(context).pop();
                  _resetGame();
                },
              ),
            ],
          );
        },
      );
    }
  }

  String _moveToPgn(NormalMove move) {
    final piece = position.board.pieceAt(move.from);
    final pieceChar = piece != null && piece.role != Role.pawn ? piece.role.uppercaseLetter : '';
    final capture = position.board.pieceAt(move.to) != null ? 'x' : '';
    final promotion = move.promotion != null ? '=${move.promotion!.uppercaseLetter}' : '';
    return '$pieceChar${move.from.name}$capture${move.to.name}$promotion';
  }
  
  Future<void> _playBlackMove() async {
    Future.delayed(const Duration(milliseconds: 100)).then((value) {
      setState(() {});
    });
    if (position.isGameOver) return;

    final random = Random();
    await Future.delayed(Duration(milliseconds: random.nextInt(1000) + 500));
    final allMoves = [
      for (final entry in position.legalMoves.entries)
        for (final dest in entry.value.squares)
          NormalMove(from: entry.key, to: dest)
    ];
    if (allMoves.isNotEmpty) {
      NormalMove mv = (allMoves..shuffle()).first;
      // Auto promote to a random non-pawn role
      if (isPromotionPawnMove(mv)) {
        final potentialRoles =
            Role.values.where((role) => role != Role.pawn).toList();
        final role = potentialRoles[random.nextInt(potentialRoles.length)];
        mv = mv.withPromotion(role);
      }

      setState(() {
        position = position.playUnchecked(mv);
        lastMove =
            NormalMove(from: mv.from, to: mv.to, promotion: mv.promotion);
        fen = position.fen;
        validMoves = makeLegalMoves(position);
      });
      lastPos = position;
    }
  }

  bool isPromotionPawnMove(NormalMove move) {
    return move.promotion == null &&
        position.board.roleAt(move.from) == Role.pawn &&
        ((move.to.rank == Rank.first && position.turn == Side.black) ||
            (move.to.rank == Rank.eighth && position.turn == Side.white));
  }
}

Color _darken(Color c, [double amount = .1]) {
  assert(amount >= 0 && amount <= 1);
  return Color.lerp(c, const Color(0xFF000000), amount) ?? c;
}
