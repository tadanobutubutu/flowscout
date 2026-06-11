import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flowscout/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Check 10 different users repos jobs in guest mode', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Skip to guest mode
    final skipButton = find.textContaining('ゲストモード');
    expect(skipButton, findsOneWidget);
    await tester.tap(skipButton);
    await tester.pumpAndSettle();

    final users = [
      'flutter',
      'dart-lang',
      'google',
      'facebook',
      'microsoft',
      'apple',
      'aws',
      'stripe',
      'vercel',
      'netlify'
    ];

    for (final user in users) {
      // ignore: avoid_print
      print('Testing user: $user');
      
      // Tap search bar
      final searchBar = find.byType(TextField);
      await tester.enterText(searchBar, user);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      
      // We should see some repos. Tap the first one.
      final listTiles = find.byType(ListTile);
      if (tester.any(listTiles)) {
        await tester.tap(listTiles.first);
        await tester.pumpAndSettle(const Duration(seconds: 3));
        
        // Wait for runs to load, then tap the first run
        final runTiles = find.byType(ListTile);
        if (tester.any(runTiles)) {
          await tester.tap(runTiles.first);
          await tester.pumpAndSettle(const Duration(seconds: 3));
          
          // Wait for jobs to load
          
          // Go back to runs
          final backButton = find.byTooltip('Back');
          if (tester.any(backButton)) {
            await tester.tap(backButton.first);
            await tester.pumpAndSettle();
          }
        }
        
        // Go back to home
        final backButtonHome = find.byTooltip('Back');
        if (tester.any(backButtonHome)) {
          await tester.tap(backButtonHome.first);
          await tester.pumpAndSettle();
        }
      }
    }
  });
}
