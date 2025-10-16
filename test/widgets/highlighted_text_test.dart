import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/widgets/highlighted_text.dart';

void main() {
  group('HighlightedText Widget Tests', () {
    testWidgets('should display text without highlighting when search term is empty', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HighlightedText(
              text: 'Hello World',
              searchTerm: '',
            ),
          ),
        ),
      );

      expect(find.text('Hello World'), findsOneWidget);
    });

    testWidgets('should highlight matching text case-insensitive by default', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HighlightedText(
              text: 'Hello World',
              searchTerm: 'world',
            ),
          ),
        ),
      );

      // Should find the RichText widget with highlighted content
      expect(find.byType(RichText), findsOneWidget);
    });

    testWidgets('should display text without highlighting when no match found', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HighlightedText(
              text: 'Hello World',
              searchTerm: 'xyz',
            ),
          ),
        ),
      );

      expect(find.text('Hello World'), findsOneWidget);
    });

    testWidgets('should respect case sensitivity when enabled', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HighlightedText(
              text: 'Hello World',
              searchTerm: 'world',
              caseSensitive: true,
            ),
          ),
        ),
      );

      // Should not highlight because 'world' != 'World'
      expect(find.text('Hello World'), findsOneWidget);
    });

    testWidgets('should highlight multiple occurrences', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HighlightedText(
              text: 'Hello Hello World',
              searchTerm: 'hello',
            ),
          ),
        ),
      );

      // Should find the RichText widget with highlighted content
      expect(find.byType(RichText), findsOneWidget);
    });
  });
}
