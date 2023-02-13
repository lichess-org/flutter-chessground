import 'board_color_scheme.dart';

enum BoardTheme {
  blue('Blue'),
  blue2('Blue2'),
  blue3('Blue3'),
  blueMarble('Blue Marble'),
  canvas('Canvas'),
  wood('Wood'),
  wood2('Wood2'),
  wood3('Wood3'),
  wood4('Wood4'),
  maple('Maple'),
  maple2('Maple 2'),
  brown('Brown'),
  leather('Leather'),
  green('Green'),
  marble('Marble'),
  greenPlastic('Green Plastic'),
  grey('Grey'),
  metal('Metal'),
  olive('Olive'),
  newspaper('Newspaper'),
  purpleDiag('Purple-Diag'),
  pinkPyramid('Pink'),
  horsey('Horsey');

  final String label;

  const BoardTheme(this.label);

  BoardColorScheme get colors {
    switch (this) {
      case BoardTheme.brown:
        return BoardColorScheme.brown;
      case BoardTheme.blue:
        return BoardColorScheme.blue;
      case BoardTheme.green:
        return BoardColorScheme.green;
      case BoardTheme.blue2:
        return BoardColorScheme.blue2;
      case BoardTheme.blue3:
        return BoardColorScheme.blue3;
      case BoardTheme.blueMarble:
        return BoardColorScheme.blueMarble;
      case BoardTheme.canvas:
        return BoardColorScheme.canvas;
      case BoardTheme.greenPlastic:
        return BoardColorScheme.greenPlastic;
      case BoardTheme.grey:
        return BoardColorScheme.grey;
      case BoardTheme.horsey:
        return BoardColorScheme.horsey;
      case BoardTheme.leather:
        return BoardColorScheme.leather;
      case BoardTheme.maple:
        return BoardColorScheme.maple;
      case BoardTheme.maple2:
        return BoardColorScheme.maple2;
      case BoardTheme.marble:
        return BoardColorScheme.marble;
      case BoardTheme.metal:
        return BoardColorScheme.metal;
      case BoardTheme.newspaper:
        return BoardColorScheme.newspaper;
      case BoardTheme.olive:
        return BoardColorScheme.olive;
      case BoardTheme.pinkPyramid:
        return BoardColorScheme.pinkPyramid;
      case BoardTheme.purpleDiag:
        return BoardColorScheme.purpleDiag;
      case BoardTheme.wood:
        return BoardColorScheme.wood;
      case BoardTheme.wood2:
        return BoardColorScheme.wood2;
      case BoardTheme.wood3:
        return BoardColorScheme.wood3;
      case BoardTheme.wood4:
        return BoardColorScheme.wood4;
    }
  }
}
