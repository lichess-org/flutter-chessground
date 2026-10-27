import 'package:chessground/chessground.dart';
import 'package:dartchess/dartchess.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Şahî Ivory Brown registers all 12 Lichess piece images', () {
    final set = PieceSet.shahiIvoryBrown;
    expect(set.label, 'Şahî Ivory Brown');
    expect(set.assets.length, 12);

    const fileNames = <PieceKind, String>{
      PieceKind.blackRook: 'bR',
      PieceKind.blackPawn: 'bP',
      PieceKind.blackKnight: 'bN',
      PieceKind.blackBishop: 'bB',
      PieceKind.blackQueen: 'bQ',
      PieceKind.blackKing: 'bK',
      PieceKind.whiteRook: 'wR',
      PieceKind.whitePawn: 'wP',
      PieceKind.whiteKnight: 'wN',
      PieceKind.whiteBishop: 'wB',
      PieceKind.whiteQueen: 'wQ',
      PieceKind.whiteKing: 'wK',
    };

    for (final entry in fileNames.entries) {
      final asset = set.assets[entry.key];
      expect(asset, isA<AssetImage>());
      final image = asset! as AssetImage;
      expect(image.assetName, 'assets/piece_sets/shahi-ivory-brown/${entry.value}.webp');
      expect(image.package, 'chessground');
    }
  });
}
