import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../localization/app_localizations.dart';
import '../domain/github_service.dart';
import '../../main.dart';
import 'workflow_detail_screen.dart';
import 'settings_screen.dart';
import 'premium_widgets.dart';
import 'user_repos_screen.dart';
import 'login_screen.dart';

final gitHubServiceProvider = Provider((ref) => GitHubService());

enum RepositorySortOrder {
  lastCiRun, // 最後にCI/CDが走った順（デフォルト）
  lastUpdated,
  name,
  stars,
  bestMatch, // ベストマッチ（検索時のデフォルト）
}

enum SearchCategory {
  repositories,
  usersAndOrgs,
}

// 検索カテゴリを管理するStateProvider
final searchCategoryProvider = StateProvider<SearchCategory>((ref) => SearchCategory.repositories);

// リポジトリ検索のクエリを管理するStateProvider
final searchQueryProvider = StateProvider<String>((ref) => '');

// 並び替え順を管理するStateProvider
final repositorySortOrderProvider =
    StateProvider<RepositorySortOrder>((ref) => RepositorySortOrder.lastCiRun);

// 実質的な並び替え順を決定するProvider
final effectiveSortOrderProvider = Provider<RepositorySortOrder>((ref) {
  final query = ref.watch(searchQueryProvider);
  final selectedSort = ref.watch(repositorySortOrderProvider);

  // 検索ワードが入っている場合は、明示的に別を選択していない限り「ベストマッチ」をデフォルトにする
  if (query.isNotEmpty) {
    if (selectedSort == RepositorySortOrder.lastCiRun) {
      return RepositorySortOrder.bestMatch;
    }
    return selectedSort;
  }

  // 検索ワードが空の場合は、明示的にbestMatchになっていてもlastCiRunに切り替える
  if (selectedSort == RepositorySortOrder.bestMatch) {
    return RepositorySortOrder.lastCiRun;
  }
  return selectedSort;
});

// ユーザー・組織の検索結果をフェッチするProvider
final usersSearchProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final service = ref.watch(gitHubServiceProvider);
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty) return [];
  return await service.searchUsersAndOrgs(query: query);
});

// フィルター条件を管理するStateProvider
final repositoryTypeFilterProvider = StateProvider<String>((ref) => 'all'); // 'all', 'public', 'private'
final repositoryOwnerTypeFilterProvider = StateProvider<String>((ref) => 'all'); // 'all', 'user', 'organization'
final repositoryOwnerFilterProvider = StateProvider<String?>((ref) => null); // null = すべて, or 特定のowner名

// フィルタリングやソートをする前の生のリポジトリリストを取得するProvider (オーナー一覧抽出などに使用)
final allRawRepositoriesProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final service = ref.watch(gitHubServiceProvider);
  return await service.searchRepositories(query: '', sort: 'updated');
});

// 最終的に表示するリポジトリ一覧を取得するFutureProvider
final repositoriesProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final service = ref.watch(gitHubServiceProvider);
  final query = ref.watch(searchQueryProvider);
  final sortOrder = ref.watch(effectiveSortOrderProvider);

  // 各種フィルター設定をwatch
  final typeFilter = ref.watch(repositoryTypeFilterProvider);
  final ownerTypeFilter = ref.watch(repositoryOwnerTypeFilterProvider);
  final ownerFilter = ref.watch(repositoryOwnerFilterProvider);

  var repos = await service.searchRepositories(
    query: query,
    sort: sortOrder == RepositorySortOrder.bestMatch ? 'best_match' : 'updated',
  );

  // 1. タイプフィルター (Public / Private)
  if (typeFilter != 'all') {
    final isPrivateTarget = typeFilter == 'private';
    repos = repos.where((r) => (r['private'] as bool? ?? false) == isPrivateTarget).toList();
  }

  // 2. オーナータイプフィルター (User / Organization)
  if (ownerTypeFilter != 'all') {
    final isOrgTarget = ownerTypeFilter == 'organization';
    repos = repos.where((r) {
      final ownerType = r['owner_type'] as String? ?? 'User';
      return ownerType.toLowerCase() == (isOrgTarget ? 'organization' : 'user');
    }).toList();
  }

  // 3. アカウント名フィルター (Owner)
  if (ownerFilter != null) {
    repos = repos.where((r) => r['owner'] == ownerFilter).toList();
  }

  // クライアント側で並び替えを適用
  switch (sortOrder) {
    case RepositorySortOrder.bestMatch:
      // APIのソート順（Relevance）をそのまま維持する
      break;
    case RepositorySortOrder.lastCiRun:
      repos.sort((a, b) {
        // pushed_atをCI/CDが最後に走った日時の代理として使用
        final aTime = a['pushed_at'] as String? ?? a['updated_at'] as String? ?? '';
        final bTime = b['pushed_at'] as String? ?? b['updated_at'] as String? ?? '';
        return bTime.compareTo(aTime);
      });
      break;
    case RepositorySortOrder.lastUpdated:
      repos.sort((a, b) {
        final aTime = a['updated_at'] as String? ?? '';
        final bTime = b['updated_at'] as String? ?? '';
        return bTime.compareTo(aTime); // 最新順
      });
      break;
    case RepositorySortOrder.name:
      repos.sort((a, b) {
        final aName = a['name'] as String? ?? '';
        final bName = b['name'] as String? ?? '';
        return aName.toLowerCase().compareTo(bName.toLowerCase()); // アルファベット順
      });
      break;
    case RepositorySortOrder.stars:
      repos.sort((a, b) {
        final aStars = a['stargazers_count'] as int? ?? 0;
        final bStars = b['stargazers_count'] as int? ?? 0;
        return bStars.compareTo(aStars); // スター数順
      });
      break;
  }

  return repos;
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

  Future<void> _checkForUpdates() async {
    final service = ref.read(gitHubServiceProvider);
    final updateInfo = await service.checkUpdate();

    if (!mounted) return;
    final prefs = ref.read(updateNotifyEnabledProvider);
    if (updateInfo['hasUpdate'] == true && prefs) {
      final l10n = AppLocalizations.of(context)!;

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
                l10n.updateInfoTitle,
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
                label: l10n.newVersionAvailable(updateInfo['latestVersion'] as String? ?? ''),
                child: Text(
                  l10n.newVersionAvailable(updateInfo['latestVersion'] as String? ?? ''),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              Semantics(
                label: l10n.currentVersion(updateInfo['currentVersion'] as String? ?? ''),
                child: Text(l10n.currentVersion(updateInfo['currentVersion'] as String? ?? '')),
              ),
              const SizedBox(height: 12),
              Text(l10n.releaseNotes,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Container(
                constraints: const BoxConstraints(maxHeight: 100),
                width: double.maxFinite,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text((updateInfo['releaseNotes'] as String?) ?? l10n.releaseNotesFallback),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.later),
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
              child: Text(l10n.update),
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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        ),
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
            tooltip: l10n.themeToggle,
            onPressed: () {
              ref.read(themeModeProvider.notifier).state =
                  isDark ? ThemeMode.light : ThemeMode.dark;
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: l10n.settings,
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
              label: l10n.searchHintText,
              hint: l10n.searchHintText,
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  ref.read(searchQueryProvider.notifier).state = value;
                },
                decoration: InputDecoration(
                  hintText: l10n.searchHint,
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
            const SizedBox(height: 12),
            // カテゴリ切り替えトグル（常時表示）
            Consumer(
              builder: (context, ref, child) {
                final searchCategory = ref.watch(searchCategoryProvider);
                return Row(
                  children: [
                    ChoiceChip(
                      label: Text(l10n.searchTypeRepos),
                      selected: searchCategory == SearchCategory.repositories,
                      selectedColor: const Color(0xFF6366F1).withOpacity(0.2),
                      checkmarkColor: const Color(0xFF6366F1),
                      labelStyle: TextStyle(
                        color: searchCategory == SearchCategory.repositories
                            ? const Color(0xFF6366F1)
                            : null,
                        fontWeight: FontWeight.bold,
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          ref.read(searchCategoryProvider.notifier).state =
                              SearchCategory.repositories;
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: Text(l10n.searchTypeUsers),
                      selected: searchCategory == SearchCategory.usersAndOrgs,
                      selectedColor: const Color(0xFF6366F1).withOpacity(0.2),
                      checkmarkColor: const Color(0xFF6366F1),
                      labelStyle: TextStyle(
                        color: searchCategory == SearchCategory.usersAndOrgs
                            ? const Color(0xFF6366F1)
                            : null,
                        fontWeight: FontWeight.bold,
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          ref.read(searchCategoryProvider.notifier).state =
                              SearchCategory.usersAndOrgs;
                        }
                      },
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            const _FilterSelectorArea(),
            const SizedBox(height: 16),
            
            // リポジトリ検索モードのときのみ、ソート・フィルターヘッダーを表示
            Consumer(
              builder: (context, ref, child) {
                final searchCategory = ref.watch(searchCategoryProvider);
                final query = ref.watch(searchQueryProvider);
                if (query.isNotEmpty && searchCategory == SearchCategory.usersAndOrgs) {
                  return const SizedBox.shrink();
                }
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.repositories,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontSize: 18),
                    ),
                    PopupMenuButton<RepositorySortOrder>(
                      icon: const Icon(Icons.swap_vert_rounded, color: Color(0xFF6366F1), size: 26),
                      tooltip: l10n.sortOrderTooltip,
                      onSelected: (order) {
                        ref.read(repositorySortOrderProvider.notifier).state = order;
                      },
                      itemBuilder: (context) {
                        final l10n = AppLocalizations.of(context)!;
                        return [
                          if (query.isNotEmpty)
                            PopupMenuItem(
                              value: RepositorySortOrder.bestMatch,
                              child: Row(
                                children: [
                                  const Icon(Icons.sort_rounded, size: 16, color: Color(0xFF6366F1)),
                                  const SizedBox(width: 8),
                                  Text(l10n.sortBestMatch),
                                ],
                              ),
                            ),
                          PopupMenuItem(
                            value: RepositorySortOrder.lastCiRun,
                            child: Row(
                              children: [
                                const Icon(Icons.rocket_launch_rounded, size: 16, color: Color(0xFF6366F1)),
                                const SizedBox(width: 8),
                                Text(l10n.sortLastCiRun),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: RepositorySortOrder.lastUpdated,
                            child: Text(l10n.sortLastUpdated),
                          ),
                          PopupMenuItem(
                            value: RepositorySortOrder.name,
                            child: Text(l10n.sortName),
                          ),
                          PopupMenuItem(
                            value: RepositorySortOrder.stars,
                            child: Text(l10n.sortStars),
                          ),
                        ];
                      },
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Consumer(
                builder: (context, ref, child) {
                  final searchCategory = ref.watch(searchCategoryProvider);
                  final query = ref.watch(searchQueryProvider);
                  
                  if (query.isNotEmpty && searchCategory == SearchCategory.usersAndOrgs) {
                    final usersAsync = ref.watch(usersSearchProvider);
                    return usersAsync.when(
                      data: (users) {
                        if (users.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.people_alt_rounded,
                                    size: 64, color: Theme.of(context).hintColor),
                                const SizedBox(height: 16),
                                Text(l10n.noRepositoriesFound,
                                    style: const TextStyle(fontSize: 16)),
                              ],
                            ),
                          );
                        }
                        return ListView.builder(
                          itemCount: users.length,
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            final user = users[index];
                            final login = user['login'] as String? ?? '';
                            final avatarUrl = user['avatar_url'] as String? ?? '';
                            final type = user['type'] as String? ?? 'User';

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: PremiumSpringButton(
                                onTap: () {
                                  Navigator.push<void>(
                                    context,
                                    MaterialPageRoute<void>(
                                      builder: (context) => UserReposScreen(
                                        username: login,
                                        avatarUrl: avatarUrl,
                                        ownerType: type,
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
                                          backgroundImage: NetworkImage(avatarUrl),
                                          radius: 24,
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                login,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                type,
                                                style: TextStyle(
                                                  color: Theme.of(context).hintColor,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (err, stack) => Center(child: Text(l10n.errorOccurred(err.toString()))),
                    );
                  }
                  
                  return reposAsync.when(
                    data: (repos) {
                      if (repos.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.folder_open_rounded,
                                  size: 64, color: Theme.of(context).hintColor),
                              const SizedBox(height: 16),
                              Text(l10n.noRepositoriesFound,
                                  style: const TextStyle(fontSize: 16)),
                            ],
                          ),
                        );
                      }
                      return ListView.builder(
                        itemCount: repos.length,
                        physics: const BouncingScrollPhysics(),

                    cacheExtent: 400,
                    itemBuilder: (context, index) {
                      final repo = repos[index];
                      final isPrivate = repo['private'] as bool? ?? false;
                      final repoName = repo['name'] as String? ?? '';
                      final repoFullName = repo['full_name'] as String? ?? '';
                      final avatarUrl = repo['avatar_url'] as String? ?? '';
                      final description = repo['description'] as String? ?? 'No description';
                      final ownerType = repo['owner_type'] as String? ?? 'User';

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
                                          backgroundImage: ResizeImage(
                                            NetworkImage(avatarUrl),
                                            width: 80,
                                            height: 80,
                                          ),
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
                                                    // Org / User バッジ
                                                    _buildOwnerTypeBadge(ownerType),
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
                    l10n.errorOccurred(error.toString()),
                    semanticsLabel: l10n.errorOccurred(error.toString()),
                  ),
                ),
              );
            },
          ),
        ),
      ],
        ),
      ),
    );
  }

  Widget _buildOwnerTypeBadge(String ownerType) {
    final isOrg = ownerType.toLowerCase() == 'organization';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isOrg
            ? const Color(0xFF6366F1).withValues(alpha: 0.1)
            : const Color(0xFF64748B).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isOrg ? 'Org' : 'User',
        style: TextStyle(
          color: isOrg ? const Color(0xFF6366F1) : const Color(0xFF64748B),
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _FilterSelectorArea extends ConsumerWidget {
  const _FilterSelectorArea();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final typeFilter = ref.watch(repositoryTypeFilterProvider);
    final ownerTypeFilter = ref.watch(repositoryOwnerTypeFilterProvider);
    final ownerFilter = ref.watch(repositoryOwnerFilterProvider);
    final rawReposAsync = ref.watch(allRawRepositoriesProvider);
    final searchCategory = ref.watch(searchCategoryProvider);
    final query = ref.watch(searchQueryProvider);

    final List<String> owners = rawReposAsync.maybeWhen(
      data: (repos) => repos.map((r) => r['owner'] as String).toSet().toList()..sort(),
      orElse: () => [],
    );

    // アクティブなフィルター数を計算
    int activeCount = 0;
    if (typeFilter != 'all') {
      activeCount++;
    }
    if (ownerTypeFilter != 'all') {
      activeCount++;
    }
    if (ownerFilter != null) {
      activeCount++;
    }
    if (query.isNotEmpty && searchCategory != SearchCategory.repositories) {
      activeCount++;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onTap: () => _showFilterSheet(context, ref, owners, isDark),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: activeCount > 0
                ? const Color(0xFF6366F1).withValues(alpha: 0.15)
                : (isDark ? const Color(0xFF131B2E) : const Color(0xFFF1F5F9)),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: activeCount > 0
                  ? const Color(0xFF6366F1)
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.tune_rounded,
                size: 18,
                color: activeCount > 0 ? const Color(0xFF6366F1) : null,
              ),
              const SizedBox(width: 6),
              Text(
                l10n.filter,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: activeCount > 0 ? const Color(0xFF6366F1) : null,
                ),
              ),
              if (activeCount > 0) ...[
                const SizedBox(width: 6),
                Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Color(0xFF6366F1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$activeCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterSheet(
    BuildContext context,
    WidgetRef ref,
    List<String> owners,
    bool isDark,
  ) {
    // 起動時の初期値をローカル変数にコピー
    String localTypeFilter = ref.read(repositoryTypeFilterProvider);
    String localOwnerTypeFilter = ref.read(repositoryOwnerTypeFilterProvider);
    String? localOwnerFilter = ref.read(repositoryOwnerFilterProvider);
    SearchCategory localSearchCategory = ref.read(searchCategoryProvider);
    final isGuest = ref.read(isGuestModeProvider);
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setLocalState) {
          return Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).padding.bottom + 16),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                // ハンドル
                Center(
                  child: Container(
                    width: 36,
                    height: 5,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[700] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // ヘッダー
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.tune_rounded,
                          color: Color(0xFF6366F1),
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.filterConditions,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            color: isDark ? Colors.white : const Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                    TextButton.icon(
                      onPressed: () {
                        setLocalState(() {
                          localTypeFilter = 'all';
                          localOwnerTypeFilter = 'all';
                          localOwnerFilter = null;
                          localSearchCategory = SearchCategory.repositories;
                        });
                      },
                      icon: const Icon(Icons.refresh_rounded, size: 16, color: Color(0xFF6366F1)),
                      label: Text(
                        l10n.reset,
                        style: const TextStyle(
                          color: Color(0xFF6366F1),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        backgroundColor: const Color(0xFF6366F1).withValues(alpha: 0.1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),



                // ── タイプ ──
                Text(
                  l10n.repositoryType,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 10,
                  children: [
                    _filterChip(ref, context, isDark, label: l10n.all, value: 'all', groupValue: localTypeFilter,
                        icon: Icons.apps_rounded,
                        onTap: () => setLocalState(() => localTypeFilter = 'all')),
                    _filterChip(ref, context, isDark, label: 'Public', value: 'public', groupValue: localTypeFilter,
                        icon: Icons.public_rounded,
                        onTap: () => setLocalState(() => localTypeFilter = 'public')),
                    _filterChip(ref, context, isDark, label: 'Private', value: 'private', groupValue: localTypeFilter,
                        icon: Icons.lock_rounded,
                        onTap: () => setLocalState(() => localTypeFilter = 'private')),
                  ],
                ),
                const SizedBox(height: 16),

                // ── オーナータイプ ──
                Text(
                  l10n.ownerType,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 10,
                  children: [
                    _filterChip(ref, context, isDark, label: l10n.all, value: 'all', groupValue: localOwnerTypeFilter,
                        icon: Icons.people_outline_rounded,
                        onTap: () => setLocalState(() => localOwnerTypeFilter = 'all')),
                    _filterChip(ref, context, isDark, label: l10n.personal, value: 'user', groupValue: localOwnerTypeFilter,
                        icon: Icons.person_rounded,
                        onTap: () => setLocalState(() => localOwnerTypeFilter = 'user')),
                    _filterChip(ref, context, isDark, label: l10n.organization, value: 'organization', groupValue: localOwnerTypeFilter,
                        icon: Icons.business_rounded,
                        onTap: () => setLocalState(() => localOwnerTypeFilter = 'organization')),
                  ],
                ),

                // ── アカウント名 ──
                if (owners.isNotEmpty && !isGuest) ...[
                  const SizedBox(height: 16),
                  Text(
                    l10n.account,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _filterChip(ref, context, isDark, label: l10n.all, value: 'ALL_NULL', groupValue: localOwnerFilter ?? 'ALL_NULL',
                          icon: Icons.alternate_email_rounded,
                          onTap: () => setLocalState(() => localOwnerFilter = null)),
                      ...owners.map((owner) => _filterChip(
                        ref, context, isDark,
                        label: '@$owner',
                        value: owner,
                        groupValue: localOwnerFilter ?? 'ALL_NULL',
                        avatarUrl: 'https://github.com/$owner.png?size=40',
                        onTap: () => setLocalState(() => localOwnerFilter = owner),
                      )),
                    ],
                  ),
                ],
                const SizedBox(height: 32),
                
                // 適用ボタン
                GestureDetector(
                  onTap: () {
                    // 適用ボタンを押した瞬間にProviderを更新する
                    ref.read(repositoryTypeFilterProvider.notifier).state = localTypeFilter;
                    ref.read(repositoryOwnerTypeFilterProvider.notifier).state = localOwnerTypeFilter;
                    ref.read(repositoryOwnerFilterProvider.notifier).state = localOwnerFilter;
                    ref.read(searchCategoryProvider.notifier).state = localSearchCategory;
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        l10n.applyFilter,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            ),
          );
        },
      ),
    );
  }

  Widget _filterChip(
    WidgetRef ref,
    BuildContext context,
    bool isDark, {
    required String label,
    required String value,
    required String groupValue,
    required VoidCallback onTap,
    IconData? icon,
    String? avatarUrl,
  }) {
    final isSelected = value == groupValue;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected
              ? null
              : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (avatarUrl != null) ...[
              CircleAvatar(
                radius: 8,
                backgroundImage: NetworkImage(avatarUrl),
                backgroundColor: Colors.transparent,
              ),
              const SizedBox(width: 6),
            ] else if (icon != null) ...[
              Icon(
                icon,
                size: 15,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.grey[400] : Colors.grey[600]),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.grey[200] : Colors.grey[800]),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
