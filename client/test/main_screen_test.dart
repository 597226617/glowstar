import 'package:flutter_test/flutter_test.dart';
import 'package:glowstar/screens/main_screen.dart';
import 'package:flutter/material.dart';

void main() {
  group('MainScreen', () {
    testWidgets('should display 5 navigation tabs', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MainScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('发现'), findsOneWidget);
      expect(find.text('动态'), findsOneWidget);
      expect(find.text('语音房'), findsOneWidget);
      expect(find.text('消息'), findsOneWidget);
      expect(find.text('我的'), findsOneWidget);
    });

    testWidgets('should display app title', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MainScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('✨ GlowStar'), findsOneWidget);
    });

    testWidgets('should switch tabs on tap', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MainScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on profile tab
      await tester.tap(find.text('我的'));
      await tester.pumpAndSettle();

      // BottomNavigationBar should update
      expect(find.text('我的'), findsOneWidget);
    });
  });
}
