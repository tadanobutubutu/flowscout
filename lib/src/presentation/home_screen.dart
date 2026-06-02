import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../domain/github_service.dart';
import '../../main.dart';
import 'workflow_detail_screen.dart';
import 'settings_screen.dart';
import 'premium_widgets.dart';

final gitHubServiceProvider = Provider((ref) => GitHubService());

// リポジトリ検索のクエリを管理するStateProvider
final searchQueryProvider = StateProvider<String>((ref) => '');

// リポジトリ一覧を取得するFutureProvider
final repositoriesProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final service = ref.watch(gitHubServiceProvider);
  final query = ref.watch(searchQueryProvider);
  return service.searchRepositories(query: query);
});

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForUpdates();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // アプデチェック処理 (設定でオフにする機能も内包)
  Future<void> _checkForUpdates() async {
    final service = ref.read(gitHubServiceProvider);
    final updateInfo = await service.checkUpdate();

    final prefs = ref.read(updateNotifyEnabledProvider);
    if (updateInfo['hasUpdate'] == true && prefs) {
      if (!mounted) return;

      // プレミアムで美しいアプデ通知ダイアログ
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: Theme.of(context).cardTheme.color,
          title: Row(
            children: [
              const Icon(Icons.system_update_alt_rounded,
                  color: Color(0xFF6366F1), size: 30),
              const SizedBox(width: 12),
              Text(
                'アップデートのご案内',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontSize: 20),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                label: '新しいバージョン ${updateInfo['latestVersion'] as String? ?? ''} が利用可能です！',
                child: Text(
                  '新しいバージョン (${updateInfo['latestVersion'] as String? ?? ''}) が利用可能です！',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              Semantics(
                label: '現在のバージョン: ${updateInfo['currentVersion'] as String? ?? ''}',
                child: Text('現在のバージョン: ${updateInfo['currentVersion'] as String? ?? ''}'),
              ),
              const SizedBox(height: 12),
              const Text('リリースノート:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Container(
                constraints: const BoxConstraints(maxHeight: 100),
                width: double.maxFinite,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text((updateInfo['releaseNotes'] as String?) ?? 'バグ修正とパフォーマンスの向上。'),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('後で'),
            ),
            ElevatedButton(
              onPressed: () async {
                final url = Uri.parse((updateInfo['downloadUrl'] as String?) ?? '');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('アップデート'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final reposAsync = ref.watch(repositoriesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Flowscout',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: 28,
                fontFamily: 'Outfit',
                foreground: Paint()
                  ..shader = const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF0EA5E9)],
                  ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
              ),
        ),
        actions: [
          IconButton(
            icon: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
            tooltip: 'テーマ切り替え',
            onPressed: () {
              ref.read(themeModeProvider.notifier).state =
                  isDark ? ThemeMode.light : ThemeMode.dark;
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: '設定',
            onPressed: () {
              Navigator.push<void>(
                context,
                MaterialPageRoute<void>(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            // プレミアムデザイン検索バー
            Semantics(
              label: 'リポジトリ検索バー',
              hint: '検索したいリポジトリ名を入力してください',
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  ref.read(searchQueryProvider.notifier).state = value;
                },
                decoration: InputDecoration(
                  hintText: 'リポジトリを検索...',
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: Color(0xFF6366F1)),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _searchController.clear();
                            ref.read(searchQueryProvider.notifier).state = '';
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: isDark
                      ? const Color(0xFF131B2E)
                      : const Color(0xFFF1F5F9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide:
                        const BorderSide(color: Color(0xFF6366F1), width: 1.5),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'マイリポジトリ',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: reposAsync.when(
                data: (repos) {
                  if (repos.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.folder_open_rounded,
                              size: 64, color: Theme.of(context).hintColor),
                          const SizedBox(height: 16),
                          const Text('リポジトリが見つかりません',
                              style: TextStyle(fontSize: 16)),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: repos.length,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      final repo = repos[index];
                      final isPrivate = repo['private'] as bool? ?? false;
                      final repoName = repo['name'] as String? ?? '';
                      final repoFullName = repo['full_name'] as String? ?? '';
                      final avatarUrl = repo['avatar_url'] as String? ?? '';
                      final description = repo['description'] as String? ?? 'No description';

                      return Semantics(
                        button: true,
                        label: '$repoName リポジトリ',
                        hint: 'ダブルタップしてワークフロー実行状況を表示します',
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Consumer(
                            builder: (context, ref, child) {
                              final isLowSpec = ref.watch(lowSpecModeProvider);
                              final animationEnabled = ref.watch(listEntranceAnimationEnabledProvider);
                              
                              final innerCard = PremiumSpringButton(
                                onTap: () {
                                  Navigator.push<void>(
                                    context,
                                    MaterialPageRoute<void>(
                                      builder: (context) => WorkflowDetailScreen(
                                        repoFullName: repoFullName,
                                        repoName: repoName,
                                      ),
                                    ),
                                  );
                                },
                                child: Card(
                                  margin: EdgeInsets.zero,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundImage:
                                              NetworkImage(avatarUrl),
                                          radius: 20,
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.only(left: 16.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        repoName,
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 16,
                                                        ),
                                                        overflow:
                                                            TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 8,
                                                          vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: isPrivate
                                                            ? const Color(
                                                                    0xFFEF4444)
                                                                .withValues(
                                                                    alpha: 0.1)
                                                            : const Color(
                                                                    0xFF10B981)
                                                                .withValues(
                                                                    alpha: 0.1),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                8),
                                                      ),
                                                      child: Text(
                                                        isPrivate
                                                            ? 'Private'
                                                            : 'Public',
                                                        style: TextStyle(
                                                          color: isPrivate
                                                              ? const Color(
                                                                  0xFFEF4444)
                                                              : const Color(
                                                                  0xFF10B981),
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  description,
                                                  style: TextStyle(
                                                    color: Theme.of(context)
                                                        .hintColor,
                                                    fontSize: 13,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const Padding(
                                          padding:
                                              EdgeInsets.only(left: 8.0),
                                          child: ExcludeSemantics(
                                            child: Icon(
                                                Icons.chevron_right_rounded),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );

                              if (isLowSpec || !animationEnabled) {
                                return innerCard;
                              }

                              return TweenAnimationBuilder<double>(
                                tween: Tween<double>(begin: 0.0, end: 1.0),
                                duration: Duration(milliseconds: 250 + (index * 30).clamp(0, 150)),
                                curve: Curves.easeOutCubic,
                                builder: (context, value, child) {
                                  return Opacity(
                                    opacity: value,
                                    child: Transform.translate(
                                      offset: Offset(0.0, 20.0 * (1.0 - value)),
                                      child: child,
                                    ),
                                  );
                                },
                                child: innerCard,
                              );
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => ListView.builder(
                  itemCount: 5,
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        const PremiumShimmerContainer(width: 40, height: 40, borderRadius: 20),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              PremiumShimmerContainer(
                                width: MediaQuery.of(context).size.width * 0.4,
                                height: 16,
                              ),
                              const SizedBox(height: 8),
                              PremiumShimmerContainer(
                                width: MediaQuery.of(context).size.width * 0.6,
                                height: 12,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                error: (error, stack) => Center(
                  child: Text(
                    'エラーが発生しました: $error',
                    semanticsLabel: 'エラーが発生しました: $error',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
