import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../localization/app_localizations.dart';
import 'home_screen.dart';
import 'workflow_detail_screen.dart';
import 'premium_widgets.dart';

final userReposProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, username) async {
  final service = ref.watch(gitHubServiceProvider);
  return await service.getUserRepositories(username);
});

// ローカルの並び替え状態を管理
final userReposSortOrderProvider = StateProvider.autoDispose<RepositorySortOrder>((ref) => RepositorySortOrder.lastCiRun);

class UserReposScreen extends ConsumerWidget {
  final String username;
  final String avatarUrl;
  final String ownerType;

  const UserReposScreen({
    super.key,
    required this.username,
    required this.avatarUrl,
    required this.ownerType,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reposAsync = ref.watch(userReposProvider(username));
    final sortOrder = ref.watch(userReposSortOrderProvider);
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          username,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            // ユーザー情報ヘッダー
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF131B2E) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(avatarUrl),
                    radius: 30,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          username,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6366F1).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                ownerType,
                                style: const TextStyle(
                                  color: Color(0xFF6366F1),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.repositories,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 18),
                ),
                PopupMenuButton<RepositorySortOrder>(
                  icon: const Icon(Icons.swap_vert_rounded, color: Color(0xFF6366F1), size: 26),
                  tooltip: l10n.sortOrderTooltip,
                  onSelected: (order) {
                    ref.read(userReposSortOrderProvider.notifier).state = order;
                  },
                  itemBuilder: (context) {
                    final l10n = AppLocalizations.of(context)!;
                    return [
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
                          Icon(Icons.folder_open_rounded, size: 64, color: Theme.of(context).hintColor),
                          const SizedBox(height: 16),
                          Text(l10n.noRepositoriesFound, style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                    );
                  }

                  // コピーを作成してソート
                  final sortedRepos = List<Map<String, dynamic>>.from(repos);
                  switch (sortOrder) {
                    case RepositorySortOrder.lastCiRun:
                      sortedRepos.sort((a, b) {
                        final aTime = a['pushed_at'] as String? ?? a['updated_at'] as String? ?? '';
                        final bTime = b['pushed_at'] as String? ?? b['updated_at'] as String? ?? '';
                        return bTime.compareTo(aTime);
                      });
                      break;
                    case RepositorySortOrder.lastUpdated:
                      sortedRepos.sort((a, b) {
                        final aTime = a['updated_at'] as String? ?? '';
                        final bTime = b['updated_at'] as String? ?? '';
                        return bTime.compareTo(aTime);
                      });
                      break;
                    case RepositorySortOrder.name:
                      sortedRepos.sort((a, b) {
                        final aName = a['name'] as String? ?? '';
                        final bName = b['name'] as String? ?? '';
                        return aName.toLowerCase().compareTo(bName.toLowerCase());
                      });
                      break;
                    case RepositorySortOrder.stars:
                      sortedRepos.sort((a, b) {
                        final aStars = a['stargazers_count'] as int? ?? 0;
                        final bStars = b['stargazers_count'] as int? ?? 0;
                        return bStars.compareTo(aStars);
                      });
                      break;
                    case RepositorySortOrder.bestMatch:
                      // ベストマッチはデフォルトの順序を維持
                      break;
                  }

                  return ListView.builder(
                    itemCount: sortedRepos.length,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      final repo = sortedRepos[index];
                      final isPrivate = repo['private'] as bool? ?? false;
                      final repoName = repo['name'] as String? ?? '';
                      final repoFullName = repo['full_name'] as String? ?? '';
                      final description = repo['description'] as String? ?? 'No description';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: PremiumSpringButton(
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
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                repoName,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: isPrivate
                                                    ? const Color(0xFFEF4444).withValues(alpha: 0.1)
                                                    : const Color(0xFF10B981).withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                isPrivate ? 'Private' : 'Public',
                                                style: TextStyle(
                                                  color: isPrivate ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          description,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Theme.of(context).hintColor,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${repo['stargazers_count']}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Theme.of(context).hintColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
