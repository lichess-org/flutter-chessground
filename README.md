<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->

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
- draw arrows on board
- move annotations

## Getting started

This package exports a `Board` widget which can be interactable or not. It is
entirely configurable with a `Settings` object.

## Usage

This will display a non-interactable board from the starting position, using the
default theme:

```dart
import 'package:flutter/material.dart';
import 'package:chessground/chessground.dart';

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
        child: Board(
          size: screenWidth,
          data: BoardData(
            interactableSide: InteractableSide.none,
            orientation: Side.white,
            fen: fen,
          ),
        ),
      ),
    );
  }
}
```

See the example app for an interactable version against a random bot.
