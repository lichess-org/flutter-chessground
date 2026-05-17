# Migration Guide

## 9.x → 10.0.0

### Interactive board: controller replaces widget parameters

The `Chessboard()` constructor (interactive board) now uses a controller pattern,
similar to Flutter's `TextEditingController` or `ScrollController`. Instead of
passing `fen:`, `game:`, and `lastMove:` to the widget on every `setState`, you
create a `ChessboardController` once and call `updatePosition()` on it when the
game state changes.

`GameData` is now a pure state snapshot — it holds game state fields
(`sideToMove`, `validMoves`, `lastMove`, etc.), but no callbacks and no FEN.
The board position (FEN) is passed directly to the controller constructor and
update methods. Callbacks (`onMove`, `onPromotionSelection`, `onSetPremove`) are
parameters on the `Chessboard` widget. `Premovable` carries only the current
premove, not the setter.

**Before (9.x)**

```dart
class _MyBoardState extends State<MyBoard> {
  Position _position = Chess.initial;
  Move? _lastMove;
  NormalMove? _promotionMove;

  GameData _buildGame() => GameData(
    playerSide: PlayerSide.white,
    isCheck: _position.isCheck,
    sideToMove: _position.turn == Side.white ? Side.white : Side.black,
    validMoves: makeLegalMoves(_position),
    promotionMove: _promotionMove,
    onMove: (move, {viaDragAndDrop}) {
      setState(() {
        _position = _position.playUnchecked(move);
        _lastMove = move;
      });
    },
    onPromotionSelection: (role) {
      setState(() {
        if (role != null) {
          _position = _position.playUnchecked(
            _promotionMove!.withPromotion(role),
          );
        }
        _promotionMove = null;
      });
    },
  );

  @override
  Widget build(BuildContext context) {
    return Chessboard(
      size: 400,
      orientation: Side.white,
      fen: _position.fen,
      lastMove: _lastMove,
      game: _buildGame(),
    );
  }
}
```

**After (10.0.0)**

```dart
class _MyBoardState extends State<MyBoard> {
  late ChessboardController _controller;
  Position _position = Chess.initial;
  Move? _lastMove;
  NormalMove? _promotionMove;

  @override
  void initState() {
    super.initState();
    _controller = ChessboardController(fen: _position.fen, game: _buildGame());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  GameData _buildGame() => GameData(
    lastMove: _lastMove,
    playerSide: PlayerSide.white,
    isCheck: _position.isCheck,
    sideToMove: _position.turn == Side.white ? Side.white : Side.black,
    validMoves: makeLegalMoves(_position),
    promotionMove: _promotionMove,
  );

  void _onMove(Move move, {bool? viaDragAndDrop}) {
    _position = _position.playUnchecked(move);
    _lastMove = move;
    _controller.updatePosition(
      _position.fen,
      game: _buildGame(),
      lastDrop: viaDragAndDrop == true ? move : null,
    );
  }

  void _onPromotionSelection(Role? role) {
    if (role != null) {
      _position = _position.playUnchecked(
        _promotionMove!.withPromotion(role),
      );
      _lastMove = _promotionMove!.withPromotion(role);
    }
    _promotionMove = null;
    _controller.updatePosition(_position.fen, game: _buildGame());
  }

  @override
  Widget build(BuildContext context) {
    return Chessboard(
      controller: _controller,
      size: 400,
      orientation: Side.white,
      onMove: _onMove,
      onPromotionSelection: _onPromotionSelection,
    );
  }
}
```

### Parameter mapping

| 9.x | 10.0.0 |
|---|---|
| `Chessboard(fen: newFen)` | `controller.updatePosition(newFen, game: ...)` |
| `Chessboard(lastMove: move)` | `GameData(lastMove: move, ...)` passed to `controller.updatePosition()` |
| `Chessboard(game: newGame)` | `controller.updatePosition(fen, game: newGame)` |
| `GameData(onMove: fn)` | `Chessboard(onMove: fn)` |
| `GameData(onPromotionSelection: fn)` | `Chessboard(onPromotionSelection: fn)` |
| `Premovable(onSetPremove: fn, premove: m)` | `Chessboard(onSetPremove: fn)` + `Premovable(premove: m)` |
| `explosionSquares: squares` | `controller.triggerExplosion(squares)` |

The `lastDrop:` parameter on `updatePosition()` replaces the internal tracking
that previously happened automatically. Pass the move as `lastDrop:` when
`viaDragAndDrop == true` to suppress the redundant slide animation for the
dragged piece.

### `Chessboard.fixed()` is unchanged

The non-interactive constructor keeps the same signature, except `explosionSquares`
has been removed (it had no effect without a controller):

```dart
// No changes needed here (unless you were using explosionSquares)
Chessboard.fixed(
  size: 400,
  orientation: Side.white,
  fen: fen,
  lastMove: lastMove,
)
```

### Explosion squares: widget parameter → controller method

Previously you could pass `explosionSquares:` directly to the `Chessboard()` widget.
Now call `controller.triggerExplosion(squares)` instead, typically right after
`controller.updatePosition(...)`:

```dart
// Before (9.x)
Chessboard(
  fen: newFen,
  game: game,
  explosionSquares: explodedSquares,
)

// After (10.0.0)
controller.updatePosition(newFen, game: newGameData);
if (explodedSquares != null) {
  controller.triggerExplosion(explodedSquares);
}
```

### `squareHighlights` removed from interactive `Chessboard()`

This parameter was only useful for `Chessboard.fixed()` and has been removed from
the interactive constructor. If you were passing `squareHighlights:` to `Chessboard()`,
remove it — it had no meaningful effect for an interactive board.

### Ownership and lifecycle

The caller creates and owns the controller. The board attaches to it in
`initState` and detaches in `dispose` — it does **not** dispose the controller.
You are responsible for calling `controller.dispose()` when the owning state is
disposed.

```dart
@override
void dispose() {
  _controller.dispose(); // required
  super.dispose();
}
```

### Shape drawing: callbacks removed, controller manages drawn shapes

`DrawShapeOptions` no longer takes `onCompleteShape` or `onClearShapes`
callbacks. The controller now owns the set of user-drawn shapes and the board
updates itself automatically — no parent `setState` required.

The externally supplied `Chessboard.shapes` parameter still works the same way
and is intended for shapes you control from outside (engine arrows, analysis
annotations, etc.). The board renders the union of both sets.

**Before (9.x)**

```dart
class _MyBoardState extends State<MyBoard> {
  Set<Shape> _shapes = {};

  ChessboardSettings get _settings => ChessboardSettings(
    drawShape: DrawShapeOptions(
      enable: true,
      onCompleteShape: (shape) {
        setState(() => _shapes = {..._shapes, shape});
      },
      onClearShapes: () {
        setState(() => _shapes = {});
      },
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Chessboard(
      // ...
      settings: _settings,
      shapes: _shapes,
    );
  }
}
```

**After (10.0.0)**

```dart
class _MyBoardState extends State<MyBoard> {
  late ChessboardController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ChessboardController(fen: Chess.initial.fen, game: _buildGame());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Chessboard(
      controller: _controller,
      // ...
      settings: const ChessboardSettings(
        drawShape: DrawShapeOptions(enable: true),
      ),
      // shapes: externalShapes,  ← only needed for externally supplied shapes
    );
  }
}
```

To clear drawn shapes from outside the board (e.g. when the position advances):

```dart
_controller.clearDrawnShapes();
```

To read the current drawn shapes (e.g. to persist them):

```dart
final drawn = _controller.drawnShapes; // Set<Shape>
```

### Parameter mapping (shape drawing)

| 9.x | 10.0.0 |
|---|---|
| `DrawShapeOptions(onCompleteShape: fn)` | removed — controller handles it internally |
| `DrawShapeOptions(onClearShapes: fn)` | removed — call `controller.clearDrawnShapes()` instead |
| `setState(() => shapes.add(shape))` in `onCompleteShape` | automatic — board calls `controller.toggleDrawnShape()` internally |
| toggle-on-redraw logic in `onCompleteShape` | built into the board — drawing the same shape twice removes it |
| `setState(() => shapes = {})` in `onClearShapes` | `controller.clearDrawnShapes()` |
| `Chessboard(shapes: userDrawnShapes)` | use `Chessboard(shapes: ...)` for *external* shapes only |
