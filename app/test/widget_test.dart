import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:declutter_ai/main.dart';
import 'package:declutter_ai/src/features/session/presentation/session_timer_screen.dart';

void main() {
  testWidgets('app boots to capture screen even when camera unavailable', (tester) async {
    await tester.pumpWidget(const DeclutterAIApp());

    // Allow the initial camera request future to resolve.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Capture clutter zone'), findsOneWidget);
    expect(find.text('Snap zone'), findsOneWidget);
    expect(find.textContaining('camera'), findsWidgets);
  });

  testWidgets('session timer logs decisions with notes', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SessionTimerScreen(),
      ),
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Keep'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextField),
      'Kept the keepsake box on the top shelf.',
    );

    await tester.tap(find.text('Save decision'));
    await tester.pumpAndSettle();

    expect(find.text('Session log'), findsOneWidget);
    expect(
      find.textContaining('keepsake box', findRichText: true),
      findsOneWidget,
    );
  });
}
