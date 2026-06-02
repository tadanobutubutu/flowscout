import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'premium_widgets.dart';

// アップデート通知設定を保持するStateProvider
final updateNotifyEnabledProvider = StateProvider<bool>((ref) => true);

// 「高度な設定（アドバンス項目）」の表示状態を管理するStateProvider
final showAdvancedSettingsProvider = StateProvider<bool>((ref) => false);

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifyEnabled = ref.watch(updateNotifyEnabledProvider);
    final isLowSpec = ref.watch(lowSpecModeProvider);
    final showAdvanced = ref.watch(showAdvancedSettingsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('詳細設定', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          // --------------------------------------------------
          // セクション：省電力 & パフォーマンス (基本項目)
          // --------------------------------------------------
          _buildSectionHeader(context, '省電力・パフォーマンス'),
          SwitchListTile(
            title: const Text('省電力・低スペック優先モード'),
            subtitle: const Text(
                '端末への負荷やバッテリー消費を抑えるため、極上演出やシマー効果をすべてオフにし、フラットUIに切り替えます。'),
            value: isLowSpec,
            activeTrackColor: const Color(0xFF6366F1),
            onChanged: (value) {
              ref.read(lowSpecModeProvider.notifier).state = value;
            },
          ),
          
          if (!isLowSpec) ...[
            const Divider(indent: 16, endIndent: 16),
            // スプリングアニメーション（基本項目: ON/OFF）
            SwitchListTile(
              title: const Text('弾むスプリング物理アニメーション'),
              subtitle: const Text('ボタンタップ時に弾む物理フィードバック演出を有効にします。'),
              value: ref.watch(springAnimationEnabledProvider),
              activeTrackColor: const Color(0xFF6366F1),
              onChanged: (value) {
                ref.read(springAnimationEnabledProvider.notifier).state = value;
              },
            ),

            const Divider(indent: 16, endIndent: 16),
            // シマーローディング（基本項目: ON/OFF）
            SwitchListTile(
              title: const Text('シマー（波打つ光）ローディング'),
              subtitle: const Text('データ読み込み中にキラキラと光るスケルトン画面を表示します。'),
              value: ref.watch(shimmerLoadingEnabledProvider),
              activeTrackColor: const Color(0xFF6366F1),
              onChanged: (value) {
                ref.read(shimmerLoadingEnabledProvider.notifier).state = value;
              },
            ),

            const Divider(indent: 16, endIndent: 16),
            // リスト出現アニメーション（基本項目: ON/OFF）
            SwitchListTile(
              title: const Text('リスト出現アニメーション (フェード/スライド)'),
              subtitle: const Text('マイリポジトリやワークフロー詳細の表示時に、ふわっと浮き上がるように出現させます。'),
              value: ref.watch(listEntranceAnimationEnabledProvider),
              activeTrackColor: const Color(0xFF6366F1),
              onChanged: (value) {
                ref.read(listEntranceAnimationEnabledProvider.notifier).state = value;
              },
            ),
          ],

          const Divider(),
          // --------------------------------------------------
          // セクション：ハプティクス（指先触感）(基本項目)
          // --------------------------------------------------
          _buildSectionHeader(context, 'ハプティクス（指先触感）'),
          SwitchListTile(
            title: const Text('ハプティクスフィードバック'),
            subtitle: const Text('ボタンタップや設定切り替え時に、微小な振動を返して物理的な手応えを感じさせます。'),
            value: ref.watch(hapticFeedbackProvider),
            activeTrackColor: const Color(0xFF6366F1),
            onChanged: (value) {
              ref.read(hapticFeedbackProvider.notifier).state = value;
              if (value) {
                HapticFeedback.lightImpact();
              }
            },
          ),

          const Divider(),
          // --------------------------------------------------
          // アドバンスド・プロパティ (高度な設定) ── トグルによる開閉
          // --------------------------------------------------
          if (!isLowSpec) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Card(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF131B2E)
                    : const Color(0xFFF1F5F9),
                child: ExpansionTile(
                  shape: const Border(),
                  title: const Text(
                    '⚙️ 高度な微調整（アドバンス項目）',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF6366F1),
                    ),
                  ),
                  subtitle: const Text('スライダーや詳細パラメータによる挙動調整を行います。'),
                  children: [
                    const Divider(height: 1),
                    // アニメーション縮小率スライダー
                    if (ref.watch(springAnimationEnabledProvider))
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('タップ時の縮小率', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                Text('${(ref.watch(springScaleFactorProvider) * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF6366F1))),
                              ],
                            ),
                            Slider(
                              value: ref.watch(springScaleFactorProvider),
                              min: 0.90,
                              max: 0.98,
                              divisions: 8,
                              activeColor: const Color(0xFF6366F1),
                              onChanged: (value) {
                                ref.read(springScaleFactorProvider.notifier).state = value;
                              },
                            ),
                          ],
                        ),
                      ),
                    
                    // シマースピードスライダー
                    if (ref.watch(shimmerLoadingEnabledProvider))
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('シマーアニメーション速度', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                Text('${ref.watch(shimmerSpeedMsProvider)} ms', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF6366F1))),
                              ],
                            ),
                            Slider(
                              value: ref.watch(shimmerSpeedMsProvider).toDouble(),
                              min: 800,
                              max: 2500,
                              divisions: 17,
                              activeColor: const Color(0xFF6366F1),
                              onChanged: (value) {
                                ref.read(shimmerSpeedMsProvider.notifier).state = value.toInt();
                              },
                            ),
                          ],
                        ),
                      ),
                    
                    // ハプティクス強度詳細ドロップダウン
                    if (ref.watch(hapticFeedbackProvider))
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('バイブレーション強度', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                            DropdownButton<HapticStrength>(
                              value: ref.watch(hapticStrengthProvider),
                              dropdownColor: Theme.of(context).cardColor,
                              onChanged: (strength) {
                                if (strength != null) {
                                  ref.read(hapticStrengthProvider.notifier).state = strength;
                                  switch (strength) {
                                    case HapticStrength.light:
                                      HapticFeedback.lightImpact();
                                      break;
                                    case HapticStrength.medium:
                                      HapticFeedback.mediumImpact();
                                      break;
                                    case HapticStrength.heavy:
                                      HapticFeedback.heavyImpact();
                                      break;
                                    case HapticStrength.selection:
                                      HapticFeedback.selectionClick();
                                      break;
                                  }
                                }
                              },
                              items: const [
                                DropdownMenuItem(value: HapticStrength.light, child: Text('Light (繊細)')),
                                DropdownMenuItem(value: HapticStrength.medium, child: Text('Medium (通常)')),
                                DropdownMenuItem(value: HapticStrength.heavy, child: Text('Heavy (強力)')),
                                DropdownMenuItem(value: HapticStrength.selection, child: Text('Selection (クリック感)')),
                              ],
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const Divider(),
          ],

          // --------------------------------------------------
          // セクション：通知とアップデート
          // --------------------------------------------------
          _buildSectionHeader(context, '通知とアップデート'),
          SwitchListTile(
            title: const Text('アプデチェック通知'),
            subtitle: const Text(
                'アプリ起動時にGitHubの最新リリース情報を自動でチェックし、アップデートがある場合に通知します。'),
            value: notifyEnabled,
            activeTrackColor: const Color(0xFF6366F1),
            onChanged: (value) {
              ref.read(updateNotifyEnabledProvider.notifier).state = value;
            },
          ),
          
          const Divider(),
          // --------------------------------------------------
          // セクション：GitHub 連携
          // --------------------------------------------------
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
                showDialog<void>(
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
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Semantics(
                                liveRegion: true,
                                label: 'GitHubとの連携を解除しました',
                                child: const Text('GitHubとの連携を解除しました。'),
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
