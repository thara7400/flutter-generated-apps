import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'みずのみメモ',
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

// ─── ホーム画面 ───────────────────────────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _count = 0;
  SharedPreferences? _prefs;
  bool _isLoading = true;

  String get _todayKey {
    final now = DateTime.now();
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return '${now.year}-$m-$d';
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _prefs = prefs;
      _count = prefs.getInt(_todayKey) ?? 0;
      _isLoading = false;
    });
  }

  Future<void> _increment() async {
    final newCount = _count + 1;
    await _prefs!.setInt(_todayKey, newCount);
    if (!mounted) return;
    setState(() => _count = newCount);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('みずのみメモ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: '記録一覧',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryScreen()),
              );
              // 戻ってきたとき日付が変わっていても正しく再読込する
              _load();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('今日の杯数', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 24),
                  Text(
                    '$_count',
                    style: theme.textTheme.displayLarge?.copyWith(
                      fontSize: 112,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  Text('杯', style: theme.textTheme.headlineMedium),
                  const SizedBox(height: 56),
                  FilledButton.icon(
                    onPressed: _increment,
                    icon: const Icon(Icons.local_drink, size: 28),
                    label: const Text('コップ 1 杯 のんだ！'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 36, vertical: 18),
                      textStyle: theme.textTheme.titleLarge,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

// ─── 記録一覧画面 ─────────────────────────────────────────────────────────────

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<MapEntry<String, int>> _records = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final datePattern = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    final sorted = prefs.getKeys().where(datePattern.hasMatch).toList()
      ..sort((a, b) => b.compareTo(a)); // 新しい日付が上
    final records =
        sorted.map((k) => MapEntry(k, prefs.getInt(k) ?? 0)).toList();
    if (!mounted) return;
    setState(() {
      _records = records;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('記録一覧')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _records.isEmpty
              ? const Center(child: Text('まだ記録がありません'))
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _records.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final entry = _records[index];
                    return ListTile(
                      leading: Icon(Icons.water_drop,
                          color: theme.colorScheme.primary),
                      title: Text(entry.key,
                          style: theme.textTheme.bodyLarge),
                      trailing: Text(
                        '${entry.value} 杯',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
