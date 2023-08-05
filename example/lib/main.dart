import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      home: const HomePage(title: 'Chessground Demo'),
    );
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
  Side orientation = Side.white;
  String fen = dc.kInitialBoardFEN;
  Move? lastMove;
  ValidMoves validMoves = IMap(const {});
  Side sideToMove = Side.white;
  PieceSet pieceSet = PieceSet.merida;
  BoardTheme boardTheme = BoardTheme.blue;
  bool immersiveMode = false;
  Mode playMode = Mode.botPlay;
  dc.Position<dc.Chess>? lastPos;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: playMode == Mode.botPlay
            ? const Text('Random Bot')
            : const Text('Free Play'),
      ),
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
            Board(
              size: screenWidth,
              settings: BoardSettings(
                pieceAssets: pieceSet.assets,
                colorScheme: boardTheme.colors,
                enableCoordinates: true,
                enablePremoves: true,
              ),
              data: BoardData(
                interactableSide: playMode == Mode.botPlay
                    ? InteractableSide.white
                    : (position.turn == dc.Side.white
                        ? InteractableSide.white
                        : InteractableSide.black),
                validMoves: validMoves,
                orientation: orientation,
                fen: fen,
                lastMove: lastMove,
                sideToMove:
                    position.turn == dc.Side.white ? Side.white : Side.black,
                onMove: playMode == Mode.botPlay
                    ? _onUserMoveAgainstBot
                    : _onUserMoveFreePlay,
                isCheck: position.isCheck,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ElevatedButton(
                  child:
                      Text("Immersive mode: ${immersiveMode ? 'ON' : 'OFF'}"),
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
                if (playMode == Mode.freePlay)
                  Center(
                      child: IconButton(
                          onPressed: lastPos != null
                              ? () => setState(() {
                                    position = lastPos!;
                                    fen = position.fen;
                                    validMoves =
                                        dc.algebraicLegalMoves(position);
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

  void _onUserMoveFreePlay(Move move, {bool? isDrop, bool? isPremove}) {
    lastPos = position;
    final m = dc.Move.fromUci(move.uci)!;
    setState(() {
      position = position.playUnchecked(m);
      lastMove = move;
      fen = position.fen;
      validMoves = dc.algebraicLegalMoves(position);
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
        lastPos = position;
      }
    }
  }
}

class BoardThumbnailsPage extends StatelessWidget {
  const BoardThumbnailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Board Thumbnails'),
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(20),
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        crossAxisCount: 2,
        children: [
          for (final fen in positions)
            LayoutBuilder(builder: (context, constraints) {
              return Board(
                size: constraints.biggest.width,
                data: BoardData(
                  interactableSide: InteractableSide.none,
                  orientation: Side.white,
                  fen: fen,
                ),
              );
            }),
        ],
      ),
    );
  }
}

const positions = [
  "rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 1 1",
  "rnbqkbnr/pppp1ppp/8/4p3/4P3/8/PPPP1PPP/RNBQKBNR w KQkq - 0 2",
  "rnbqkb1r/pppppppp/5n2/8/4P3/8/PPPP1PPP/RNBQKBNR w KQkq - 2 2",
  "rnbqkb1r/ppp1pppp/3p4/3nP3/3P4/5N2/PPP2PPP/RNBQKB1R b KQkq - 1 4",
  "rnbqkbnr/pppp1ppp/8/4p3/2B1P3/8/PPPP1PPP/RNBQK1NR b KQkq - 2 2",
  "rnbqkbnr/pp1ppppp/2p5/8/4P3/8/PPPP1PPP/RNBQKBNR w KQkq - 1 2",
  "rnbqkbnr/pp2pppp/2p5/3pP3/3P4/8/PPP2PPP/RNBQKBNR b KQkq - 1 3",
  "rn1qkbnr/pp2pppp/2p5/5b2/3PN3/8/PPP2PPP/R1BQKBNR w KQkq - 2 5",
  "rnbqkbnr/pp2pppp/2p5/3P4/3P4/8/PPP2PPP/RNBQKBNR b KQkq - 1 3",
  "rnbqkb1r/pp3ppp/4pn2/3p4/2PP4/2N5/PP3PPP/R1BQKBNR w KQkq - 1 6",
  "rnbqkb1r/pp3ppp/4pn2/3p4/2PP4/2N5/PP3PPP/R1BQKBNR w KQkq - 1 6",
  "rnbqkbnr/pppp1ppp/8/8/3pP3/2P5/PP3PPP/RNBQKBNR b KQkq - 1 3",
  "r1bqkb1r/pppp1ppp/2n2n2/4p3/4P3/2N2N2/PPPP1PPP/R1BQKB1R w KQkq - 5 4",
  "r1bqkb1r/pppp1ppp/2n2n2/4p3/3PP3/2N2N2/PPP2PPP/R1BQKB1R b KQkq d3 1 4",
  "r1bqkb1r/pppp1ppp/2n2n2/1B2p3/4P3/2N2N2/PPPP1PPP/R1BQK2R b KQkq - 0 4",
  "rnbqkbnr/pppp1ppp/4p3/8/4P3/8/PPPP1PPP/RNBQKBNR w KQkq - 1 2",
  "rnbqkbnr/ppp2ppp/4p3/3pP3/3P4/8/PPP2PPP/RNBQKBNR b KQkq - 1 3",
  "rnbqkb1r/ppp2ppp/4pn2/3p2B1/3PP3/2N5/PPP2PPP/R2QKBNR b KQkq - 1 4",
  "rnbqkb1r/ppp2ppp/4pn2/3p4/3PP3/2N5/PPP2PPP/R1BQKBNR w KQkq - 3 4",
  "rnbqkbnr/ppp2ppp/4p3/3P4/3P4/8/PPP2PPP/RNBQKBNR b KQkq - 1 3",
  "rnbqkbnr/ppp2ppp/4p3/8/3Pp3/2N5/PPP2PPP/R1BQKBNR w KQkq - 1 4",
  "rnbqkbnr/ppp2ppp/4p3/3p4/3PP3/8/PPPN1PPP/R1BQKBNR b KQkq - 2 3",
  "rnbqk1nr/ppp2ppp/4p3/3p4/1b1PP3/2N5/PPP2PPP/R1BQKBNR w KQkq - 3 4",
  "r1bqk1nr/pppp1ppp/2n5/2b1p3/2B1P3/5N2/PPPP1PPP/RNBQK2R w KQkq - 5 4",
  "r1bqkbnr/pppp1ppp/2n5/4p3/2B1P3/5N2/PPPP1PPP/RNBQK2R b KQkq - 4 3",
  "r1bqk1nr/pppp1ppp/2n5/2b1p3/1PB1P3/5N2/P1PP1PPP/RNBQK2R b KQkq b3 1 4",
  "r1bqk1nr/ppppbppp/2n5/4p3/2B1P3/5N2/PPPP1PPP/RNBQK2R w KQkq - 5 4",
  "r1bqkb1r/pppp1ppp/2n2n2/4p3/2B1P3/5N2/PPPP1PPP/RNBQK2R w KQkq - 5 4",
  "rnbqkbnr/pppp1ppp/8/4p3/4PP2/8/PPPP2PP/RNBQKBNR b KQkq f3 1 2",
  "rnbqkbnr/pppp1ppp/8/8/4Pp2/8/PPPP2PP/RNBQKBNR w KQkq - 1 3",
  "rnbqkbnr/pppp1ppp/8/8/2B1Pp2/8/PPPP2PP/RNBQK1NR b KQkq - 2 3",
  "rnbqkbnr/ppp2ppp/8/3p4/4Pp2/5N2/PPPP2PP/RNBQKB1R w KQkq d6 1 4",
  "rnbqkbnr/pppp1p1p/8/6p1/4Pp2/5N2/PPPP2PP/RNBQKB1R w KQkq - 0 4",
  "rnbqk1nr/pppp1ppp/8/2b1p3/4PP2/8/PPPP2PP/RNBQKBNR w KQkq - 2 3",
  "rnbqkbnr/ppp2ppp/8/3pp3/4PP2/8/PPPP2PP/RNBQKBNR w KQkq d6 1 3",
  "rnbqkbnr/pppppp1p/6p1/8/4P3/8/PPPP1PPP/RNBQKBNR w KQkq - 0 2",
  "rnbqk1nr/ppppppbp/6p1/8/3PP3/2N5/PPP2PPP/R1BQKBNR b KQkq - 0 3",
  "rnbqkbnr/ppp2ppp/3p4/4p3/4P3/5N2/PPPP1PPP/RNBQKB1R w KQkq - 1 3",
  "rnbqkb1r/ppp1pppp/3p1n2/8/3PP3/8/PPP2PPP/RNBQKBNR w KQkq - 2 3",
  "rnbqkb1r/ppp1pp1p/3p1np1/8/3PPP2/2N5/PPP3PP/R1BQKBNR b KQkq f3 1 4",
  "rnbqkb1r/ppp1pp1p/3p1np1/8/3PP3/2N2N2/PPP2PPP/R1BQKB1R b KQkq - 2 4",
  "rnbqkb1r/pppp1ppp/5n2/4p3/4P3/5N2/PPPP1PPP/RNBQKB1R w KQkq - 3 3",
  "rnbqkb1r/ppp2ppp/3p4/8/3Pn3/5N2/PPP2PPP/RNBQKB1R b KQkq d3 1 5",
  "rnbqkb1r/pppp1ppp/5n2/4p3/3PP3/5N2/PPP2PPP/RNBQKB1R b KQkq d3 1 3",
  "rnbqkb1r/pppp1ppp/5n2/4p3/4P3/2N2N2/PPPP1PPP/R1BQKB1R b KQkq - 4 3",
  "r1bqkbnr/pppp1ppp/2n5/1B2p3/4P3/5N2/PPPP1PPP/RNBQK2R b KQkq - 4 3",
  "r1bqkb1r/pppp1ppp/2n2n2/1B2p3/4P3/5N2/PPPP1PPP/RNBQK2R w KQkq - 5 4",
  "r1bqk1nr/pppp1ppp/2n5/1Bb1p3/4P3/5N2/PPPP1PPP/RNBQK2R w KQkq - 5 4",
  "r1bqk2r/2ppbppp/p1n2n2/1p2p3/4P3/1B3N2/PPPP1PPP/RNBQR1K1 b kq - 0 7",
  "r1bqkbnr/1ppp1ppp/p1B5/4p3/4P3/5N2/PPPP1PPP/RNBQK2R b KQkq - 1 4",
  "r1bq1rk1/2p1bppp/p1n2n2/1p1pp3/4P3/1BP2N2/PP1P1PPP/RNBQR1K1 w - - 0 9",
  "r1bqkbnr/pppp2pp/2n5/1B2pp2/4P3/5N2/PPPP1PPP/RNBQK2R w KQkq f6 1 4",
  "rnbqkbnr/ppp1pppp/8/3p4/4P3/8/PPPP1PPP/RNBQKBNR w KQkq d6 1 2",
  "rnbqkb1r/ppp1pppp/5n2/3P4/3P4/8/PPP2PPP/RNBQKBNR b KQkq - 0 3",
  "r1bqkbnr/pppp1ppp/2n5/4p3/3PP3/5N2/PPP2PPP/RNBQKB1R b KQkq d3 1 3",
  "r1bqk1nr/pppp1ppp/2n5/2b5/3NP3/8/PPP2PPP/RNBQKB1R w KQkq - 2 5",
  "r1bqkb1r/p1pp1ppp/2p2n2/4P3/8/8/PPP2PPP/RNBQKB1R b KQkq - 1 6",
  "r1b1kbnr/pppp1ppp/2n5/8/3NP2q/8/PPP2PPP/RNBQKB1R w KQkq - 2 5",
  "rnbqkbnr/pp1ppppp/8/2p5/4P3/8/PPPP1PPP/RNBQKBNR w KQkq c6 1 2",
  "r1bqkbnr/pp1ppp1p/2n3p1/8/3NP3/8/PPP2PPP/RNBQKB1R w KQkq - 1 5",
  "rnbqkbnr/pp1ppppp/8/2p5/4P3/2P5/PP1P1PPP/RNBQKBNR b KQkq - 1 2",
  "rnbqkbnr/pp1ppppp/8/2p5/4P3/2N5/PPPP1PPP/R1BQKBNR b KQkq - 2 2",
  "rnbqkb1r/pp2pp1p/3p1np1/8/3NP3/2N5/PPP2PPP/R1BQKB1R w KQkq - 1 6",
  "r1bqkbnr/pp1ppppp/2n5/2p5/4PP2/2N5/PPPP2PP/R1BQKBNR b KQkq f3 1 3",
  "rnbqkbnr/pp1ppp1p/6p1/2p5/4P3/5N2/PPPP1PPP/RNBQKB1R w KQkq - 1 2",
  "rnbqkbnr/1p1p1ppp/p3p3/8/3NP3/8/PPP2PPP/RNBQKB1R w KQkq - 1 5",
  "rnbqkb1r/1p2pppp/p2p1n2/8/3NP3/2N5/PPP2PPP/R1BQKB1R w KQkq - 1 6",
  "r1bqkb1r/pp2pppp/2np1n2/6B1/3NP3/2N5/PPP2PPP/R2QKB1R b KQkq - 5 6",
  "rnbqkb1r/pp3ppp/3ppn2/8/3NP3/2N5/PPP2PPP/R1BQKB1R w KQkq - 1 6",
  "rnbqkbnr/pp1ppppp/8/8/3pP3/2P5/PP3PPP/RNBQKBNR b KQkq - 1 3",
  "rnbqkbnr/pppp1ppp/8/4p3/4P3/2N5/PPPP1PPP/R1BQKBNR b KQkq - 2 2",
  "rnbqkb1r/pppp1ppp/8/4p3/2B1n3/2N5/PPPP1PPP/R1BQK1NR w KQkq - 0 4",
  "r1bqkb1r/pppp1ppp/2n2n2/4N3/4P3/2N5/PPPP1PPP/R1BQKB1R b KQkq - 1 4",
  "rnbqkbnr/pppp1ppp/8/4p3/4P3/8/PPPPKPPP/RNBQ1BNR b kq - 0 2",
  "rnbqkbnr/pppppppp/8/8/3P4/8/PPP1PPPP/RNBQKBNR b KQkq d3 1 1",
  "rnbqkb1r/p2ppppp/5n2/1ppP4/2P5/8/PP2PPPP/RNBQKBNR w KQkq b6 1 4",
  "rnbqkb1r/pp1p1ppp/4pn2/2pP4/2P5/8/PP2PPPP/RNBQKBNR w KQkq - 0 4",
  "rnbqkb1r/pp1p1ppp/5n2/2pPp3/2P5/8/PP2PPPP/RNBQKBNR w KQkq - 0 4",
  "rnbqkbnr/ppp1pppp/8/3p4/3PP3/8/PPP2PPP/RNBQKBNR b KQkq e3 1 2",
  "rnbqk2r/pppp1ppp/4pn2/8/1bPP4/5N2/PP2PPPP/RNBQKB1R w KQkq - 3 4",
  "rnbqkb1r/pppp1ppp/4pn2/8/2PP4/6P1/PP2PP1P/RNBQKBNR b KQkq - 1 3",
  "rnbqk2r/ppp1bppp/4pn2/3p4/2PP4/5NP1/PP2PPBP/RNBQK2R b KQkq - 4 5",
  "rnbqkbnr/ppppp1pp/8/5p2/3P4/8/PPP1PPPP/RNBQKBNR w KQkq f6 1 2",
  "rnbqk2r/ppppp1bp/5np1/5p2/2PP4/5NP1/PP2PPBP/RNBQK2R b KQkq - 4 5",
  "rnbqkb1r/ppppp1pp/5n2/6B1/3Pp3/2N5/PPP2PPP/R2QKBNR b KQkq - 4 4",
  "rnbq1rk1/ppp1b1pp/4pn2/3p1p2/2PP4/5NP1/PP2PPBP/RNBQ1RK1 w - d6 1 7",
  "rnbqkb1r/ppp1pp1p/5np1/3p4/2PP4/2N5/PP2PPPP/R1BQKBNR w KQkq d6 1 4",
  "rnbqkb1r/ppp1pp1p/5np1/3p4/2PP1B2/2N5/PP2PPPP/R2QKBNR b KQkq - 2 4",
  "rnbqkb1r/ppp1pp1p/6p1/3n4/3P4/2N5/PP2PPPP/R1BQKBNR w KQkq - 1 5",
  "rnbqkb1r/ppp1pp1p/5np1/3p4/2PP4/1QN5/PP2PPPP/R1B1KBNR b KQkq - 0 4",
  "rnbqk2r/ppp1ppbp/5np1/3p2B1/2PP4/2N2N2/PP2PPPP/R2QKB1R b KQkq - 0 5",
  "rnbqkb1r/pppppp1p/5np1/8/2PP4/8/PP2PPPP/RNBQKBNR w KQkq - 1 3",
  "rnbqk2r/ppp1ppbp/3p1np1/8/2PPP3/2N5/PP3PPP/R1BQKBNR w KQkq - 1 5",
  "rnbq1rk1/ppp1ppbp/3p1np1/6B1/2PPP3/2N5/PP2BPPP/R2QK1NR b KQ - 4 6",
  "rnbqk2r/ppp1ppbp/3p1np1/8/2PP4/2N2NP1/PP2PP1P/R1BQKB1R b KQkq - 1 5",
  "rnbqk2r/ppp1ppbp/3p1np1/8/2PPPP2/2N5/PP4PP/R1BQKBNR b KQkq f3 1 5",
  "rnbq1rk1/ppp1ppbp/3p1np1/8/2PPP3/2N2N2/PP2BPPP/R1BQK2R b KQ - 4 6",
  "rnbqk2r/ppp1ppbp/3p1np1/8/2PPP3/2N2P2/PP4PP/R1BQKBNR b KQkq - 1 5",
  "rnbqk1nr/ppp1ppbp/3p2p1/8/2PP4/2N5/PP2PPPP/R1BQKBNR w KQkq - 1 4",
  "rnbqk2r/pppp1ppp/4pn2/8/1bPP4/2N5/PP2PPPP/R1BQKBNR w KQkq - 3 4",
  "rnbqk2r/pppp1ppp/4pn2/8/1bPP4/2N5/PPQ1PPPP/R1B1KBNR b KQkq - 4 4",
  "rnbqk2r/p1pp1ppp/1p2pn2/8/1bPP4/2N1P3/PP3PPP/R1BQKBNR w KQkq - 0 5",
  "rnbqk2r/pppp1ppp/4pn2/6B1/1bPP4/2N5/PP2PPPP/R2QKBNR b KQkq - 0 4",
  "rnbqk2r/pppp1ppp/4pn2/8/2PP4/P1P5/4PPPP/R1BQKBNR b KQkq - 0 5",
  "rnbqkb1r/ppp1pppp/3p1n2/8/2PP4/8/PP2PPPP/RNBQKBNR w KQkq - 1 3",
  "rnbqkbnr/ppp1pppp/8/3p4/2PP4/8/PP2PPPP/RNBQKBNR b KQkq c3 1 2",
  "rnbqkbnr/ppp1pppp/8/8/2pP4/8/PP2PPPP/RNBQKBNR w KQkq - 1 3",
  "rnbqkb1r/pp3ppp/2p1pn2/3p4/2PP4/2N2N2/PP2PPPP/R1BQKB1R w KQkq - 1 5",
  "rnbqkbnr/pp2pppp/2p5/3p4/2PP4/8/PP2PPPP/RNBQKBNR w KQkq - 0 3",
  "rnbqkb1r/pp3ppp/4pn2/2pp4/2PP4/2N2N2/PP2PPPP/R1BQKB1R w KQkq c6 1 5",
  "rnbqkbnr/pp3ppp/4p3/2pp4/2PP4/2N5/PP2PPPP/R1BQKBNR w KQkq - 0 4",
  "rnbqkbnr/ppp2ppp/8/3pp3/2PP4/8/PP2PPPP/RNBQKBNR w KQkq e6 1 3",
  "r1bqkbnr/ppp1pppp/2n5/3p4/2PP4/8/PP2PPPP/RNBQKBNR w KQkq - 2 3",
  "rnbqkb1r/p1pp1ppp/1p2pn2/8/2PP4/5N2/PP2PPPP/RNBQKB1R w KQkq - 1 4",
  "rnbqkb1r/ppp1pppp/5n2/3p4/3P1B2/5N2/PPP1PPPP/RN1QKB1R b KQkq - 4 3",
  "rnbqkb1r/ppp1pppp/5n2/3p2B1/3P4/5N2/PPP1PPPP/RN1QKB1R b KQkq - 4 3",
  "rnbqkb1r/ppp1pppp/5n2/3p2B1/3P4/2N5/PPP1PPPP/R2QKBNR b KQkq - 4 3",
  "rnbqkb1r/pppp1ppp/5n2/4p3/2PP4/8/PP2PPPP/RNBQKBNR w KQkq - 0 3",
  "rnbqkbnr/ppp1pppp/8/3p4/3P4/8/PPP1PPPP/RNBQKBNR w KQkq - 0 2",
  "rnbqkb1r/pppppppp/5n2/6B1/3P4/8/PPP1PPPP/RN1QKBNR b KQkq - 3 2",
  "rnbqkbnr/pppppppp/8/8/8/5N2/PPPPPPPP/RNBQKB1R b KQkq - 1 1",
  "rnbqkbnr/ppp1pppp/8/3p4/8/5NP1/PPPPPP1P/RNBQKB1R b KQkq - 1 2",
  "rnbqkbnr/ppp1pppp/8/3p4/2P5/5N2/PP1PPPPP/RNBQKB1R b KQkq c3 1 2",
  "rnbqkbnr/pppppppp/8/8/2P5/8/PP1PPPPP/RNBQKBNR b KQkq c3 1 1",
  "rnbqkbnr/pppp1ppp/8/4p3/2P5/8/PP1PPPPP/RNBQKBNR w KQkq e6 1 2",
  "rnbqkbnr/pp1ppppp/8/2p5/2P5/8/PP1PPPPP/RNBQKBNR w KQkq c6 1 2",
  "r1bqk1nr/ppp2pbp/2np2p1/4p3/2P5/2NP2P1/PP2PPBP/R1BQK1NR w KQkq - 0 6",
  "rnbqkbnr/pppppppp/8/8/8/1P6/P1PPPPPP/RNBQKBNR b KQkq - 1 1",
  "rnbqkbnr/pppppppp/8/8/8/6P1/PPPPPP1P/RNBQKBNR b KQkq - 1 1",
];
