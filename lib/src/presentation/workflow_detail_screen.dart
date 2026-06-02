import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'home_screen.dart';
import 'premium_widgets.dart';
import 'job_log_screen.dart';

class WorkflowDetailScreen extends ConsumerWidget {
  final String repoFullName;
  final String repoName;

  const WorkflowDetailScreen({
    super.key,
    required this.repoFullName,
    required this.repoName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(gitHubServiceProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          repoName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: service.getWorkflowRuns(repoFullName),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return ListView.builder(
              itemCount: 4,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) => Container(
                margin: const EdgeInsets.only(bottom: 16),
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
                    const PremiumShimmerContainer(width: 30, height: 30, borderRadius: 15),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          PremiumShimmerContainer(
                            width: MediaQuery.of(context).size.width * 0.5,
                            height: 15,
                          ),
                          const SizedBox(height: 8),
                          PremiumShimmerContainer(
                            width: MediaQuery.of(context).size.width * 0.3,
                            height: 12,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (snapshot.hasError) {
            return Semantics(
              label: 'ワークフローの取得に失敗しました: ${snapshot.error}',
              child: Center(
                child: Text('ワークフローの取得に失敗しました: ${snapshot.error}'),
              ),
            );
          }

          final runs = snapshot.data ?? [];

          if (runs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.analytics_outlined,
                      size: 64, color: Theme.of(context).hintColor),
                  const SizedBox(height: 16),
                  const Text('実行されたワークフローがありません',
                      style: TextStyle(fontSize: 16)),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: runs.length,
            physics: const BouncingScrollPhysics(),
            cacheExtent: 400,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemBuilder: (context, index) {
              final run = runs[index];
              final conclusion = run['conclusion'] as String? ?? 'pending';
              final status = run['status'] as String? ?? 'queued';
              final isSuccess = conclusion == 'success';
              final isFailure = conclusion == 'failure';
              final isCancelled = conclusion == 'cancelled';
              final isRunning =
                  status == 'in_progress' || status == 'queued';

              Color statusColor = const Color(0xFF94A3B8); // pending/queued
              IconData statusIcon = Icons.help_outline_rounded;

              if (isRunning) {
                statusColor = const Color(0xFFF59E0B); // warning/orange
                statusIcon = Icons.hourglass_empty_rounded;
              } else if (isSuccess) {
                statusColor = const Color(0xFF10B981); // emerald green
                statusIcon = Icons.check_circle_outline_rounded;
              } else if (isFailure) {
                statusColor = const Color(0xFFEF4444); // red
                statusIcon = Icons.error_outline_rounded;
              } else if (isCancelled) {
                statusColor = const Color(0xFF6B7280); // gray
                statusIcon = Icons.cancel_outlined;
              }

              final runName = run['name'] as String? ?? 'Workflow';
              final headCommitMessage = run['head_commit_message'] as String? ?? 'No message';
              final event = run['event'] as String? ?? '';
              final headBranch = run['head_branch'] as String? ?? '';
              final headCommitAuthor = run['head_commit_author'] as String? ?? '';
              final runId = run['id'] as int? ?? 0;

              return Semantics(
                button: true,
                label: 'ワークフローラン $runName、ステータス: $conclusion',
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Card(
                    child: ExpansionTile(
                      shape: const Border(), // ExpansionTileの上下のボーダーを消去
                      leading: Icon(statusIcon, color: statusColor, size: 30),
                      title: Text(
                        headCommitMessage,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                              'Event: $event • Branch: $headBranch'),
                          Text('Author: $headCommitAuthor'),
                        ],
                      ),
                      children: [
                        // 詳細ジョブとステップの取得
                        FutureBuilder<List<Map<String, dynamic>>>(
                          future: service.getRunJobs(repoFullName, runId),
                          builder: (context, jobSnapshot) {
                            if (jobSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Semantics(
                                liveRegion: true,
                                label: 'ジョブ情報をロード中',
                                child: const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Center(
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2)),
                                ),
                              );
                            }

                            final jobs = jobSnapshot.data ?? [];
                            if (jobs.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text('ジョブ情報が見つかりません。'),
                              );
                            }

                            return Container(
                              padding: const EdgeInsets.all(16),
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? const Color(0xFF0F172A)
                                  : const Color(0xFFF8FAFC),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: jobs.map((job) {
                                  final jobMap = job;
                                  final jobName = jobMap['name'] as String? ?? 'Job';
                                  final int jobId = jobMap['id'] as int? ?? 0;
                                  final steps = jobMap['steps'] as List<dynamic>? ?? [];
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          Navigator.push<void>(
                                            context,
                                            MaterialPageRoute<void>(
                                              builder: (context) => JobLogScreen(
                                                repoFullName: repoFullName,
                                                jobId: jobId,
                                                jobName: jobName,
                                              ),
                                            ),
                                          );
                                        },
                                        borderRadius: BorderRadius.circular(8),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Semantics(
                                                label: 'ジョブ名: $jobName',
                                                child: Text(
                                                  'Job: $jobName',
                                                  style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 14,
                                                      color: Color(0xFF6366F1)),
                                                ),
                                              ),
                                              const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.grey),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      ...steps.map((step) {
                                        final stepMap = step as Map<String, dynamic>;
                                        final stepConclusion = stepMap['conclusion'] as String? ?? 'pending';
                                        final stepStatus = stepMap['status'] as String? ?? 'queued';
                                        final stepName = stepMap['name'] as String? ?? 'Step';
                                        
                                        final isStepSuccess =
                                            stepConclusion == 'success';
                                        final isStepFailure =
                                            stepConclusion == 'failure';
                                        final isStepRunning =
                                            stepStatus == 'in_progress';

                                        Color stepColor = Colors.grey;
                                        IconData stepIcon = Icons
                                            .radio_button_unchecked_rounded;

                                        if (isStepRunning) {
                                          stepColor = Colors.amber;
                                          stepIcon =
                                              Icons.hourglass_bottom_rounded;
                                        } else if (isStepSuccess) {
                                          stepColor = Colors.green;
                                          stepIcon = Icons.check_rounded;
                                        } else if (isStepFailure) {
                                          stepColor = Colors.red;
                                          stepIcon = Icons.close_rounded;
                                        }

                                        return InkWell(
                                          onTap: () {
                                            Navigator.push<void>(
                                              context,
                                              MaterialPageRoute<void>(
                                                builder: (context) => JobLogScreen(
                                                  repoFullName: repoFullName,
                                                  jobId: jobId,
                                                  jobName: '$jobName - $stepName',
                                                  highlightKeyword: stepName,
                                                ),
                                              ),
                                            );
                                          },
                                          borderRadius: BorderRadius.circular(6),
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 12.0, bottom: 6.0, top: 6.0),
                                            child: Row(
                                              children: [
                                                Icon(stepIcon,
                                                    color: stepColor, size: 16),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    stepName,
                                                    style: TextStyle(
                                                      color: isStepFailure
                                                          ? Colors.red
                                                          : null,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ),
                                                if (isStepFailure)
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 6,
                                                        vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: Colors.red
                                                          .withValues(alpha: 0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4),
                                                    ),
                                                    child: const Text(
                                                      'Error Details',
                                                      style: TextStyle(
                                                          color: Colors.red,
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }),
                                      const Divider(height: 20),
                                    ],
                                  );
                                }).toList(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
