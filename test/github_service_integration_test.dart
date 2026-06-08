import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flowscout/src/domain/github_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MyHttpOverrides extends HttpOverrides {}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    // 実ネットワーク通信を許可する
    HttpOverrides.global = MyHttpOverrides();
    // FlutterSecureStorageのモック初期化
    FlutterSecureStorage.setMockInitialValues({});
  });

  group('GitHubService Integration Test (Guest Mode)', () {
    final service = GitHubService();

    final testRepos = [
      'facebook/react',
      'microsoft/vscode',
      'apple/swift',
      'tensorflow/tensorflow',
      'kubernetes/kubernetes',
      'django/django',
      'rails/rails',
      'rust-lang/rust',
      'golang/go',
      'google/googletest',
    ];

    for (final repo in testRepos) {
      test('Fetch details and logs for $repo', () async {
        print('----------------------------------------');
        print('Testing repository: $repo');

        // 1. リポジトリ検索
        final parts = repo.split('/');
        final query = parts[1]; // リポジトリ名で検索
        final searchResults = await service.searchRepositories(query: query);
        expect(searchResults, isNotEmpty);
        
        final matched = searchResults.firstWhere(
          (r) => r['full_name'] == repo,
          orElse: () => searchResults.first,
        );
        print('Found: ${matched['full_name']} (Stars: ${matched['stargazers_count']})');

        // 2. ワークフロー実行一覧の取得
        final runs = await service.getWorkflowRuns(repo);
        print('Workflow runs fetched: ${runs.length}');
        
        if (runs.isNotEmpty) {
          final firstRun = runs.first;
          final runId = firstRun['id'] as int;
          print('First workflow run: ID=$runId, Status=${firstRun['status']}, Conclusion=${firstRun['conclusion']}');

          // 3. ジョブ一覧の取得
          final jobs = await service.getRunJobs(repo, runId);
          print('Jobs fetched: ${jobs.length}');

          if (jobs.isNotEmpty) {
            final firstJob = jobs.first;
            final jobId = firstJob['id'] as int;
            print('First job: ID=$jobId, Name=${firstJob['name']}, Status=${firstJob['status']}');

            // 4. ジョブログの取得試行
            final log = await service.getJobLog(repo, jobId);
            if (log != null) {
              print('Log fetched successfully! Length: ${log.length} characters');
              expect(log, isNotEmpty);
            } else {
              print('Log not available (could be expired or queued)');
            }
          }
        } else {
          print('No workflow runs found for $repo.');
        }
      });
    }
  });
}
