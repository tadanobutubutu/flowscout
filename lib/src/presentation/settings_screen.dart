import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// アップデート通知設定を保持するStateProvider
final updateNotifyEnabledProvider = StateProvider<bool>((ref) => true);

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifyEnabled = ref.watch(updateNotifyEnabledProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('設定', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          _buildSectionHeader(context, '通知とアップデート'),
          SwitchListTile(
            title: const Text('アプデチェック通知'),
            subtitle: const Text(
                'アプリ起動時にGitHubの最新リリース情報を自動でチェックし、アップデートがある場合に通知します。'),
            value: notifyEnabled,
            activeColor: const Color(0xFF6366F1),
            onChanged: (value) {
              ref.read(updateNotifyEnabledProvider.notifier).state = value;
            },
          ),
          const Divider(),
          _buildSectionHeader(context, 'GitHub 連携'),
          Semantics(
            button: true,
            label: 'GitHub接続解除ボタン',
            child: ListTile(
              leading: const Icon(Icons.account_circle_outlined, size: 28),
              title: const Text('GitHub 接続解除'),
              subtitle: const Text('現在のアカウントとの連携を解除し、ログアウトします。'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                // ログアウト処理
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('連携を解除しますか？'),
                    content: const Text('接続を解除すると、リポジトリやCI/CDの実行状況が見られなくなります。'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('キャンセル'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red),
                        onPressed: () {
                          // ログアウト処理を実行する想定
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Semantics(
                                liveRegion: true,
                                label: 'GitHubとの連携を解除しました',
                                child: Text('GitHubとの連携を解除しました。'),
                              ),
                            ),
                          );
                        },
                        child: const Text('解除',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const Divider(),
          _buildSectionHeader(context, 'このアプリについて'),
          const ListTile(
            leading: Icon(Icons.info_outline_rounded),
            title: Text('Flowscout'),
            subtitle: Text('Version 1.0.0 (Build 1)'),
          ),
          const ListTile(
            leading: Icon(Icons.accessibility_new_rounded),
            title: Text('アクセシビリティ対応'),
            subtitle: Text(
                'WCAG 2.2、Apple HIG Accessibility、およびAndroid Build Accessible Apps ガイドラインに準拠して設計されています。'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFF6366F1),
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}
