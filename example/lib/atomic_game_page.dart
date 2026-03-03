import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:chessground/chessground.dart';
import 'package:dartchess/dartchess.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';

import 'board_theme.dart';

/// A page that demonstrates atomic chess explosion animations.
///
/// The user controls White; Black plays random legal moves.
/// Every capture triggers explosion animations on the affected squares.
class AtomicGamePage extends StatefulWidget {
  const AtomicGamePage({super.key});

  @override
  State<AtomicGamePage> createState() => _AtomicGamePageState();
}

class _AtomicGamePageState extends State<AtomicGamePage> {
  Atomic position = Atomic.initial;
  String fen = kInitialBoardFEN;
  Move? lastMove;
  NormalMove? promotionMove;
  ValidMoves validMoves = IMap(const {});
  ISet<Square>? explosionSquares;
  BoardTheme boardTheme = BoardTheme.brown;
  PieceSet pieceSet = PieceSet.gioco;

  @override
  void initState() {
    super.initState();
    validMoves = makeLegalMoves(position);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Atomic Chess'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'New game',
            onPressed: _newGame,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Center(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final size =
                          min(constraints.maxWidth, constraints.maxHeight);
                      return Chessboard(
                        size: size,
                        settings: ChessboardSettings(
                          pieceAssets: pieceSet.assets,
                          colorScheme: boardTheme.colors,
                          animationDuration: const Duration(milliseconds: 200),
                        ),
                        orientation: Side.white,
                        fen: fen,
                        lastMove: lastMove,
                        explosionSquares: explosionSquares,
                        game: GameData(
                          playerSide: position.isGameOver
                              ? PlayerSide.none
                              : PlayerSide.white,
                          validMoves: validMoves,
                          sideToMove: position.turn,
                          isCheck: position.isCheck,
                          promotionMove: promotionMove,
                          onMove: _onUserMove,
                          onPromotionSelection: _onPromotionSelection,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _StatusBar(position: position),
              const SizedBox(height: 12),
              _SettingsRow(
                boardTheme: boardTheme,
                pieceSet: pieceSet,
                onBoardThemeChanged: (t) => setState(() => boardTheme = t),
                onPieceSetChanged: (p) => setState(() => pieceSet = p),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('New Game'),
                onPressed: _newGame,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _newGame() {
    setState(() {
      position = Atomic.initial;
      fen = position.fen;
      validMoves = makeLegalMoves(position);
      lastMove = null;
      promotionMove = null;
      explosionSquares = null;
    });
  }

  void _onUserMove(Move move, {bool? viaDragAndDrop}) {
    if (move is NormalMove && _isPromotionPawnMove(move)) {
      setState(() => promotionMove = move);
      return;
    }
    _applyMove(move, scheduleBotAfter: true);
  }

  void _onPromotionSelection(Role? role) {
    if (role == null) {
      setState(() => promotionMove = null);
    } else if (promotionMove != null) {
      _applyMove(promotionMove!.withPromotion(role), scheduleBotAfter: true);
    }
  }

  bool _isPromotionPawnMove(NormalMove move) {
    return move.promotion == null &&
        position.board.roleAt(move.from) == Role.pawn &&
        ((move.to.rank == Rank.eighth && position.turn == Side.white) ||
            (move.to.rank == Rank.first && position.turn == Side.black));
  }

  void _applyMove(Move move, {bool scheduleBotAfter = false}) {
    if (!position.isLegal(move)) return;

    final newExplosions = ISet(position.explosionSquares(move).squares);

    setState(() {
      position = position.playUnchecked(move) as Atomic;
      fen = position.fen;
      lastMove = move;
      validMoves = makeLegalMoves(position);
      promotionMove = null;
      explosionSquares = newExplosions;
    });

    if (scheduleBotAfter && !position.isGameOver) {
      _scheduleBotMove();
    }
  }

  void _scheduleBotMove() {
    final delay = Duration(milliseconds: Random().nextInt(600) + 400);
    Future.delayed(delay, () {
      if (!mounted || position.isGameOver || position.turn != Side.black) {
        return;
      }
      _playBotMove();
    });
  }

  void _playBotMove() {
    final random = Random();
    final allMoves = [
      for (final entry in position.legalMoves.entries)
        for (final dest in entry.value.squares)
          NormalMove(from: entry.key, to: dest),
    ];
    if (allMoves.isEmpty) return;

    // Prefer captures so explosions are demonstrated more often.
    final captures =
        allMoves.where((m) => position.board.occupied.has(m.to)).toList();
    NormalMove mv = (captures.isNotEmpty && random.nextDouble() < 0.65
        ? (captures..shuffle(random)).first
        : (allMoves..shuffle(random)).first);

    if (_isPromotionPawnMove(mv)) {
      mv = mv.withPromotion(Role.queen);
    }

    _applyMove(mv);
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar({required this.position});

  final Position position;

  @override
  Widget build(BuildContext context) {
    final String text;
    if (position.isGameOver) {
      final winner = position.outcome?.winner;
      text = switch (winner) {
        Side.white => 'White wins!',
        Side.black => 'Black wins!',
        null => "It's a draw!",
      };
    } else {
      text = position.turn == Side.white
          ? 'Your turn (White)'
          : 'Black is thinking…';
    }

    return Text(
      text,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.titleMedium,
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.boardTheme,
    required this.pieceSet,
    required this.onBoardThemeChanged,
    required this.onPieceSetChanged,
  });

  final BoardTheme boardTheme;
  final PieceSet pieceSet;
  final ValueChanged<BoardTheme> onBoardThemeChanged;
  final ValueChanged<PieceSet> onPieceSetChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        _PickerChip(
          label: 'Board',
          value: boardTheme.label,
          onTap: () => _showPicker<BoardTheme>(
            context,
            choices: BoardTheme.values,
            selected: boardTheme,
            labelOf: (t) => t.label,
            onChanged: onBoardThemeChanged,
          ),
        ),
        _PickerChip(
          label: 'Pieces',
          value: pieceSet.label,
          onTap: () => _showPicker<PieceSet>(
            context,
            choices: PieceSet.values,
            selected: pieceSet,
            labelOf: (p) => p.label,
            onChanged: onPieceSetChanged,
          ),
        ),
      ],
    );
  }

  void _showPicker<T>(
    BuildContext context, {
    required List<T> choices,
    required T selected,
    required String Function(T) labelOf,
    required ValueChanged<T> onChanged,
  }) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        contentPadding: const EdgeInsets.only(top: 12),
        scrollable: true,
        content: RadioGroup<T>(
          groupValue: selected,
          onChanged: (v) {
            if (v != null) onChanged(v);
            Navigator.of(ctx).pop();
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: choices
                .map((c) => RadioListTile<T>(title: Text(labelOf(c)), value: c))
                .toList(growable: false),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

class _PickerChip extends StatelessWidget {
  const _PickerChip(
      {required this.label, required this.value, required this.onTap});

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text('$label: $value'),
      onPressed: onTap,
    );
  }
}
