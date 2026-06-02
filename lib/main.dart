import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_links/app_links.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'src/localization/app_localizations.dart';
import 'src/presentation/login_screen.dart';
import 'src/presentation/home_screen.dart';
import 'src/presentation/scroll_behavior.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // ステータスバーとナビゲーションバーのスタイル設定
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  runApp(
    const ProviderScope(
      child: FlowscoutApp(),
    ),
  );
}

class FlowscoutApp extends ConsumerWidget {
  const FlowscoutApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor:
            isDark ? const Color(0xFF090D16) : const Color(0xFFF8FAFC),
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarDividerColor:
            isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
      ),
      child: MaterialApp(
      title: 'Flowscout',
      debugShowCheckedModeBanner: false,
        scrollBehavior: const MyCustomScrollBehavior(),
      themeMode: themeMode,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,

      // プレミアム・ライトテーマ (WCAG 2.2 コントラスト準拠)
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.light,
          primary: const Color(0xFF4F46E5),
          onPrimary: Colors.white,
          secondary: const Color(0xFF0EA5E9),
          surface: const Color(0xFFF8FAFC),
          onSurface: const Color(0xFF0F172A),
        ),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
              color: Color(0xFF0F172A)),
          titleMedium:
              TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF334155)),
          bodyMedium: TextStyle(color: Color(0xFF475569)),
        ),
        cardTheme: const CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            side: BorderSide(color: Color(0xFFE2E8F0), width: 1),
          ),
        ),
      ),

      // プレミアム・ダークテーマ（深宇宙調）
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.dark,
          primary: const Color(0xFF818CF8),
          onPrimary: const Color(0xFF0F172A),
          secondary: const Color(0xFF38BDF8),
          surface: const Color(0xFF090D16),
          onSurface: const Color(0xFFF1F5F9),
        ),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
              color: Color(0xFFF1F5F9)),
          titleMedium:
              TextStyle(fontWeight: FontWeight.w600, color: Color(0xFFCBD5E1)),
          bodyMedium: TextStyle(color: Color(0xFF94A3B8)),
        ),
        cardTheme: const CardThemeData(
          color: Color(0xFF131B2E),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            side: BorderSide(color: Color(0xFF1E293B), width: 1),
          ),
        ),
      ),

      // 起動時のルーティング: トークンがあれば HomeScreen、なければ LoginScreen
      import 'src/presentation/scroll_behavior.dart';
    
    // Inside MaterialApp builder
    scrollBehavior: const MyCustomScrollBehavior(),
    ),);
  }
}

/// アプリ起動時にSecure Storageをチェックして適切な画面に振り分けるルーター
class _AppStartupRouter extends ConsumerStatefulWidget {
  const _AppStartupRouter();

  @override
  ConsumerState<_AppStartupRouter> createState() => _AppStartupRouterState();
}

class _AppStartupRouterState extends ConsumerState<_AppStartupRouter> {
  bool _checking = true;
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _appLinks = AppLinks();
    _checkLogin();
    _initDeepLinks();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  // ディープリンクの監視
  Future<void> _initDeepLinks() async {
    // アプリがコールドスタートした際（終了していた状態からの起動）のリンクを処理
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleDeepLink(initialUri);
      }
    } catch (e) {
      debugPrint('Error getting initial link: $e');
    }

    // アプリがメモリ上に起動している際（バックグラウンドから復帰など）のストリーム監視
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (uri) {
        _handleDeepLink(uri);
      },
      onError: (err) {
        debugPrint('Deep link stream error: $err');
      },
    );
  }

  Future<void> _handleDeepLink(Uri uri) async {
    // flowscout://oauth-callback?token=xxx の形式を解析
    if (uri.scheme == 'flowscout' && uri.host == 'oauth-callback') {
      final token = uri.queryParameters['token'];
      if (token != null && token.isNotEmpty) {
        setState(() => _checking = true);
        final service = ref.read(gitHubServiceProvider);
        final userInfo = await service.validateToken(token);
        if (userInfo != null && mounted) {
          await service.saveToken(token);
          ref.read(isLoggedInProvider.notifier).state = true;
          ref.read(loggedInUserProvider.notifier).state = userInfo;
        }
        if (mounted) {
          setState(() => _checking = false);
        }
      }
    } else if (uri.scheme == 'flowscout' && uri.host == 'setup-success') {
      // GitHub Appインストール完了後に戻ってきた場合、自動的にOAuthログインを再開する
      final url = Uri.parse('https://flowscout-oauth.tadanobutubutu.workers.dev/login');
      try {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } catch (e) {
        debugPrint('Error launching oauth flow after installation: $e');
      }
    }
  }

  Future<void> _checkLogin() async {
    final service = ref.read(gitHubServiceProvider);
    final token = await service.getToken();
    if (token != null && token.isNotEmpty) {
      // トークンがある場合は検証してユーザー情報を取得
      final userInfo = await service.getCurrentUser();
      if (userInfo != null) {
        ref.read(isLoggedInProvider.notifier).state = true;
        ref.read(loggedInUserProvider.notifier).state = userInfo;
      } else {
        // トークンが無効な場合は削除
        await service.deleteToken();
      }
    }
    if (mounted) {
      setState(() => _checking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      // スプラッシュ的なローディング画面
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF0EA5E9)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/app_icon.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.hub_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const CircularProgressIndicator(
                color: Color(0xFF6366F1),
                strokeWidth: 2,
              ),
            ],
          ),
        ),
      );
    }

    final isLoggedIn = ref.watch(isLoggedInProvider);
    return isLoggedIn ? const HomeScreen() : const LoginScreen();
  }
}

// テーマ管理用
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);
