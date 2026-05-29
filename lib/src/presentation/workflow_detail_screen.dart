import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'home_screen.dart';

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
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF6366F1)),
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
                  Icon(Icons.analytics_outlined, size: 64, color: Theme.of(context).hintColor),
                  const SizedBox(height: 16),
                  const Text('実行されたワークフローがありません', style: TextStyle(fontSize: 16)),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: runs.length,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemBuilder: (context, index) {
              final run = runs[index];
              final isSuccess = run['conclusion'] == 'success';
              final isFailure = run['conclusion'] == 'failure';
              final isCancelled = run['conclusion'] == 'cancelled';
              final isRunning = run['status'] == 'in_progress' || run['status'] == 'queued';

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

              return Semantics(
                button: true,
                label: 'ワークフローラン ${run['name']}、ステータス: ${run['conclusion']}',
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Card(
                    child: ExpansionTile(
                      shape: const Border(), // ExpansionTileの上下のボーダーを消去
                      leading: Icon(statusIcon, color: statusColor, size: 30),
                      title: Text(
                        run['head_commit_message'],
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text('Event: ${run['event']} • Branch: ${run['head_branch']}'),
                          Text('Author: ${run['head_commit_author']}'),
                        ],
                      ),
                      children: [
                        // 詳細ジョブとステップの取得
                        FutureBuilder<List<Map<String, dynamic>>>(
                          future: service.getRunJobs(repoFullName, run['id']),
                          builder: (context, jobSnapshot) {
                          if (jobSnapshot.connectionState == ConnectionState.waiting) {
                            return const Semantics(
                              liveRegion: true,
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
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
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? const Color(0xFF0F172A)
                                  : const Color(0xFFF8FAFC),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: jobs.map((job) {
                                  final steps = job['steps'] as List<dynamic>;
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Semantics(
                                        label: 'ジョブ名: ${job['name']}',
                                        child: Text(
                                          'Job: ${job['name']}',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      ...steps.map((step) {
                                        final isStepSuccess = step['conclusion'] == 'success';
                                        final isStepFailure = step['conclusion'] == 'failure';
                                        final isStepRunning = step['status'] == 'in_progress';

                                        Color stepColor = Colors.grey;
                                        IconData stepIcon = Icons.radio_button_unchecked_rounded;

                                        if (isStepRunning) {
                                          stepColor = Colors.amber;
                                          stepIcon = Icons.hourglass_bottom_rounded;
                                        } else if (isStepSuccess) {
                                          stepColor = Colors.green;
                                          stepIcon = Icons.check_rounded;
                                        } else if (isStepFailure) {
                                          stepColor = Colors.red;
                                          stepIcon = Icons.close_rounded;
                                        }

                                        return Padding(
                                          padding: const EdgeInsets.only(left: 12.0, bottom: 6.0),
                                          child: Row(
                                            children: [
                                              Icon(stepIcon, color: stepColor, size: 16),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  step['name'],
                                                  style: TextStyle(
                                                    color: isStepFailure ? Colors.red : null,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ),
                                              if (isStepFailure)
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: Colors.red.withOpacity(0.1),
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: const Text(
                                                    'Error Details',
                                                    style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                            ],
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
