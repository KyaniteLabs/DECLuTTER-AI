import 'package:declutter_ai/src/features/detect/domain/detection.dart';
import 'package:declutter_ai/src/features/grouping/domain/detection_group.dart';
import 'package:declutter_ai/src/features/grouping/domain/grouped_detection_result.dart';
import 'package:declutter_ai/src/features/session/domain/session_decision.dart';
import 'package:declutter_ai/src/features/session/presentation/session_timer_screen.dart';
import 'package:declutter_ai/src/features/session/services/cash_to_clear_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

DetectionGroup buildGroup({
  required String id,
  required String label,
  required int count,
}) {
  return DetectionGroup(
    id: id,
    rawLabel: label,
    displayLabel: label[0].toUpperCase() + label.substring(1),
    detections: List.generate(
      count,
      (index) => Detection(
        label: label,
        confidence: 0.9 - index * 0.1,
        boundingBox: Rect.fromLTWH(0.1 * index, 0, 0.2, 0.2),
      ),
    ),
  );
}

GroupedDetectionResult buildGroupedResult(List<DetectionGroup> groups) {
  final totalDetections =
      groups.fold<int>(0, (sum, group) => sum + group.count);
  return GroupedDetectionResult(
    groups: groups,
    totalDetections: totalDetections,
    originalSize: const Size(400, 300),
    isMocked: false,
  );
}

void main() {
  group('SessionDecisionHistory', () {
    testWidgets('summarizes group progress alongside logged decisions',
        (tester) async {
      final groups = [
        buildGroup(id: 'group_1', label: 'books', count: 2),
        buildGroup(id: 'group_2', label: 'mug', count: 1),
      ];
      final decisions = [
        SessionDecision(
          groupId: 'group_1',
          groupLabel: groups.first.friendlyLabel,
          groupTotal: groups.first.count,
          category: DecisionCategory.keep,
          createdAt: DateTime(2024, 1, 1, 10, 30),
          note: 'Shelved the novels',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: SessionDecisionHistory(
              decisions: decisions,
              groupedResult: buildGroupedResult(groups),
            ),
          ),
        ),
      );

      expect(find.text('Books: 1/2 sorted'), findsOneWidget);
      expect(find.text('Mug: 0/1 sorted'), findsOneWidget);
      expect(find.text('Group group_1 • Books (2 items)'), findsOneWidget);
      expect(find.text('Progress: 1/2 items sorted'), findsOneWidget);
      expect(find.text('Shelved the novels'), findsOneWidget);
    });
  });

  group('SessionTimerScreen', () {
    testWidgets('surfaces grouped detections in the sprint UI', (tester) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final groups = [
        buildGroup(id: 'group_1', label: 'books', count: 2),
        buildGroup(id: 'group_2', label: 'mug', count: 1),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: SessionTimerScreen(
            groupedResult: buildGroupedResult(groups),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify group labels appear in decision cards.
      expect(find.text('Books · 2 items'), findsOneWidget);
      expect(find.text('Mug · 1 item'), findsOneWidget);
    });

    testWidgets('logs decisions against the correct group metadata',
        (tester) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final books = buildGroup(id: 'group_1', label: 'books', count: 2);
      final mug = buildGroup(id: 'group_2', label: 'mug', count: 1);

      await tester.pumpWidget(
        MaterialApp(
          home: SessionTimerScreen(
            groupedResult: buildGroupedResult([books, mug]),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap the first Keep button (belongs to the first DecisionCard).
      final keepButtons = find.widgetWithText(FilledButton, 'Keep');
      expect(keepButtons, findsWidgets);
      await tester.tap(keepButtons.first);
      await tester.pumpAndSettle();

      // After one decision, progress should show 1/2.
      expect(find.text('1/2 groups decided'), findsOneWidget);
    });
  });

  group('CashToClearStatusCard', () {
    testWidgets('shows synced money on the table and group value chips',
        (tester) async {
      final groups = [
        buildGroup(id: 'group_1', label: 'books', count: 2),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: CashToClearStatusCard(
              isSyncing: false,
              message: 'Cash-to-Clear values synced.',
              moneyOnTableLowUsd: 12,
              moneyOnTableHighUsd: 30,
              groupedResult: buildGroupedResult(groups),
              publicListingUrlsByGroupId: const {
                'group_1': 'https://api.example.com/public/listings/pub_1',
              },
              creatingListingPageGroupIds: const {},
              onCreateListingPage: _noop,
              remoteItemsByGroupId: const {
                'group_1': CashToClearItemDto(
                  itemId: 'item_1',
                  label: 'books',
                  valuation: CashToClearValuationDto(
                    lowUsd: 12,
                    highUsd: 30,
                    confidence: 'medium',
                    source: 'mock-ebay-comps',
                  ),
                  listingDraft: CashToClearListingDraftDto(
                    title: 'Books - Unknown',
                    priceUsd: 21,
                    categoryHint: 'Books & Magazines',
                  ),
                ),
              },
            ),
          ),
        ),
      );

      expect(find.text('Money on the table'), findsOneWidget);
      expect(find.text(r'$12–30'), findsOneWidget);
      expect(find.textContaining('Books: \$12–30'), findsOneWidget);
      expect(find.text('Page created for Books'), findsOneWidget);
      expect(find.text('https://api.example.com/public/listings/pub_1'),
          findsOneWidget);
    });

    testWidgets('disables create page action while a group is already creating',
        (tester) async {
      final groups = [
        buildGroup(id: 'group_1', label: 'books', count: 2),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: CashToClearStatusCard(
              isSyncing: true,
              message: 'Creating standalone listing page...',
              moneyOnTableLowUsd: 12,
              moneyOnTableHighUsd: 30,
              groupedResult: buildGroupedResult(groups),
              publicListingUrlsByGroupId: const {},
              creatingListingPageGroupIds: const {'group_1'},
              onCreateListingPage: _noop,
              remoteItemsByGroupId: const {
                'group_1': CashToClearItemDto(
                  itemId: 'item_1',
                  label: 'books',
                  valuation: CashToClearValuationDto(
                    lowUsd: 12,
                    highUsd: 30,
                    confidence: 'medium',
                    source: 'mock-ebay-comps',
                  ),
                  listingDraft: CashToClearListingDraftDto(
                    title: 'Books - Unknown',
                    priceUsd: 21,
                    categoryHint: 'Books & Magazines',
                  ),
                ),
              },
            ),
          ),
        ),
      );

      final button = tester.widget<OutlinedButton>(
        find.widgetWithText(OutlinedButton, 'Creating page...'),
      );
      expect(button.onPressed, isNull);
    });
  });

  group('SessionSummaryCard', () {
    testWidgets('summarizes decisions and listing links', (tester) async {
      final groups = [
        buildGroup(id: 'group_1', label: 'books', count: 2),
      ];
      final decisions = [
        SessionDecision(
          groupId: 'group_1',
          groupLabel: 'Books (2 items)',
          groupTotal: 2,
          category: DecisionCategory.sell,
          createdAt: DateTime(2026),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: SessionSummaryCard(
              decisions: decisions,
              groupedResult: buildGroupedResult(groups),
              moneyOnTableLowUsd: 12,
              moneyOnTableHighUsd: 30,
              publicListingUrlsByGroupId: const {
                'group_1': 'https://api.example.com/public/listings/pub_1',
              },
            ),
          ),
        ),
      );

      expect(find.text('Sprint summary'), findsOneWidget);
      expect(find.text('1/2 items decided'), findsOneWidget);
      expect(find.text(r'Money still on the table: $12–30'), findsOneWidget);
      expect(find.text('Sell: 1'), findsOneWidget);
      expect(find.text('Listing pages'), findsOneWidget);
      expect(find.text('https://api.example.com/public/listings/pub_1'),
          findsOneWidget);
    });
  });
}

void _noop(String _) {}
