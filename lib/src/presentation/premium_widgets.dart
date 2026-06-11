import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ----------------------------------------------------
// 1. 省電力・パフォーマンス設定プロバイダー
// ----------------------------------------------------
/// 低スペック優先モード（一括で重い演出をオフにする設定）
final lowSpecModeProvider = StateProvider<bool>((ref) => false);

/// 物理演算スプリングアニメーションの有効状態
final springAnimationEnabledProvider = StateProvider<bool>((ref) => true);

/// 弾む際の縮小スケールファクター (0.90倍 〜 0.98倍 など)
final springScaleFactorProvider = StateProvider<double>((ref) => 0.95);

/// シマー（Shimmer）ローディングのアニメーション有効状態
final shimmerLoadingEnabledProvider = StateProvider<bool>((ref) => true);

/// シマーのループアニメーション速度（ミリ秒）
final shimmerSpeedMsProvider = StateProvider<int>((ref) => 1500);

// ----------------------------------------------------
// 2. ハプティクス（触感）設定プロバイダー
// ----------------------------------------------------
/// ハプティクス全体の有効状態
final hapticFeedbackProvider = StateProvider<bool>((ref) => true);

/// ハプティクスフィードバックの強さ（ライト, ミディアム, ヘビー, セレクション）
enum HapticStrength {
  light,
  medium,
  heavy,
  selection,
}
final hapticStrengthProvider = StateProvider<HapticStrength>((ref) => HapticStrength.light);

// ----------------------------------------------------
// 3. アニメーション演出設定プロバイダー
// ----------------------------------------------------
/// リスト表示時のフェードイン＆スライドアップ演出の有効状態 (控えめなアニメーション)
final listEntranceAnimationEnabledProvider = StateProvider<bool>((ref) => true);

/// アニメーション開始遅延（マウント直後のジャンプ抑制：Skip Entering 制御用）
final skipFirstFrameRenderProvider = StateProvider<bool>((ref) => true);

// ----------------------------------------------------
// 5. 言語設定プロバイダー
// ----------------------------------------------------
/// ユーザーが明示的に選択した言語（nullなら端末のシステム言語を自動使用）
final localOverrideProvider = StateProvider<Locale?>((ref) => null);


// ----------------------------------------------------
// 4. カスタム UI コンポーネント
// ----------------------------------------------------

/// 1. 弾むような極上物理演算ボタンコンポーネント (Spring Button)
class PremiumSpringButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final bool enableHaptics;

  const PremiumSpringButton({
    super.key,
    required this.child,
    required this.onTap,
    this.enableHaptics = true,
  });

  @override
  State<PremiumSpringButton> createState() => _PremiumSpringButtonState();
}

class _PremiumSpringButtonState extends State<PremiumSpringButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details, WidgetRef ref) {
    final isLowSpec = ref.read(lowSpecModeProvider);
    final springEnabled = ref.read(springAnimationEnabledProvider);
    if (isLowSpec || !springEnabled) return;

    // スケールアニメーションの目標値をカスタムパラメータから動的に適用
    final targetScale = ref.read(springScaleFactorProvider);
    _scaleAnimation = Tween<double>(begin: 1.0, end: targetScale).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward();
  }

  // Removed _handleTapUp as its logic is now split between onTapUp and onTap in the builder

  void _handleTapCancel(WidgetRef ref) {
    final isLowSpec = ref.read(lowSpecModeProvider);
    final springEnabled = ref.read(springAnimationEnabledProvider);
    if (isLowSpec || !springEnabled) return;
    _controller.reverse();
  }

  void _triggerFeedbackAndTap(WidgetRef ref) {
    final hapticEnabled = ref.read(hapticFeedbackProvider);
    if (widget.enableHaptics && hapticEnabled) {
      final strength = ref.read(hapticStrengthProvider);
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
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final isLowSpec = ref.watch(lowSpecModeProvider);
        final springEnabled = ref.watch(springAnimationEnabledProvider);

        if (isLowSpec || !springEnabled) {
          return GestureDetector(
            onTap: () => _triggerFeedbackAndTap(ref),
            behavior: HitTestBehavior.opaque,
            child: widget.child,
          );
        }

        return GestureDetector(
          onTapDown: (details) => _handleTapDown(details, ref),
          onTapUp: (details) {
            final isLowSpec = ref.read(lowSpecModeProvider);
            final springEnabled = ref.read(springAnimationEnabledProvider);
            if (!isLowSpec && springEnabled) {
              _controller.reverse();
            }
          },
          onTap: () => _triggerFeedbackAndTap(ref),
          onTapCancel: () => _handleTapCancel(ref),
          behavior: HitTestBehavior.opaque,
          child: RepaintBoundary(
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}

/// 2. キラキラと光るシマー（Shimmer）ローディングプレースホルダー
class PremiumShimmerContainer extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const PremiumShimmerContainer({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 12.0,
  });

  @override
  State<PremiumShimmerContainer> createState() => _PremiumShimmerContainerState();
}

class _PremiumShimmerContainerState extends State<PremiumShimmerContainer> with SingleTickerProviderStateMixin {
  AnimationController? _shimmerController;

  void _initControllerIfNeeded(bool enabled) {
    if (enabled && _shimmerController == null) {
      _shimmerController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1500),
      )..repeat();
    } else if (!enabled && _shimmerController != null) {
      _shimmerController!.dispose();
      _shimmerController = null;
    }
  }

  @override
  void dispose() {
    _shimmerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final highlightColor = isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);

    return Consumer(
      builder: (context, ref, child) {
        final isLowSpec = ref.watch(lowSpecModeProvider);
        final shimmerEnabled = ref.watch(shimmerLoadingEnabledProvider);
        final shouldAnimate = !isLowSpec && shimmerEnabled;

        _initControllerIfNeeded(shouldAnimate);

        // 低スペックまたはシマー無効時はアニメーションなしのフラットなスケルトンを表示 (コントローラーは完全停止)
        if (!shouldAnimate || _shimmerController == null) {
          return Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
          );
        }

        // アニメーション速度をカスタム速度設定から同期
        final speedMs = ref.watch(shimmerSpeedMsProvider);
        if (_shimmerController!.duration?.inMilliseconds != speedMs) {
          _shimmerController!.duration = Duration(milliseconds: speedMs);
          if (!_shimmerController!.isAnimating) {
            _shimmerController!.repeat();
          }
        }

        return RepaintBoundary(
          child: AnimatedBuilder(
            animation: _shimmerController!,
            builder: (context, child) {
              return Container(
                width: widget.width,
                height: widget.height,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      baseColor,
                      highlightColor,
                      baseColor,
                    ],
                    stops: [
                      _shimmerController!.value - 0.3,
                      _shimmerController!.value,
                      _shimmerController!.value + 0.3,
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
