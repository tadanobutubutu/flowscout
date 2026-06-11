// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowscout/main.dart';
import 'package:flowscout/src/presentation/home_screen.dart';
import 'package:flowscout/src/domain/github_service.dart';

// テスト用のモックGitHubService
class MockGitHubService extends GitHubService {
  @override
  Future<String?> getToken() async => null;
}

void main() {
  testWidgets('Flowscout app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame inside ProviderScope.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          gitHubServiceProvider.overrideWithValue(MockGitHubService()),
        ],
        child: const FlowscoutApp(),
      ),
    );

    // 起動時の非同期トークン確認の処理完了を十分なステップで待つ
    for (int i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    
    // 認証連携ボタンが存在することを確認 (英語デフォルト)
    expect(find.text('Connect with GitHub App'), findsOneWidget);
  });
}
