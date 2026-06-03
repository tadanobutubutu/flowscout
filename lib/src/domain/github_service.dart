import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';

class GitHubService {
  static const String clientId = 'Iv23limzxSsYeKcuUopY';
  static const _secureStorage = FlutterSecureStorage();
  static const _activeUserKey = 'active_github_username';
  static const _registeredUsersKey = 'github_registered_users';
  static const _tokenPrefix = 'github_oauth_token_';

  // 1. セキュアトークンの保存と取得 (アクティブなアカウント用)
  Future<String?> getToken() async {
    final activeUser = await _secureStorage.read(key: _activeUserKey);
    if (activeUser == null) {
      // 互換性維持：もし古いシングルアカウントのトークンがあればそれを返す
      final legacyToken = await _secureStorage.read(key: 'github_oauth_token');
      if (legacyToken != null) {
        return legacyToken;
      }
      return null;
    }
    return await _secureStorage.read(key: '$_tokenPrefix$activeUser');
  }

  // 互換性のための既存のsaveToken (基本使用せず、saveTokenForUserを推奨)
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: 'github_oauth_token', value: token);
  }

  // 指定ユーザー名でトークンを保存し、アクティブ化
  Future<void> saveTokenForUser(String token, String username) async {
    // トークンを保存
    await _secureStorage.write(key: '$_tokenPrefix$username', value: token);
    
    // 互換性維持：単一アカウント用キーにも書き込んでおく（他の単純参照箇所のフォールバック用）
    await _secureStorage.write(key: 'github_oauth_token', value: token);

    // 登録ユーザーリストの更新
    final usersStr = await _secureStorage.read(key: _registeredUsersKey) ?? '';
    final users = usersStr.isEmpty ? <String>[] : usersStr.split(',');
    if (!users.contains(username)) {
      users.add(username);
      await _secureStorage.write(key: _registeredUsersKey, value: users.join(','));
    }

    // アクティブユーザーに設定
    await _secureStorage.write(key: _activeUserKey, value: username);
  }

  // 登録されているユーザー名のリストを取得
  Future<List<String>> getRegisteredUsers() async {
    final usersStr = await _secureStorage.read(key: _registeredUsersKey) ?? '';
    if (usersStr.isEmpty) {
      // 互換性維持：もし古いシングルアカウントでログイン中なら、そのアカウント情報を取得して追加する
      final legacyToken = await _secureStorage.read(key: 'github_oauth_token');
      if (legacyToken != null) {
        // トークンが有効か検証を兼ねてユーザー名を取得
        final userMap = await getCurrentUser();
        if (userMap != null) {
          final login = userMap['login'] as String;
          await saveTokenForUser(legacyToken, login);
          return [login];
        }
      }
      return [];
    }
    return usersStr.split(',');
  }

  // 現在アクティブなユーザー名を取得
  Future<String?> getActiveUser() async {
    return await _secureStorage.read(key: _activeUserKey);
  }

  // アクティブなユーザーを切り替える
  Future<void> setActiveUser(String username) async {
    await _secureStorage.write(key: _activeUserKey, value: username);
    
    // 互換性維持：単一アカウント用キーにも同期
    final token = await _secureStorage.read(key: '$_tokenPrefix$username');
    if (token != null) {
      await _secureStorage.write(key: 'github_oauth_token', value: token);
    }
  }

  // 特定ユーザーのトークンを削除
  Future<void> deleteUserToken(String username) async {
    await _secureStorage.delete(key: '$_tokenPrefix$username');

    final usersStr = await _secureStorage.read(key: _registeredUsersKey) ?? '';
    final users = usersStr.isEmpty ? <String>[] : usersStr.split(',');
    if (users.contains(username)) {
      users.remove(username);
      await _secureStorage.write(key: _registeredUsersKey, value: users.join(','));
    }

    // アクティブユーザーが削除された場合、他のユーザーがいればそちらをアクティブにし、いなければクリアする
    final activeUser = await getActiveUser();
    if (activeUser == username) {
      if (users.isNotEmpty) {
        await setActiveUser(users.first);
      } else {
        await _secureStorage.delete(key: _activeUserKey);
        await _secureStorage.delete(key: 'github_oauth_token');
      }
    }
  }

  // 全てのアカウントをログアウト
  Future<void> deleteAllTokens() async {
    final users = await getRegisteredUsers();
    for (final user in users) {
      await _secureStorage.delete(key: '$_tokenPrefix$user');
    }
    await _secureStorage.delete(key: _activeUserKey);
    await _secureStorage.delete(key: _registeredUsersKey);
    await _secureStorage.delete(key: 'github_oauth_token');
  }

  // 互換性のための既存メソッド（単一削除）
  Future<void> deleteToken() async {
    final activeUser = await getActiveUser();
    if (activeUser != null) {
      await deleteUserToken(activeUser);
    } else {
      await _secureStorage.delete(key: 'github_oauth_token');
    }
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
    final List<Map<String, dynamic>> allRepos = [];
    final Set<int> seenRepoIds = {};

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
          for (final inst in installations) {
            final instMap = inst as Map<String, dynamic>;
            final int instId = instMap['id'] as int;

            int page = 1;
            while (true) {
              final rUrl = Uri.parse('https://api.github.com/user/installations/$instId/repositories?per_page=100&page=$page');
              final repoResponse = await http.get(rUrl, headers: headers);
              if (repoResponse.statusCode == 200) {
                final Map<String, dynamic> repoData = json.decode(repoResponse.body) as Map<String, dynamic>;
                final List<dynamic> repos = repoData['repositories'] as List<dynamic>? ?? [];
                if (repos.isEmpty) break;

                for (final repo in repos) {
                  final repoMap = repo as Map<String, dynamic>;
                  final int repoId = repoMap['id'] as int;
                  if (seenRepoIds.contains(repoId)) continue;
                  seenRepoIds.add(repoId);

                  final ownerMap = repoMap['owner'] as Map<String, dynamic>;

                  // クエリが指定されている場合、フィルタリング
                  if (query.isNotEmpty &&
                      !(repoMap['name'] as String).toLowerCase().contains(query.toLowerCase()) &&
                      !(repoMap['full_name'] as String).toLowerCase().contains(query.toLowerCase())) {
                    continue;
                  }

                  allRepos.add({
                    'id': repoId,
                    'name': repoMap['name'],
                    'full_name': repoMap['full_name'],
                    'private': repoMap['private'],
                    'description': repoMap['description'] ?? 'No description',
                    'stargazers_count': repoMap['stargazers_count'],
                    'updated_at': repoMap['updated_at'],
                    'pushed_at': repoMap['pushed_at'],
                    'owner': ownerMap['login'],
                    'avatar_url': ownerMap['avatar_url'],
                    'owner_type': ownerMap['type'] ?? 'User',
                  });
                }

                if (repos.length < 100) break;
                page++;
              } else {
                break;
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
        final int repoId = itemMap['id'] as int;
        if (seenRepoIds.contains(repoId)) continue;
        seenRepoIds.add(repoId);

        final Map<String, dynamic> ownerMap = itemMap['owner'] as Map<String, dynamic>;
        allRepos.add({
          'id': repoId,
          'name': itemMap['name'],
          'full_name': itemMap['full_name'],
          'private': itemMap['private'],
          'description': itemMap['description'] ?? 'No description',
          'stargazers_count': itemMap['stargazers_count'],
          'updated_at': itemMap['updated_at'],
          'pushed_at': itemMap['pushed_at'],
          'owner': ownerMap['login'],
          'avatar_url': ownerMap['avatar_url'],
          'owner_type': ownerMap['type'] ?? 'User',
        });
      }
      page++;
    }
    // ソートして返す
    allRepos.sort((a, b) => (b['updated_at'] as String).compareTo(a['updated_at'] as String));
    return allRepos;
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
              final Map<String, dynamic>? headCommit = runMap['head_commit'] as Map<String, dynamic>?;
              final Map<String, dynamic> author = headCommit != null 
                  ? (headCommit['author'] as Map<String, dynamic>? ?? {}) 
                  : {};
              final Map<String, dynamic>? actor = runMap['actor'] as Map<String, dynamic>?;
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
                    headCommit?['message'] ?? 'No commit message',
                'head_commit_author':
                    author['name'] ?? 'Unknown',
                'actor_login': actor?['login'] ?? 'Unknown',
                'actor_avatar_url': actor?['avatar_url'] ?? '',
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
    final url = Uri.parse(
        'https://api.github.com/repos/$repoFullName/actions/jobs/$jobId/logs');

    try {
      // GitHub API は /logs に対して 302 リダイレクトを返す（S3 署名付きURL）
      // http.Client を使って手動でリダイレクトを追跡する
      final client = http.Client();
      try {
        final request = http.Request('GET', url)
          ..followRedirects = false
          ..headers.addAll(headers);

        final streamedResponse = await client.send(request);

        if (streamedResponse.statusCode == 302 ||
            streamedResponse.statusCode == 301) {
          final redirectUrl = streamedResponse.headers['location'];
          if (redirectUrl != null) {
            // リダイレクト先（S3）へ追加認証なしでリクエスト
            final redirectResponse =
                await http.get(Uri.parse(redirectUrl));
            if (redirectResponse.statusCode == 200) {
              return redirectResponse.body;
            }
            debugPrint(
                'Error fetching log from redirect: ${redirectResponse.statusCode}');
          }
        } else if (streamedResponse.statusCode == 200) {
          return await streamedResponse.stream.bytesToString();
        } else {
          debugPrint(
              'Unexpected status fetching job log: ${streamedResponse.statusCode}');
        }
      } finally {
        client.close();
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
