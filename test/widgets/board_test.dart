import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dartchess/dartchess.dart' as dc;
import 'package:chessground/chessground.dart';

const boardSize = 200.0;

Widget buildInteractableBoard({
  required Settings initialSettings,
  orientation = Color.white,
  initialFen = dc.kInitialFEN,
}) {
  Settings settings = initialSettings;
  dc.Position<dc.Chess> position = dc.Chess.fromSetup(dc.Setup.parseFen(initialFen));
  Move? lastMove;

  return Directionality(
      textDirection: TextDirection.ltr,
      child: StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
        return Board(
          orientation: orientation,
          size: boardSize,
          fen: position.fen,
          settings: settings,
          lastMove: lastMove,
          validMoves: dc.algebraicLegalMoves(position),
          onMove: (Move move) {
            setState(() {
              position = position.playUnchecked(dc.Move.fromUci(move.uci));
              lastMove = move;
            });
          },
        );
      }));
}

Offset squareOffset(SquareId id, {Color orientation = Color.white}) {
  return Coord.fromSquareId(id).offset(orientation, boardSize / 8);
}

void main() {
  group('Non-interactable board', () {
    const viewOnlyBoard = Directionality(
        textDirection: TextDirection.ltr,
        child: Board(orientation: Color.white, size: boardSize, fen: dc.kInitialFEN));

    testWidgets('initial position display', (WidgetTester tester) async {
      await tester.pumpWidget(viewOnlyBoard);

      expect(find.byType(Board), findsOneWidget);
      expect(find.byType(PieceWidget), findsNWidgets(32));
    });

    testWidgets('cannot select piece', (WidgetTester tester) async {
      await tester.pumpWidget(viewOnlyBoard);
      await tester.tap(find.byKey(const Key('e2-whitepawn')));
      await tester.pump();

      expect(find.byKey(const Key('e2-selected')), findsNothing);
    });
  });

  group('Interactable board', () {
    testWidgets('selecting and deselecting a square', (WidgetTester tester) async {
      await tester.pumpWidget(buildInteractableBoard(
          initialSettings:
              const Settings(interactable: true, interactableColor: InteractableColor.both)));
      await tester.tap(find.byKey(const Key('a2-whitepawn')));
      await tester.pump();

      expect(find.byKey(const Key('a2-selected')), findsOneWidget);
      expect(find.byType(MoveDest), findsNWidgets(2));

      // selecting same keeps it selected
      await tester.tap(find.byKey(const Key('a2-whitepawn')));
      await tester.pump();
      expect(find.byKey(const Key('a2-selected')), findsOneWidget);
      expect(find.byType(MoveDest), findsNWidgets(2));

      // selecting another square
      await tester.tap(find.byKey(const Key('a1-whiterook')));
      await tester.pump();
      expect(find.byKey(const Key('a1-selected')), findsOneWidget);
      expect(find.byType(MoveDest), findsNothing);

      // selecting an opposite piece deselects
      await tester.tap(find.byKey(const Key('e7-blackpawn')));
      await tester.pump();
      expect(find.byKey(const Key('a1-selected')), findsNothing);
      expect(find.byType(MoveDest), findsNothing);

      // selecting an empty square deselects
      await tester.tap(find.byKey(const Key('a1-whiterook')));
      await tester.pump();
      expect(find.byKey(const Key('a1-selected')), findsOneWidget);
      await tester.tapAt(squareOffset('c4'));
      await tester.pump();
      expect(find.byKey(const Key('a1-selected')), findsNothing);
    });

    testWidgets('play e2-e4 move by tap', (WidgetTester tester) async {
      await tester.pumpWidget(buildInteractableBoard(
          initialSettings:
              const Settings(interactable: true, interactableColor: InteractableColor.both)));
      await tester.tap(find.byKey(const Key('e2-whitepawn')));
      await tester.pump();

      expect(find.byKey(const Key('e2-selected')), findsOneWidget);
      expect(find.byType(MoveDest), findsNWidgets(2));

      await tester.tapAt(squareOffset('e4'));
      await tester.pump();
      expect(find.byKey(const Key('e2-selected')), findsNothing);
      expect(find.byType(MoveDest), findsNothing);
      expect(find.byKey(const Key('e4-whitepawn')), findsOneWidget);
      expect(find.byKey(const Key('e2-whitepawn')), findsNothing);
      expect(find.byKey(const Key('e2-lastMove')), findsOneWidget);
      expect(find.byKey(const Key('e4-lastMove')), findsOneWidget);
    });

    testWidgets('castling by taping king then rook is possible', (WidgetTester tester) async {
      await tester.pumpWidget(buildInteractableBoard(
          initialFen: 'r1bqk1nr/pppp1ppp/2n5/2b1p3/2B1P3/5N2/PPPP1PPP/RNBQK2R w KQkq - 4 4',
          initialSettings:
              const Settings(interactable: true, interactableColor: InteractableColor.both)));
      await tester.tap(find.byKey(const Key('e1-whiteking')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('h1-whiterook')));
      await tester.pump();
      expect(find.byKey(const Key('e1-whiteking')), findsNothing);
      expect(find.byKey(const Key('h1-whiterook')), findsNothing);
      expect(find.byKey(const Key('g1-whiteking')), findsOneWidget);
      expect(find.byKey(const Key('f1-whiterook')), findsOneWidget);
      expect(find.byKey(const Key('e1-lastMove')), findsOneWidget);
      expect(find.byKey(const Key('h1-lastMove')), findsOneWidget);
    });
  });
}