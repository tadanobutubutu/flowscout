import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';

class GitHubService {
  static const String clientId = 'Iv23limzxSsYeKcuUopY';
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

  // デバイスコードのリクエスト
  Future<Map<String, dynamic>?> requestDeviceCode() async {
    try {
      final response = await http.post(
        Uri.parse('https://github.com/login/device/code'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'client_id': clientId,
          'scope': 'repo read:user workflow',
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('Error requesting device code: $e');
    }
    return null;
  }

  // アクセストークン取得のためのポーリング
  Future<String?> pollForToken(String deviceCode, int interval) async {
    final url = Uri.parse('https://github.com/login/oauth/access_token');
    
    try {
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'client_id': clientId,
          'device_code': deviceCode,
          'grant_type': 'urn:ietf:params:oauth:grant-type:device_code',
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        if (data.containsKey('access_token')) {
          return data['access_token'] as String;
        } else if (data['error'] == 'authorization_pending') {
          // まだユーザーがコードを入力していない状態
          return 'authorization_pending';
        } else if (data['error'] == 'slow_down') {
          return 'slow_down';
        } else if (data['error'] == 'expired_token') {
          return 'expired_token';
        }
      }
    } catch (e) {
      debugPrint('Error polling for token: $e');
    }
    return null;
  }

  // 現在のログインユーザー情報の取得
  Future<Map<String, dynamic>?> getCurrentUser() async {
    final token = await getToken();
    if (token == null) return null;
    final headers = await _getHeaders();
    try {
      final response = await http.get(
        Uri.parse('https://api.github.com/user'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return {
          'login': data['login'] as String? ?? '',
          'name': data['name'] as String? ?? '',
          'avatar_url': data['avatar_url'] as String? ?? '',
          'public_repos': data['public_repos'] as int? ?? 0,
          'total_private_repos': data['total_private_repos'] as int? ?? 0,
        };
      }
    } catch (e) {
      debugPrint('Error getting current user: $e');
    }
    return null;
  }

  // トークンの検証（ログイン時に使用）
  Future<Map<String, dynamic>?> validateToken(String token) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.github.com/user'),
        headers: {
          'Accept': 'application/vnd.github.v3+json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return {
          'login': data['login'] as String? ?? '',
          'name': data['name'] as String? ?? '',
          'avatar_url': data['avatar_url'] as String? ?? '',
        };
      }
    } catch (e) {
      debugPrint('Error validating token: $e');
    }
    return null;
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

    try {
      // 1. まずはGitHub Appとしてのインストール一覧を取得してみる
      final installationsResponse = await http.get(
        Uri.parse('https://api.github.com/user/installations'),
        headers: headers,
      );

      if (installationsResponse.statusCode == 200) {
        final Map<String, dynamic> instData = json.decode(installationsResponse.body) as Map<String, dynamic>;
        final List<dynamic> installations = instData['installations'] as List<dynamic>? ?? [];

        if (installations.isNotEmpty) {
          final List<Map<String, dynamic>> allRepos = [];
          for (final inst in installations) {
            final instMap = inst as Map<String, dynamic>;
            final int instId = instMap['id'] as int;

            final rUrl = Uri.parse('https://api.github.com/user/installations/$instId/repositories?per_page=100');
            final repoResponse = await http.get(rUrl, headers: headers);
            if (repoResponse.statusCode == 200) {
              final Map<String, dynamic> repoData = json.decode(repoResponse.body) as Map<String, dynamic>;
              final List<dynamic> repos = repoData['repositories'] as List<dynamic>? ?? [];
              for (final repo in repos) {
                final repoMap = repo as Map<String, dynamic>;
                final ownerMap = repoMap['owner'] as Map<String, dynamic>;
                
                // クエリが指定されている場合、リポジトリ名に含まれているかフィルタ
                if (query.isNotEmpty &&
                    !(repoMap['name'] as String).toLowerCase().contains(query.toLowerCase()) &&
                    !(repoMap['full_name'] as String).toLowerCase().contains(query.toLowerCase())) {
                  continue;
                }

                allRepos.add({
                  'id': repoMap['id'],
                  'name': repoMap['name'],
                  'full_name': repoMap['full_name'],
                  'private': repoMap['private'],
                  'description': repoMap['description'] ?? 'No description',
                  'stargazers_count': repoMap['stargazers_count'],
                  'updated_at': repoMap['updated_at'],
                  'owner': ownerMap['login'],
                  'avatar_url': ownerMap['avatar_url'],
                });
              }
            }
          }
          
          // 更新順にソートして返す
          allRepos.sort((a, b) => (b['updated_at'] as String).compareTo(a['updated_at'] as String));
          return allRepos;
        }
      }
    } catch (e) {
      debugPrint('Error fetching repos via installations: $e');
    }

    // ── 2. フォールバック (PATログイン、またはApp経由での取得に失敗した場合) ──
    int page = 1;
    List<Map<String, dynamic>> allRepos = [];
    while (true) {
      final fallbackUrl = Uri.parse(
        query.isEmpty
            ? 'https://api.github.com/user/repos?sort=updated&per_page=100&page=$page'
            : 'https://api.github.com/search/repositories?q=$query+in:name&sort=updated&order=desc&per_page=100&page=$page',
      );
      final resp = await http.get(fallbackUrl, headers: headers);
      if (resp.statusCode != 200) {
        debugPrint('Error fetching repos (fallback) page $page: ${resp.statusCode}');
        break;
      }
      final List<dynamic> items = query.isEmpty
          ? json.decode(resp.body) as List<dynamic>
          : (json.decode(resp.body) as Map<String, dynamic>)['items'] as List<dynamic>;
      if (items.isEmpty) {
        break;
      }
      for (final item in items) {
        final Map<String, dynamic> itemMap = item as Map<String, dynamic>;
        final Map<String, dynamic> ownerMap = itemMap['owner'] as Map<String, dynamic>;
        allRepos.add({
          'id': itemMap['id'],
          'name': itemMap['name'],
          'full_name': itemMap['full_name'],
          'private': itemMap['private'],
          'description': itemMap['description'] ?? 'No description',
          'stargazers_count': itemMap['stargazers_count'],
          'updated_at': itemMap['updated_at'],
          'owner': ownerMap['login'],
          'avatar_url': ownerMap['avatar_url'],
        });
      }
      page++;
    }
    // ソートして返す
    allRepos.sort((a, b) => (b['updated_at'] as String).compareTo(a['updated_at'] as String));
    return allRepos;



    } catch (e) {
      debugPrint('Error searching repos (fallback): $e');
    }
    return [];
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

  // 5. ジョブのログを取得する (エラーログ詳細の特定用)
  Future<String?> getJobLog(String repoFullName, int jobId) async {
    final headers = await _getHeaders();
    final url = Uri.parse('https://api.github.com/repos/$repoFullName/actions/jobs/$jobId/logs');

    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        return response.body;
      }
    } catch (e) {
      debugPrint('Error fetching job log: $e');
    }
    return null;
  }

  // 6. アプデチェック機能 (GitHub Releases から最新バージョンを取得)
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
