import 'dart:math';
import 'package:flutter/material.dart';
import 'package:chessground/chessground.dart' as cg;
import 'package:dartchess/dartchess.dart';
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
  Position<Chess> position = Chess.initial;
  String fen = kInitialBoardFEN;
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
          interactableColor: cg.InteractableColor.white,
          pieceSet: maestroPieceSet,
          validMoves: validMoves,
          size: screenWidth,
          orientation: cg.Color.white,
          fen: fen,
          lastMove: lastMove,
          turnColor: position.turn == Color.white ? cg.Color.white : cg.Color.black,
          onMove: _onUserMove,
        ),
      ),
    );
  }

  @override
  void initState() {
    validMoves = algebraicLegalMoves(position);
    super.initState();
  }

  void _onUserMove(cg.Move move, {bool? isPremove}) async {
    final m = Move.fromUci(move.uci);
    setState(() {
      position = position.playUnchecked(m);
      lastMove = move;
      fen = position.fen;
      validMoves = {};
    });
    Future.delayed(const Duration(milliseconds: 100)).then((value) {
      setState(() {});
    });
    if (!position.isGameOver) {
      final random = Random();
      await Future.delayed(Duration(milliseconds: random.nextInt(5500) + 500));
      final allMoves = [
        for (final entry in position.legalMoves.entries)
          for (final dest in entry.value.squares) NormalMove(from: entry.key, to: dest)
      ];
      if (allMoves.isNotEmpty) {
        final mv = (allMoves..shuffle()).first;
        setState(() {
          position = position.playUnchecked(mv);
          lastMove = cg.Move(from: toAlgebraic(mv.from), to: toAlgebraic(mv.to));
          fen = position.fen;
          validMoves = algebraicLegalMoves(position);
        });
      }
    }
  }
}
