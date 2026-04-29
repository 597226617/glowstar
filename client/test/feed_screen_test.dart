import 'package:flutter_test/flutter_test.dart';
import 'package:glowstar/screens/feed_screen.dart';
import 'package:flutter/material.dart';

void main() {
  group('FeedScreen', () {
    testWidgets('should display tabs', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: FeedScreen()),
        ),
      );
      await tester.pump();

      expect(find.text('推荐'), findsOneWidget);
      expect(find.text('关注'), findsOneWidget);
      expect(find.text('附近'), findsOneWidget);
      expect(find.text('学习'), findsOneWidget);
    });

    testWidgets('should display loading indicator initially', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: FeedScreen()),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
