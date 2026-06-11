import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'premium_widgets.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import '../domain/github_service.dart';
import '../localization/app_localizations.dart';

// アップデート通知設定を保持するStateProvider
final updateNotifyEnabledProvider = StateProvider<bool>((ref) => true);

// 「高度な設定（アドバンス項目）」の表示状態を管理するStateProvider
final showAdvancedSettingsProvider = StateProvider<bool>((ref) => false);

// アクティブユーザー名を監視するProvider
final activeUserProvider = FutureProvider<String?>((ref) async {
  final service = ref.watch(gitHubServiceProvider);
  return await service.getActiveUser();
});

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifyEnabled = ref.watch(updateNotifyEnabledProvider);
    final isLowSpec = ref.watch(lowSpecModeProvider);
    final l10n = AppLocalizations.of(context)!;

    String getLocaleLabel(Locale? locale) {
      if (locale == null) {
        return l10n.systemDefault;
      }
      switch (locale.languageCode) {
        case 'de':
          return 'Deutsch';
        case 'en':
          return 'English';
        case 'es':
          return 'Español';
        case 'fr':
          return 'Français';
        case 'ja':
          return '日本語';
        case 'ko':
          return '한국어';
        case 'zh':
          return '中文';
        default:
          return locale.languageCode;
      }
    }

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
        title: Text(l10n.settingsTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          // --------------------------------------------------
          // セクション：言語設定
          // --------------------------------------------------
          _buildSectionHeader(context, l10n.languageSettings),
          ListTile(
            leading: const Icon(Icons.language_rounded, color: Color(0xFF6366F1)),
            title: Text(l10n.displayLanguage),
            trailing: DropdownButton<Locale?>(
              value: ref.watch(localOverrideProvider),
              dropdownColor: Theme.of(context).cardColor,
              underline: const SizedBox(),
              items: [
                DropdownMenuItem(
                  value: null,
                  child: Text(l10n.systemDefault),
                ),
                ...AppLocalizations.supportedLocales.map((locale) {
                  return DropdownMenuItem(
                    value: locale,
                    child: Text(getLocaleLabel(locale)),
                  );
                }),
              ],
              onChanged: (locale) {
                ref.read(localOverrideProvider.notifier).state = locale;
              },
            ),
          ),
          const Divider(),

          // --------------------------------------------------
          // セクション：省電力 & パフォーマンス (基本項目)
          // --------------------------------------------------
          _buildSectionHeader(context, l10n.powerPerformance),
          SwitchListTile(
            title: Text(l10n.lowSpecMode),
            subtitle: Text(l10n.lowSpecModeDesc),
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
              title: Text(l10n.springAnimation),
              subtitle: Text(l10n.springAnimationDesc),
              value: ref.watch(springAnimationEnabledProvider),
              activeTrackColor: const Color(0xFF6366F1),
              onChanged: (value) {
                ref.read(springAnimationEnabledProvider.notifier).state = value;
              },
            ),

            const Divider(indent: 16, endIndent: 16),
            // シマーローディング（基本項目: ON/OFF）
            SwitchListTile(
              title: Text(l10n.shimmerLoading),
              subtitle: Text(l10n.shimmerLoadingDesc),
              value: ref.watch(shimmerLoadingEnabledProvider),
              activeTrackColor: const Color(0xFF6366F1),
              onChanged: (value) {
                ref.read(shimmerLoadingEnabledProvider.notifier).state = value;
              },
            ),

            const Divider(indent: 16, endIndent: 16),
            // リスト出現アニメーション（基本項目: ON/OFF）
            SwitchListTile(
              title: Text(l10n.listEntranceAnimation),
              subtitle: Text(l10n.listEntranceAnimationDesc),
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
          _buildSectionHeader(context, l10n.hapticsTouch),
          SwitchListTile(
            title: Text(l10n.hapticsFeedback),
            subtitle: Text(l10n.hapticsFeedbackDesc),
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
              title: Text(
                l10n.advancedTuning,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(l10n.advancedTuningDesc),
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
          _buildSectionHeader(context, l10n.notificationsUpdates),
          SwitchListTile(
            title: Text(l10n.updateCheckNotify),
            subtitle: Text(l10n.updateCheckNotifyDesc),
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
          _buildSectionHeader(context, l10n.githubIntegration),
          const _GitHubAccountTile(),

          ListTile(
            leading: const Icon(Icons.add_circle_outline_rounded, color: Color(0xFF6366F1)),
            title: Text(l10n.addNewAccount),
            subtitle: Text(
              l10n.addNewAccountDesc,
              style: const TextStyle(fontSize: 12),
            ),
            trailing: const Icon(Icons.open_in_new_rounded),
            onTap: () async {
              final url = Uri.parse('https://flowscout-oauth.tadanobutubutu.workers.dev/login');
              try {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              } catch (e) {
                debugPrint('Error launching url: $e');
              }
            },
          ),
          const Divider(),

          ListTile(
            leading: const Icon(Icons.person_add_alt_1_rounded, color: Color(0xFF6366F1)),
            title: Text(l10n.manageAccounts),
            subtitle: Text(l10n.manageAccountsDesc),
            trailing: const Icon(Icons.open_in_new_rounded),
            onTap: () async {
              final url = Uri.parse('https://github.com/apps/flowscout-monitor/installations/new');
              try {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              } catch (e) {
                debugPrint('Error launching url: $e');
              }
            },
          ),
          const Divider(),

          // --------------------------------------------------
          // セクション：デンジャーゾーン
          // --------------------------------------------------
          _buildSectionHeader(context, l10n.dangerZone, isDanger: true),
          const _DangerZoneTile(),
          const Divider(),

          _buildSectionHeader(context, l10n.aboutApp),
          const ListTile(
            leading: Icon(Icons.info_outline_rounded),
            title: Text('Flowscout'),
            subtitle: Text('Version 1.0.0 (Build 1)'),
          ),
          ListTile(
            leading: const Icon(Icons.accessibility_new_rounded),
            title: Text(l10n.accessibilitySupport),
            subtitle: Text(l10n.accessibilitySupportDesc),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, {bool isDanger = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: isDanger ? const Color(0xFFEF4444) : const Color(0xFF6366F1),
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
                          ? AppLocalizations.of(context)!.springScaleFactor
                          : AppLocalizations.of(context)!.springScaleFactorDisabled,
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
                          ? AppLocalizations.of(context)!.shimmerSpeed
                          : AppLocalizations.of(context)!.shimmerSpeedDisabled,
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
                      ? AppLocalizations.of(context)!.vibrationStrength
                      : AppLocalizations.of(context)!.vibrationStrengthDisabled,
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
                items: [
                  DropdownMenuItem(
                      value: HapticStrength.light,
                      child: Text(AppLocalizations.of(context)!.hapticLight)),
                  DropdownMenuItem(
                      value: HapticStrength.medium,
                      child: Text(AppLocalizations.of(context)!.hapticMedium)),
                  DropdownMenuItem(
                      value: HapticStrength.heavy,
                      child: Text(AppLocalizations.of(context)!.hapticHeavy)),
                  DropdownMenuItem(
                      value: HapticStrength.selection,
                      child: Text(AppLocalizations.of(context)!.hapticSelection)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// GitHubアカウント表示タイル (マルチアカウント対応)
class _GitHubAccountTile extends ConsumerWidget {
  const _GitHubAccountTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.read(gitHubServiceProvider);
    final activeUserAsync = ref.watch(activeUserProvider);
    final isGuestMode = ref.watch(isGuestModeProvider);
    final l10n = AppLocalizations.of(context)!;

    if (isGuestMode) {
      return ListTile(
        leading: const Icon(Icons.face_retouching_natural_rounded, color: Color(0xFF6366F1)),
        title: Text(l10n.guestModeActive),
        subtitle: Text(l10n.guestModeDesc),
      );
    }

    return FutureBuilder<List<String>>(
      future: service.getRegisteredUsers(),
      builder: (context, snapshot) {
        final users = snapshot.data ?? [];
        if (users.isEmpty) {
          return ListTile(
            leading: const Icon(Icons.person_off_rounded),
            title: Text(l10n.noAccountRegistered),
          );
        }

        return Column(
          children: users.map((username) {
            final isActive = username == activeUserAsync.value;
            return ListTile(
              leading: CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(
                  'https://github.com/$username.png?size=80',
                ),
                onBackgroundImageError: (_, __) {},
                child: null,
              ),
              title: Text(
                '@$username',
                style: TextStyle(
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              subtitle: Text(isActive ? l10n.currentlyActive : l10n.tapToSwitch),
              trailing: isActive
                  ? const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981))
                  : null,
              onTap: isActive
                  ? null
                  : () async {
                      await service.setActiveUser(username);
                      // キャッシュクリアして状態更新
                      ref.invalidate(activeUserProvider);
                      ref.invalidate(repositoriesProvider);
                      ref.invalidate(allRawRepositoriesProvider);
                      
                      // loggedInUserProvider も同期更新
                      final userInfo = await service.getCurrentUser();
                      ref.read(loggedInUserProvider.notifier).state = userInfo;
                    },
            );
          }).toList(),
        );
      },
    );
  }
}

/// 危険な操作を行うデンジャーゾーンのタイル (マルチアカウント対応)
class _DangerZoneTile extends ConsumerWidget {
  const _DangerZoneTile();

  Future<void> _confirmDisconnect(
    BuildContext context,
    WidgetRef ref,
    GitHubService service, {
    required bool all,
  }) async {
    final activeUser = await service.getActiveUser();
    if (!context.mounted) return;
    final l10n = AppLocalizations.of(context)!;

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(all ? l10n.confirmDisconnectAllTitle : l10n.confirmDisconnectTitle),
        content: Text(
          all
              ? l10n.confirmDisconnectAllDesc
              : l10n.confirmDisconnectDesc(activeUser ?? ''),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444)),
            onPressed: () async {
              Navigator.pop(ctx);
              if (all) {
                await service.deleteAllTokens();
              } else if (activeUser != null) {
                await service.deleteUserToken(activeUser);
              }

              // アクティブなアカウントが他にあるかチェック
              final nextActive = await service.getActiveUser();
              if (nextActive != null) {
                // 切り替え
                ref.invalidate(activeUserProvider);
                ref.invalidate(repositoriesProvider);
                ref.invalidate(allRawRepositoriesProvider);
                final userInfo = await service.getCurrentUser();
                ref.read(loggedInUserProvider.notifier).state = userInfo;
              } else {
                // すべて削除された場合はログイン画面へ
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
              }
            },
            child: Text(l10n.disconnect,
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.read<GitHubService>(gitHubServiceProvider);
    final isGuestMode = ref.watch(isGuestModeProvider);
    final l10n = AppLocalizations.of(context)!;

    if (isGuestMode) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1).withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF6366F1).withValues(alpha: 0.3), width: 1.5),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: const Icon(Icons.login_rounded, color: Color(0xFF6366F1), size: 26),
            title: Text(
              l10n.endGuestMode,
              style: const TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.bold),
            ),
            subtitle: Text(l10n.endGuestModeDesc),
            onTap: () {
              ref.read(isLoggedInProvider.notifier).state = false;
              ref.read(isGuestModeProvider.notifier).state = false;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444).withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.3), width: 1.5),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Theme(
            data: Theme.of(context).copyWith(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
            child: Column(
              children: [
                Semantics(
                  button: true,
                  label: '現在のアカウントの接続解除ボタン',
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: const Icon(Icons.logout_rounded,
                        color: Color(0xFFEF4444), size: 26),
                    title: Text(
                      l10n.disconnectCurrent,
                      style: const TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(l10n.disconnectCurrentDesc),
                    onTap: () => _confirmDisconnect(context, ref, service, all: false),
                  ),
                ),
                const Divider(height: 1, color: Color(0x22EF4444)),
                Semantics(
                  button: true,
                  label: 'すべてのアカウントの接続解除ボタン',
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: const Icon(Icons.delete_forever_rounded,
                        color: Color(0xFFEF4444), size: 26),
                    title: Text(
                      l10n.logoutAll,
                      style: const TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(l10n.logoutAllDesc),
                    onTap: () => _confirmDisconnect(context, ref, service, all: true),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

