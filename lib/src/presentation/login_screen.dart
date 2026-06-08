import 'dart:async';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'home_screen.dart';

// ログイン状態のグローバル管理（アプリ全体で使用）
final isLoggedInProvider = StateProvider<bool>((ref) => false);
final loggedInUserProvider = StateProvider<Map<String, dynamic>?>((ref) => null);
final isGuestModeProvider = StateProvider<bool>((ref) => false);

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _tokenController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscureToken = true;
  String? _errorMessage;

  Timer? _pollingTimer;
  bool _showPatOption = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    _animController.forward();
  }

  @override
  void dispose() {
    _tokenController.dispose();
    _animController.dispose();
    _pollingTimer?.cancel();
    super.dispose();
  }

  // OAuthログイン（Web Application Flow）の開始
  Future<void> _startOAuthFlow() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final url = Uri.parse('https://flowscout-oauth.tadanobutubutu.workers.dev/login');
    try {
      // Android 11以降の package visibility 制限などで canLaunchUrl が false を返すことがあるため、
      // 直接 launchUrl を実行して成否を確認します。
      final launched = await launchUrl(url);
      if (!launched) {
        setState(() {
          _isLoading = false;
          _errorMessage = '認証ページを開くことができませんでした。';
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = '認証ページを開く際にエラーが発生しました: $e';
      });
    }
  }

  // PATログイン
  Future<void> _loginWithPat() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final service = ref.read(gitHubServiceProvider);
    final token = _tokenController.text.trim();
    final userInfo = await service.validateToken(token);

    if (!mounted) return;

    if (userInfo != null) {
      await service.saveToken(token);
      if (!mounted) return;
      ref.read(isLoggedInProvider.notifier).state = true;
      ref.read(loggedInUserProvider.notifier).state = userInfo;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = 'トークンが無効です。正しいPersonal Access Tokenを入力してください。';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,

      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 32),

                  // ── ロゴ・ヘッダー ──
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF0EA5E9)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withValues(alpha: 0.35),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.asset(
                        'assets/app_icon.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.hub_rounded,
                          color: Colors.white,
                          size: 44,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF0EA5E9)],
                    ).createShader(bounds),
                    child: const Text(
                      'Flowscout',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Outfit',
                        color: Colors.white,
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'GitHub CI/CDモニタリングアプリ',
                    style: TextStyle(
                      fontSize: 15,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                  const SizedBox(height: 44),

                  // ── エラーメッセージ表示 ──
                  if (_errorMessage != null) ...[
                    Semantics(
                      liveRegion: true,
                      label: _errorMessage,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFEF4444).withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline_rounded,
                                color: Color(0xFFEF4444), size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  color: Color(0xFFEF4444),
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // ── メイン: GitHub App OAuth 連携 ──
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _startOAuthFlow,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.login_rounded, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'GitHub Appで連携する',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'GitHub App を使用して安全かつ迅速に連携できます。',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).hintColor,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 48),

                  // ── PAT オプション (アコーディオン) ──
                  Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      initiallyExpanded: _showPatOption,
                      onExpansionChanged: (expanded) {
                        setState(() => _showPatOption = expanded);
                      },
                      title: Center(
                        child: Text(
                          'または Personal Access Token で接続',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).hintColor,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      children: [
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              const SizedBox(height: 16),
                              _buildInfoCard(isDark),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: _tokenController,
                                obscureText: _obscureToken,
                                autocorrect: false,
                                enableSuggestions: false,
                                keyboardType: TextInputType.visiblePassword,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 14,
                                  letterSpacing: 0.5,
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Personal Access Token',
                                  hintText: 'ghp_xxxxxxxxxxxxxxxxxxxx',
                                  prefixIcon: const Icon(
                                    Icons.key_rounded,
                                    color: Color(0xFF6366F1),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureToken
                                          ? Icons.visibility_off_rounded
                                          : Icons.visibility_rounded,
                                      color: Theme.of(context).hintColor,
                                    ),
                                    onPressed: () {
                                      setState(() => _obscureToken = !_obscureToken);
                                    },
                                  ),
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
                                    borderSide: const BorderSide(
                                      color: Color(0xFF6366F1),
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'トークンを入力してください';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _loginWithPat,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey.shade800,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text('PATで接続する'),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextButton.icon(
                                onPressed: () async {
                                  final url = Uri.parse(
                                    'https://github.com/settings/tokens/new?scopes=repo,read:user,workflow&description=Flowscout+App',
                                  );
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(url);
                                  }
                                },
                                icon: const Icon(Icons.open_in_new_rounded, size: 14,
                                    color: Color(0xFF6366F1)),
                                label: const Text(
                                  'GitHubでトークンを発行する',
                                  style: TextStyle(color: Color(0xFF6366F1), fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── ゲストモードのスキップボタン ──
                  TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Row(
                              children: [
                                Icon(Icons.warning_amber_rounded, color: Colors.orange),
                                SizedBox(width: 8),
                                Text('ゲストモードの注意'),
                              ],
                            ),
                            content: const Text(
                              'ゲストモードではAPIの取得回数に厳しい制限（1時間に約60回）があります。\n\nそのため、短時間に何度も画面を開いたり更新したりすると、「取得失敗」などのエラーが表示される場合があります。\n\nすべての機能を制限なく利用するには、ログインしてご利用いただくことを推奨します。',
                              style: TextStyle(fontSize: 14),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('キャンセル'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  ref.read(isGuestModeProvider.notifier).state = true;
                                  ref.read(isLoggedInProvider.notifier).state = true;
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
                                    (route) => false,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).colorScheme.primary,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('同意して進む'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Text(
                      'ログインせずにスキップ (ゲストモード)',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF131B2E)
            : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF6366F1).withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline_rounded,
                  color: Color(0xFF6366F1), size: 18),
              const SizedBox(width: 8),
              Text(
                'Personal Access Tokenとは',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isDark
                      ? const Color(0xFFF1F5F9)
                      : const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildInfoRow('GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)'),
          const SizedBox(height: 6),
          _buildInfoRow('「Generate new token (classic)」をクリック'),
          const SizedBox(height: 6),
          _buildInfoRow('スコープ: repo, read:user, workflow にチェックを入れる'),
          const SizedBox(height: 6),
          _buildInfoRow('生成されたトークン（ghp_...）を入力欄に入力します。'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check_circle_outline_rounded,
            color: Color(0xFF10B981), size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).hintColor,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
