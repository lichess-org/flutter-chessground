import 'dart:math';
import 'package:flutter/material.dart';
import 'package:chessground/chessground.dart' as cg;
import 'package:chess/chess.dart' as ch;

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
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
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
  String fen = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR';
  cg.Move? lastMove;

  @override
  void initState() {
    super.initState();
    playRandomGame();
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

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: cg.Board(
          settings: const cg.Settings(
            interactable: false,
          ),
          size: screenWidth,
          orientation: cg.Color.white,
          fen: fen,
          lastMove: lastMove,
        ),
      ),
    );
  }
}
