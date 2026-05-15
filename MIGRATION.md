# Migration Guide

## 9.x → 10.0.0

### Interactive board: controller replaces widget parameters

The `Chessboard()` constructor (interactive board) now uses a controller pattern,
similar to Flutter's `TextEditingController` or `ScrollController`. Instead of
passing `fen:`, `game:`, and `lastMove:` to the widget on every `setState`, you
create a `ChessboardController` once and call `updatePosition()` on it when the
game state changes.

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
  NormalMove? _promotionMove;
  Move? _lastMove;

  @override
  void initState() {
    super.initState();
    _controller = ChessboardController(
      initialFen: _position.fen,
      initialGame: _buildGame(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  GameData _buildGame() => GameData(
    playerSide: PlayerSide.white,
    isCheck: _position.isCheck,
    sideToMove: _position.turn == Side.white ? Side.white : Side.black,
    validMoves: makeLegalMoves(_position),
    promotionMove: _promotionMove,
    onMove: (move, {viaDragAndDrop}) {
      _position = _position.playUnchecked(move);
      _lastMove = move;
      _controller.updatePosition(
        _position.fen,
        game: _buildGame(),
        lastMove: _lastMove,
        lastDrop: viaDragAndDrop == true ? move : null,
      );
    },
    onPromotionSelection: (role) {
      if (role != null) {
        _position = _position.playUnchecked(
          _promotionMove!.withPromotion(role),
        );
        _lastMove = _promotionMove!.withPromotion(role);
      }
      _promotionMove = null;
      _controller.updatePosition(
        _position.fen,
        game: _buildGame(),
        lastMove: _lastMove,
      );
    },
  );

  @override
  Widget build(BuildContext context) {
    return Chessboard(
      controller: _controller,
      size: 400,
      orientation: Side.white,
    );
  }
}
```

### Parameter mapping

| 9.x widget constructor param | 10.0.0 equivalent |
|---|---|
| `fen: newFen` | `controller.updatePosition(newFen, ...)` |
| `game: newGame` | `controller.updatePosition(..., game: newGame)` |
| `lastMove: move` | `controller.updatePosition(..., lastMove: move)` |

The `lastDrop:` parameter on `updatePosition()` replaces the internal tracking
that previously happened automatically. Pass the move as `lastDrop:` when
`viaDragAndDrop == true` to suppress the redundant slide animation for the
dragged piece.

### `Chessboard.fixed()` is unchanged

The non-interactive constructor keeps the same signature:

```dart
// No changes needed here
Chessboard.fixed(
  size: 400,
  orientation: Side.white,
  fen: fen,
  lastMove: lastMove,
)
```

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

### Why the change?

With the old pattern the parent widget had to call `setState()` on every move,
which rebuilt the entire widget subtree above the board before the board itself
could update. With the controller pattern, `updatePosition()` notifies the board
directly — the board rebuilds itself without touching the parent.
