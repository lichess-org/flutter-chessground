import 'dart:math';
import 'package:flutter/material.dart';
import 'package:chessground/chessground.dart' as cg;
import 'package:chess/chess.dart' as ch;
import 'package:bishop/bishop.dart' as bishop;
import './piece_set.dart';

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

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bishop.Game game = bishop.Game(variant: bishop.Variant.standard());
  String fen = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR';
  cg.Move? lastMove;
  cg.ValidMoves validMoves = {};
  cg.Color turnColor = cg.Color.white;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: cg.Board(
          settings: const cg.Settings(
            interactable: true,
            interactableColor: cg.InteractableColor.white,
          ),
          pieceSet: maestroPieceSet,
          validMoves: validMoves,
          size: screenWidth,
          orientation: cg.Color.white,
          fen: fen,
          lastMove: lastMove,
          turnColor:
              game.turn == bishop.WHITE ? cg.Color.white : cg.Color.black,
          onMove: _onMove,
        ),
      ),
    );
  }

  @override
  void initState() {
    validMoves = _getValidMoves(game);
    // playRandomGame();
    super.initState();
  }

  cg.ValidMoves _getValidMoves(bishop.Game g) {
    final cg.ValidMoves result = {};
    final legalMoves = g.generateLegalMoves();
    for (bishop.Move m in legalMoves) {
      final fromSquare = bishop.squareName(m.from);
      final toSquare = bishop.squareName(m.to);
      if (!result.containsKey(fromSquare)) {
        result[fromSquare] = {toSquare};
      } else {
        result[fromSquare]!.add(toSquare);
      }
    }
    return result;
  }

  void _onMove(cg.Move move) async {
    bishop.Move? m = game.getMove(move.uci);
    bool result = m != null ? game.makeMove(m) : false;
    if (result) {
      setState(() {
        lastMove = move;
        fen = game.fen;
        validMoves = {};
      });
    }
    Future.delayed(const Duration(milliseconds: 100)).then((value) {
      setState(() {});
    });
    if (result && !game.gameOver) {
      await Future.delayed(Duration(milliseconds: Random().nextInt(750) + 50));
      final mv = game.makeRandomMove();
      final fromSquare = bishop.squareName(mv.from);
      final toSquare = bishop.squareName(mv.to);
      final _validMoves = _getValidMoves(game);
      setState(() {
        lastMove = cg.Move(from: fromSquare, to: toSquare);
        fen = game.fen;
        validMoves = _validMoves;
      });
    }
  }

  playRandomGame() async {
    ch.Chess chess = ch.Chess();
    while (!chess.game_over) {
      // debugPrint('position: ' + chess.fen);
      // debugPrint(chess.ascii);
      var moves = chess.moves();
      moves.shuffle();
      var move = moves[0];
      chess.move(move);
      final history = chess.getHistory({'verbose': true});
      await Future.delayed(Duration(milliseconds: Random().nextInt(950) + 200));
      setState(() {
        fen = chess.fen;
        if (history.isNotEmpty) {
          final lm = history[history.length - 1];
          lastMove = cg.Move(
            from: lm['from'],
            to: lm['to'],
          );
        }
      });
    }
  }
}
