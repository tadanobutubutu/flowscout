import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';

class GitHubService {
  static const _secureStorage = FlutterSecureStorage();
  static const _tokenKey = 'github_oauth_token';

  // 1. セキュアトークンの保存と取得
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  Future<void> deleteToken() async {
    await _secureStorage.delete(key: _tokenKey);
  }

  // ヘッダー生成
  Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    return {
      'Accept': 'application/vnd.github.v3+json',
      if (token != null) 'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  // 2. リポジトリ検索機能 (プライベート/パブリック両対応、ページネーション/検索クエリ対応)
  Future<List<Map<String, dynamic>>> searchRepositories(
      {String query = ''}) async {
    final headers = await _getHeaders();

    // クエリが空の場合は、ユーザーがアクセス可能なリポジトリ一覧を取得
    final url = query.isEmpty
        ? Uri.parse(
            'https://api.github.com/user/repos?sort=updated&per_page=50')
        : Uri.parse(
            'https://api.github.com/search/repositories?q=$query+in:name&sort=updated&order=desc');

    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body) as Map<String, dynamic>;
        final List<dynamic> items = query.isEmpty
            ? json.decode(response.body) as List<dynamic>
            : data['items'] as List<dynamic>;

        return items
            .map((item) {
              final Map<String, dynamic> itemMap = item as Map<String, dynamic>;
              final Map<String, dynamic> ownerMap = itemMap['owner'] as Map<String, dynamic>;
              return {
                'id': itemMap['id'],
                'name': itemMap['name'],
                'full_name': itemMap['full_name'],
                'private': itemMap['private'],
                'description': itemMap['description'] ?? 'No description',
                'stargazers_count': itemMap['stargazers_count'],
                'updated_at': itemMap['updated_at'],
                'owner': ownerMap['login'],
                'avatar_url': ownerMap['avatar_url'],
              };
            })
            .toList();
      } else {
        throw Exception('Failed to load repositories: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error searching repos: $e');
      return [];
    }
  }

  // 3. 直コミットやPRで走ったワークフローラン (Workflow Runs) の一覧取得
  Future<List<Map<String, dynamic>>> getWorkflowRuns(
      String repoFullName) async {
    final headers = await _getHeaders();
    final url = Uri.parse(
        'https://api.github.com/repos/$repoFullName/actions/runs?per_page=30');

    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body) as Map<String, dynamic>;
        final List<dynamic> runs = data['workflow_runs'] as List<dynamic>? ?? [];

        return runs
            .map((run) {
              final Map<String, dynamic> runMap = run as Map<String, dynamic>;
              final Map<String, dynamic> headCommit = runMap['head_commit'] as Map<String, dynamic>;
              final Map<String, dynamic> author = headCommit['author'] as Map<String, dynamic>;
              return {
                'id': runMap['id'],
                'name': runMap['name'],
                'event': runMap['event'], // push, pull_request, etc.
                'status': runMap['status'], // completed, in_progress, queued
                'conclusion': runMap['conclusion'] ??
                    'pending', // success, failure, cancelled
                'html_url': runMap['html_url'],
                'run_number': runMap['run_number'],
                'head_branch': runMap['head_branch'],
                'head_commit_message':
                    headCommit['message'] ?? 'No commit message',
                'head_commit_author':
                    author['name'] ?? 'Unknown',
                'created_at': runMap['created_at'],
                'updated_at': runMap['updated_at'],
              };
            })
            .toList();
      } else {
        throw Exception('Failed to load workflow runs: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching workflow runs: $e');
      return [];
    }
  }

  // 4. ジョブおよび詳細なステップの取得 (エラーログ詳細の特定用)
  Future<List<Map<String, dynamic>>> getRunJobs(
      String repoFullName, int runId) async {
    final headers = await _getHeaders();
    final url = Uri.parse(
        'https://api.github.com/repos/$repoFullName/actions/runs/$runId/jobs');

    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body) as Map<String, dynamic>;
        final List<dynamic> jobs = data['jobs'] as List<dynamic>? ?? [];

        return jobs.map((job) {
          final Map<String, dynamic> jobMap = job as Map<String, dynamic>;
          final List<dynamic> steps = jobMap['steps'] as List<dynamic>? ?? [];
          return {
            'id': jobMap['id'],
            'name': jobMap['name'],
            'status': jobMap['status'],
            'conclusion': jobMap['conclusion'] ?? 'pending',
            'started_at': jobMap['started_at'],
            'completed_at': jobMap['completed_at'],
            'steps': steps
                .map((step) {
                  final Map<String, dynamic> stepMap = step as Map<String, dynamic>;
                  return {
                    'name': stepMap['name'],
                    'status': stepMap['status'],
                    'conclusion': stepMap['conclusion'] ?? 'pending',
                    'number': stepMap['number'],
                  };
                })
                .toList(),
          };
        }).toList();
      } else {
        throw Exception('Failed to load jobs: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching run jobs: $e');
      return [];
    }
  }

  // 5. アプデチェック機能 (GitHub Releases から最新バージョンを取得)
  Future<Map<String, dynamic>> checkUpdate() async {
    final headers = await _getHeaders();
    // Flowscout 本体のパブリックリポジトリから最新のリリースを取得する想定
    final url = Uri.parse(
        'https://api.github.com/repos/tadanobutubutu/flowscout/releases/latest');

    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body) as Map<String, dynamic>;
        final String latestTagName = data['tag_name'] as String? ?? 'v1.0.0'; // 例: v1.0.1
        final String body = data['body'] as String? ?? '';
        final String downloadUrl = data['html_url'] as String? ?? '';

        final packageInfo = await PackageInfo.fromPlatform();
        final String currentVersion = 'v${packageInfo.version}';

        // バージョン比較 (単純な文字列比較ではなくセマンティックバージョン比較を行うのが好ましい)
        final hasUpdate = _isNewerVersion(latestTagName, currentVersion);

        return {
          'hasUpdate': hasUpdate,
          'latestVersion': latestTagName,
          'currentVersion': currentVersion,
          'releaseNotes': body,
          'downloadUrl': downloadUrl,
        };
      }
    } catch (e) {
      debugPrint('Error checking update: $e');
    }
    return {'hasUpdate': false};
  }

  bool _isNewerVersion(String latest, String current) {
    try {
      final latestClean = latest.replaceAll('v', '').split('+')[0];
      final currentClean = current.replaceAll('v', '').split('+')[0];

      final List<int> latestParts = latestClean.split('.').map(int.parse).toList();
      final List<int> currentParts = currentClean.split('.').map(int.parse).toList();

      for (int i = 0; i < latestParts.length; i++) {
        if (i >= currentParts.length) return true;
        if (latestParts[i] > currentParts[i]) return true;
        if (latestParts[i] < currentParts[i]) return false;
      }
    } catch (_) {}
    return false;
  }
}
