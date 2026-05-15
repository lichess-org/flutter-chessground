# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Chessground is a Flutter chessboard UI package developed for lichess.org. It contains no chess logic — all game logic is handled externally via the `dartchess` dependency. The package is published on pub.dev as `chessground`.

## Commands

```bash
flutter pub get          # Install dependencies
flutter test             # Run all tests
flutter test test/fen_test.dart  # Run a single test file
flutter analyze          # Run static analysis (strict mode: strict-casts, strict-inference, strict-raw-types)
dart format lib/ test/   # Format all source files
```

CI uses Flutter **beta** channel.

## Architecture

### Public API

All public exports go through `lib/chessground.dart`. Internal implementation lives in `lib/src/`.

### Three Board Widgets

- **`Chessboard`** (`src/widgets/board.dart`) — Main interactive board. Two constructors: `Chessboard()` for interactive play (requires a `ChessboardController`) and `Chessboard.fixed()` for non-interactive display with animations.
- **`StaticChessboard`** (`src/widgets/static_board.dart`) — Read-only board optimized for scrollable contexts (uses deferred loading).
- **`ChessboardEditor`** (`src/widgets/board_editor.dart`) — Position editor with drag and edit pointer modes.

### Core Data Flow

The board is driven by a controller and immutable data objects:
- **`ChessboardController`** (`src/widgets/board_controller.dart`) — Owns board position, game state, and piece animations. Create once in `initState`, dispose in `dispose`. Two constructors:
  - `ChessboardController(fen: fen, initialGame: game)` — for interactive boards.
  - `ChessboardController.nonInteractive(initialFen: fen)` — for non-interactive display boards (`Chessboard.fixed()`).
  - `updatePosition(String fen, {GameData? game, Move? lastMove, Move? lastDrop})` — advance position with animation. Pass `game:` for interactive boards, `lastMove:` for non-interactive.
  - `jumpToPosition(String fen, {GameData? game, Move? lastMove})` — switch position without animation.
- **`GameData`** — Immutable snapshot of interactive game state: `playerSide`, `sideToMove`, `validMoves`, `lastMove`, `premovable`, `droppable`, `promotionMove`, `isCheck`. Does **not** carry the FEN — that is always passed separately.
- **`ChessboardSettings`** — All visual and behavioral configuration (theme, animations, piece shift method, draw shapes, coordinates, etc.).
- **`Pieces`** (`Map<Square, Piece>`) — Board position, typically derived from FEN via `readFen()`.

### Shape System

`Shape` is a sealed class hierarchy with three variants: `Arrow`, `Circle`, and `PieceShape`. Shapes are drawn on the board via custom painters in `src/widgets/shape.dart`.

### Key Types (from dartchess)

`Square`, `Piece`, `Side`, `Move` come from the `dartchess` package. Collection types `IMap`/`ISet` come from `fast_immutable_collections`.

### Image Caching

`ChessgroundImages` is a singleton that manages piece image caching to prevent blinking during rebuilds. It supports optional precaching at app startup.

## Code Conventions

- Immutable data classes with `@immutable`, `copyWith()`, manual `==`/`hashCode`
- Single quotes for strings (enforced by linter)
- Linting via `package:lint/package.yaml` with all strict modes enabled
- All files must be formatted with `dart format` before committing
