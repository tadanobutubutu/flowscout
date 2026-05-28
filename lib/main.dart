import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/presentation/home_screen.dart';

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
    // テーマ切り替えプロバイダ (初期値はダークモードを推奨)
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Flowscout',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,

      // プレミアム・ライトテーマ (WCAG 2.2 コントラスト準拠)
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1), // インディゴ/バイオレット調
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

      // プレミアム・ダークテーマ (ガラスモルフィズム、深宇宙調)
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.dark,
          primary: const Color(0xFF818CF8),
          onPrimary: const Color(0xFF0F172A),
          secondary: const Color(0xFF38BDF8),
          surface: const Color(0xFF090D16), // 深いネイビーブラック
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
          color: Color(0xFF131B2E), // 美しい半透明調のベースとなるダークカード
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            side: BorderSide(color: Color(0xFF1E293B), width: 1),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

// テーマ管理用のシンプルなStateProvider
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);
