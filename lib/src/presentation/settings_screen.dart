import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'premium_widgets.dart';
import 'login_screen.dart';
import 'home_screen.dart';

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

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Theme.of(context).brightness == Brightness.dark
              ? Brightness.light
              : Brightness.dark,
          statusBarBrightness: Theme.of(context).brightness == Brightness.dark
              ? Brightness.dark
              : Brightness.light,
        ),
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
            ExpansionTile(
              shape: const Border(),
              title: const Text(
                '高度な微調整',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: const Text('各演出の詳細パラメータを調整します。'),
              children: const [
                Divider(height: 1),
                // アニメーション縮小率スライダー
                _SpringScaleSlider(),
                Divider(height: 1, indent: 16, endIndent: 16),
                // シマースピードスライダー
                _ShimmerSpeedSlider(),
                Divider(height: 1, indent: 16, endIndent: 16),
                // ハプティクス強度詳細ドロップダウン
                _HapticStrengthDropdown(),
              ],
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
          const _GitHubAccountTile(),
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

// ── アドバンス設定の各ウィジェットをクラスに分離 ──

class _SpringScaleSlider extends ConsumerWidget {
  const _SpringScaleSlider();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEnabled = ref.watch(springAnimationEnabledProvider);
    return IgnorePointer(
      ignoring: !isEnabled,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 250),
        opacity: isEnabled ? 1.0 : 0.4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      isEnabled
                          ? 'タップ時の縮小率'
                          : 'タップ時の縮小率 (上のスイッチを有効にすると調整可能)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isEnabled ? null : Theme.of(context).disabledColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${(ref.watch(springScaleFactorProvider) * 100).toInt()}%',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Color(0xFF6366F1)),
                  ),
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
      ),
    );
  }
}

class _ShimmerSpeedSlider extends ConsumerWidget {
  const _ShimmerSpeedSlider();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEnabled = ref.watch(shimmerLoadingEnabledProvider);
    return IgnorePointer(
      ignoring: !isEnabled,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 250),
        opacity: isEnabled ? 1.0 : 0.4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      isEnabled
                          ? 'シマーアニメーション速度'
                          : 'シマーアニメーション速度 (上のスイッチを有効にすると調整可能)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isEnabled ? null : Theme.of(context).disabledColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${ref.watch(shimmerSpeedMsProvider)} ms',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Color(0xFF6366F1)),
                  ),
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
      ),
    );
  }
}

class _HapticStrengthDropdown extends ConsumerWidget {
  const _HapticStrengthDropdown();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEnabled = ref.watch(hapticFeedbackProvider);
    return IgnorePointer(
      ignoring: !isEnabled,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 250),
        opacity: isEnabled ? 1.0 : 0.4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  isEnabled
                      ? 'バイブレーション強度'
                      : 'バイブレーション強度 (上のスイッチを有効にすると調整可能)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isEnabled ? null : Theme.of(context).disabledColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              DropdownButton<HapticStrength>(
                value: ref.watch(hapticStrengthProvider),
                dropdownColor: Theme.of(context).cardColor,
                onChanged: isEnabled
                    ? (strength) {
                        if (strength != null) {
                          ref.read(hapticStrengthProvider.notifier).state =
                              strength;
                          switch (strength) {
                            case HapticStrength.light:
                              HapticFeedback.lightImpact();
                            case HapticStrength.medium:
                              HapticFeedback.mediumImpact();
                            case HapticStrength.heavy:
                              HapticFeedback.heavyImpact();
                            case HapticStrength.selection:
                              HapticFeedback.selectionClick();
                          }
                        }
                      }
                    : null,
                items: const [
                  DropdownMenuItem(
                      value: HapticStrength.light,
                      child: Text('Light (繊細)')),
                  DropdownMenuItem(
                      value: HapticStrength.medium,
                      child: Text('Medium (通常)')),
                  DropdownMenuItem(
                      value: HapticStrength.heavy,
                      child: Text('Heavy (強力)')),
                  DropdownMenuItem(
                      value: HapticStrength.selection,
                      child: Text('Selection (クリック感)')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// GitHubアカウント表示 & 接続解除タイル
class _GitHubAccountTile extends ConsumerWidget {
  const _GitHubAccountTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userInfo = ref.watch(loggedInUserProvider);
    final service = ref.read(gitHubServiceProvider);

    final login = userInfo?['login'] as String? ?? '';
    final name = userInfo?['name'] as String? ?? '';
    final avatarUrl = userInfo?['avatar_url'] as String? ?? '';

    return Column(
      children: [
        // ユーザー情報表示
        if (login.isNotEmpty)
          ListTile(
            leading: CircleAvatar(
              radius: 22,
              backgroundImage:
                  avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
              child: avatarUrl.isEmpty
                  ? const Icon(Icons.person_rounded)
                  : null,
            ),
            title: Text(
              name.isNotEmpty ? name : login,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('@$login'),
            trailing: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.circle, color: Color(0xFF10B981), size: 8),
                  SizedBox(width: 4),
                  Text(
                    '接続中',
                    style: TextStyle(
                      color: Color(0xFF10B981),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        // 接続解除ボタン
        Semantics(
          button: true,
          label: 'GitHub接続解除ボタン',
          child: ListTile(
            leading: const Icon(Icons.logout_rounded,
                color: Color(0xFFEF4444), size: 26),
            title: const Text(
              'GitHub 接続解除',
              style: TextStyle(color: Color(0xFFEF4444)),
            ),
            subtitle: const Text('現在のアカウントとの連携を解除し、ログアウトします。'),
            onTap: () {
              showDialog<void>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('連携を解除しますか？'),
                  content: const Text(
                    '接続を解除すると、リポジトリやCI/CDの実行状況が見られなくなります。',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('キャンセル'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEF4444)),
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await service.deleteToken();
                        ref.read(isLoggedInProvider.notifier).state = false;
                        ref.read(loggedInUserProvider.notifier).state = null;
                        if (context.mounted) {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute<void>(
                              builder: (_) => const LoginScreen(),
                            ),
                            (route) => false,
                          );
                        }
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
      ],
    );
  }
}
