[![Tests](https://github.com/lichess-org/flutter-chessground/workflows/Test/badge.svg)](https://github.com/lichess-org/flutter-chessground/actions?query=workflow%3A%22Test%22)
[![pub package](https://img.shields.io/pub/v/chessground.svg)](https://pub.dev/packages/chessground)
[![package publisher](https://img.shields.io/pub/publisher/chessground.svg)](https://pub.dev/packages/chessground/publisher)
[![Discord](https://img.shields.io/discord/280713822073913354?label=Discord&logo=discord&style=flat)](https://discord.com/channels/280713822073913354/807722604478988348)

Chessground is a chessboard package developed for lichess.org. It doesn't handle
chess logic so you can use it with different chess variants.

## Features

- pieces animations: moving and fading away
- board highlights: last move, piece destinations
- move piece by tap or drag and drop
- premoves
- displays a shadow under dragged piece to indicate the drop square target
- board themes
- piece sets from lichess
- promotion selector
- draw shapes on board while playing using 2 fingers
- move annotations
- opponent's pieces can be displayed upside down
- create positions with a board editor

## Getting started

This package exports a `Chessboard` widget which can be interactable or not.

It is configurable with a `ChessboardSettings` object which defines the board
behavior and appearance.

To interact with the board in order to play a game, you must provide a `GameData`
object to the `Chessboard` widget. This object is immutable and contains the game
state (which side is to move, the current valid moves, etc.), along with the
callback functions to handle user interactions.

All chess logic must be handled outside of this package. Any change in the state
of the game needs to be transferred to the board by creating a new `GameData` object.

## Usage

This will display a non-interactable board from the starting position, using the
default theme:

```dart
import 'package:flutter/material.dart';
import 'package:chessground/chessground.dart';
import 'package:dartchess/dartchess.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String fen = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR';

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chessground demo'),
      ),
      body: Center(
        child: Chessboard.fixed(
          size: screenWidth,
          orientation: Side.white,
          fen: fen,
        ),
      ),
    );
  }
}
```

See the example app for:
- Random Bot: an interactable board for one player playing against a random bot,
- Free Play: an interactable board for two players sitting opposite to each other,
- Board editor: a board editor to create positions,
- Draw Shapes: activate the draw shapes feature and draw on the board using 2
- Board Thumbnails: a demo screen showing over hundred different boards in a grid,
  fingers.
