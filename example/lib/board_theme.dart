import 'package:chessground/chessground.dart';

/// The chessboard theme.
enum BoardTheme {
  blue('Blue', ChessboardColorScheme.blue),
  blue2('Blue2', ChessboardColorScheme.blue2),
  blue3('Blue3', ChessboardColorScheme.blue3),
  blueMarble('Blue Marble', ChessboardColorScheme.blueMarble),
  canvas('Canvas', ChessboardColorScheme.canvas),
  wood('Wood', ChessboardColorScheme.wood),
  wood2('Wood2', ChessboardColorScheme.wood2),
  wood3('Wood3', ChessboardColorScheme.wood3),
  wood4('Wood4', ChessboardColorScheme.wood4),
  maple('Maple', ChessboardColorScheme.maple),
  maple2('Maple 2', ChessboardColorScheme.maple2),
  brown('Brown', ChessboardColorScheme.brown),
  leather('Leather', ChessboardColorScheme.leather),
  ic('IC', ChessboardColorScheme.ic),
  green('Green', ChessboardColorScheme.green),
  marble('Marble', ChessboardColorScheme.marble),
  greenPlastic('Green Plastic', ChessboardColorScheme.greenPlastic),
  grey('Grey', ChessboardColorScheme.grey),
  metal('Metal', ChessboardColorScheme.metal),
  olive('Olive', ChessboardColorScheme.olive),
  newspaper('Newspaper', ChessboardColorScheme.newspaper),
  purpleDiag('Purple-Diag', ChessboardColorScheme.purpleDiag),
  pinkPyramid('Pink', ChessboardColorScheme.pinkPyramid),
  horsey('Horsey', ChessboardColorScheme.horsey);

  final String label;

  final ChessboardColorScheme colors;

  const BoardTheme(this.label, this.colors);
}
