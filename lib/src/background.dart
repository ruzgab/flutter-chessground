import 'package:flutter/material.dart';
import 'models.dart' as cg;

/// Board background
///
/// Use the static const members to ensure flutter don't rebuild the board more
/// than once
class Background extends StatelessWidget {
  const Background({
    Key? key,
    required this.lightSquare,
    required this.darkSquare,
    this.coordinates = false,
    this.orientation = cg.Color.white,
  }) : super(key: key);

  final Color lightSquare;
  final Color darkSquare;
  final bool coordinates;
  final cg.Color orientation;

  static const brown = Background(
    lightSquare: Color(0xfff0d9b6),
    darkSquare: Color(0xffb58863),
  );
  static const brownWhiteCoords = Background(
    lightSquare: Color(0xfff0d9b6),
    darkSquare: Color(0xffb58863),
    coordinates: true,
    orientation: cg.Color.white,
  );
  static const brownBlackCoords = Background(
    lightSquare: Color(0xfff0d9b6),
    darkSquare: Color(0xffb58863),
    coordinates: true,
    orientation: cg.Color.black,
  );
  static const blue = Background(
    lightSquare: Color(0xffdee3e6),
    darkSquare: Color(0xff8ca2ad),
  );
  static const blueWhiteCoords = Background(
    lightSquare: Color(0xffdee3e6),
    darkSquare: Color(0xff8ca2ad),
    coordinates: true,
    orientation: cg.Color.white,
  );
  static const blueBlackCoords = Background(
    lightSquare: Color(0xffdee3e6),
    darkSquare: Color(0xff8ca2ad),
    coordinates: true,
    orientation: cg.Color.black,
  );
  static const green = Background(
    lightSquare: Color(0xffffffdd),
    darkSquare: Color(0xff86a666),
  );
  static const greenWhiteCoords = Background(
    lightSquare: Color(0xffffffdd),
    darkSquare: Color(0xff86a666),
    coordinates: true,
    orientation: cg.Color.white,
  );
  static const greenBlackCoords = Background(
    lightSquare: Color(0xffffffdd),
    darkSquare: Color(0xff86a666),
    coordinates: true,
    orientation: cg.Color.black,
  );

  @override
  Widget build(BuildContext context) {
    debugPrint('build chessground background');
    return SizedBox.expand(
      child: Column(
        children: List.generate(
          8,
          (rank) => Expanded(
            child: Row(
              children: List.generate(
                8,
                (file) => Expanded(
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                        color: ((rank + file) % 2 == 0)
                            ? lightSquare
                            : darkSquare),
                    child: coordinates
                        ? Coordinate(
                            rank: rank,
                            file: file,
                            orientation: orientation,
                            color: ((rank + file) % 2 == 0)
                                ? darkSquare
                                : lightSquare,
                          )
                        : null,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Coordinate extends StatelessWidget {
  final int rank;
  final int file;
  final Color color;
  final cg.Color orientation;

  const Coordinate({
    Key? key,
    required this.rank,
    required this.file,
    required this.color,
    required this.orientation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final coordStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 11.0,
      color: color,
      fontFamily: 'Roboto',
    );
    return Stack(
      children: [
        if (file == 7)
          Align(
            alignment: Alignment.topRight,
            child: Text(
              orientation == cg.Color.white ? '${8 - rank}' : '${rank + 1}',
              style: coordStyle,
            ),
          ),
        if (rank == 7)
          Align(
            alignment: Alignment.bottomLeft,
            child: Text(
              orientation == cg.Color.white
                  ? String.fromCharCode(97 + file)
                  : String.fromCharCode(97 + 7 - file),
              style: coordStyle,
            ),
          ),
      ],
    );
  }
}
