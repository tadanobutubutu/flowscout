import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'home_screen.dart'; // gitHubServiceProvider をインポートするため

class JobLogScreen extends ConsumerStatefulWidget {
  final String repoFullName;
  final int jobId;
  final String jobName;
  final String? highlightKeyword; // エラー表示時に自動でスクロール/ハイライトするためのキーワード

  const JobLogScreen({
    super.key,
    required this.repoFullName,
    required this.jobId,
    required this.jobName,
    this.highlightKeyword,
  });

  @override
  ConsumerState<JobLogScreen> createState() => _JobLogScreenState();
}

class _JobLogScreenState extends ConsumerState<JobLogScreen> {
  bool _isLoading = true;
  String? _logContent;
  String? _errorMessage;
  final List<String> _logLines = [];
  final List<int> _matchedLineIndices = [];
  int _currentMatchIndex = -1;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _fetchLog();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _fetchLog() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final service = ref.read(gitHubServiceProvider);
    final log = await service.getJobLog(widget.repoFullName, widget.jobId);

    if (!mounted) return;

    if (log != null) {
      // ログを行ごとに分割
      final lines = log.split('\n');
      setState(() {
        _logContent = log;
        _logLines.addAll(lines);
        _isLoading = false;
      });

      // エラーキーワード指定がある場合は自動で検索を走らせる
      if (widget.highlightKeyword != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _searchController.text = widget.highlightKeyword!;
          _performSearch(widget.highlightKeyword!);
        });
      }
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = 'ログの取得に失敗しました。時間をおいて再度お試しください。';
      });
    }
  }

  // 検索処理 (ステップ開始グループ等を優先検出するスマートサーチ)
  void _performSearch(String query) {
    _matchedLineIndices.clear();
    if (query.trim().isEmpty) {
      setState(() {
        _currentMatchIndex = -1;
      });
      return;
    }

    final lowercaseQuery = query.toLowerCase();
    int? bestMatchIndex;

    for (int i = 0; i < _logLines.length; i++) {
      final line = _logLines[i].toLowerCase();
      if (line.contains(lowercaseQuery)) {
        _matchedLineIndices.add(i);

        // GitHub Actionsのログにおいて、ステップ開始を示すグループマーカー（##[group] や starting:）がある行を優先
        if (bestMatchIndex == null &&
            (line.contains('##[group]') ||
             line.contains('starting:') ||
             line.contains('run '))) {
          bestMatchIndex = _matchedLineIndices.length - 1;
        }
      }
    }

    setState(() {
      if (_matchedLineIndices.isNotEmpty) {
        // グループ開始行が検出できればそこへ、無ければ最初のマッチ行へスクロール
        _currentMatchIndex = bestMatchIndex ?? 0;
        _scrollToLine(_matchedLineIndices[_currentMatchIndex]);
      } else {
        _currentMatchIndex = -1;
      }
    });
  }

  // 指定行へスクロール
  void _scrollToLine(int lineIndex) {
    // 1行あたりのおおよその高さを20.0として計算
    const double estimateLineHeight = 22.0;
    final double targetOffset = (lineIndex * estimateLineHeight) - 100.0;
    _scrollController.animateTo(
      targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  void _nextMatch() {
    if (_matchedLineIndices.isEmpty) return;
    setState(() {
      _currentMatchIndex = (_currentMatchIndex + 1) % _matchedLineIndices.length;
      _scrollToLine(_matchedLineIndices[_currentMatchIndex]);
    });
  }

  void _prevMatch() {
    if (_matchedLineIndices.isEmpty) return;
    setState(() {
      _currentMatchIndex =
          (_currentMatchIndex - 1 + _matchedLineIndices.length) %
              _matchedLineIndices.length;
      _scrollToLine(_matchedLineIndices[_currentMatchIndex]);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF090D16) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                style: const TextStyle(fontSize: 16),
                decoration: const InputDecoration(
                  hintText: 'ログ内を検索...',
                  border: InputBorder.none,
                ),
                onChanged: _performSearch,
              )
            : Text(
                widget.jobName,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
        actions: [
          if (_isSearching) ...[
            if (_matchedLineIndices.isNotEmpty) ...[
              Center(
                child: Text(
                  '${_currentMatchIndex + 1}/${_matchedLineIndices.length}',
                  style: TextStyle(color: Theme.of(context).hintColor, fontSize: 13),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.keyboard_arrow_up_rounded),
                onPressed: _prevMatch,
              ),
              IconButton(
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                onPressed: _nextMatch,
              ),
            ],
            IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () {
                setState(() {
                  _isSearching = false;
                  _searchController.clear();
                  _matchedLineIndices.clear();
                  _currentMatchIndex = -1;
                });
              },
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.search_rounded),
              onPressed: () {
                setState(() {
                  _isSearching = true;
                  _searchFocusNode.requestFocus();
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: _fetchLog,
            ),
          ],
        ],
      ),
      body: SafeArea(
        child: _buildBody(isDark),
      ),
    );
  }

  Widget _buildBody(bool isDark) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(strokeWidth: 3),
            SizedBox(height: 16),
            Text('ログをダウンロード中...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(_errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _fetchLog,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('再試行'),
              ),
            ],
          ),
        ),
      );
    }

    if (_logLines.isEmpty) {
      return const Center(
        child: Text('ログデータがありません'),
      );
    }

    // 等幅フォントでのログ描画。cacheExtentを大きめにしてスムーズにする
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1),
        ),
      ),
      child: ListView.builder(
        controller: _scrollController,
        itemCount: _logLines.length,
        cacheExtent: 600,
        itemBuilder: (context, index) {
          final line = _logLines[index];
          final isHighlighted = _matchedLineIndices.contains(index) &&
              _matchedLineIndices[_currentMatchIndex] == index;

          // エラー行の簡易ハイライト
          final isGitHubError = line.contains('##[error]') || line.toLowerCase().contains('error');

          Color textColor = isDark ? const Color(0xFFCBD5E1) : const Color(0xFF1E293B);
          if (isGitHubError) {
            textColor = Colors.redAccent.shade200;
          }

          return Container(
            color: isHighlighted
                ? Colors.amber.withValues(alpha: 0.3)
                : Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 行番号
                SizedBox(
                  width: 38,
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: Theme.of(context).hintColor.withValues(alpha: 0.6),
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(width: 12),
                // ログ本文
                Expanded(
                  child: Text(
                    line,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: textColor,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
