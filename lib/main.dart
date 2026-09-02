import 'dart:async';
import 'dart:math';

import 'package:flip_card_plus/flip_card_plus.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'かんたん神経衰弱DX',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const StartScreen(),
    );
  }
}

// ==================== Start Screen ====================

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.primaryContainer,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'かんたん神経衰弱DX',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: cs.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 64),
            FilledButton(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 16,
                ),
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GameScreen()),
              ),
              child: const Text('はじめる', style: TextStyle(fontSize: 22)),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== Game Screen ====================

const _kEmojis = ['🐶', '🐱', '🐭', '🐹', '🐰', '🦊', '🐻', '🐼'];
const _kPairCount = 8;
const _kCardCount = _kPairCount * 2;

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late List<String> _values;
  late List<bool> _matched;
  late List<AnimationController> _flipCtrls;

  final _faceUp = <int>[];
  bool _blocked = false;
  int _matchedPairs = 0;

  late Stopwatch _stopwatch;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _flipCtrls = List.generate(
      _kCardCount,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      ),
    );
    _startGame();
  }

  void _startGame() {
    final pool = [..._kEmojis, ..._kEmojis]..shuffle(Random());
    _values = pool;
    _matched = List.filled(_kCardCount, false);
    for (final c in _flipCtrls) {
      c.reset();
    }
    _faceUp.clear();
    _blocked = false;
    _matchedPairs = 0;
    _stopwatch = Stopwatch()..start();
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    for (final c in _flipCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  void _onTap(int i) {
    if (_blocked) return;
    if (_matched[i]) return;
    if (_faceUp.contains(i)) return;
    if (_faceUp.length >= 2) return;

    _flipCtrls[i].forward();
    setState(() => _faceUp.add(i));

    if (_faceUp.length < 2) return;

    _blocked = true;
    final a = _faceUp[0];
    final b = _faceUp[1];

    if (_values[a] == _values[b]) {
      // マッチ
      setState(() {
        _matched[a] = true;
        _matched[b] = true;
        _matchedPairs++;
        _faceUp.clear();
        _blocked = false;
      });
      if (_matchedPairs == _kPairCount) {
        _stopwatch.stop();
        _ticker?.cancel();
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) _showClear();
        });
      }
    } else {
      // ミスマッチ → 1 秒後に裏返す
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (!mounted) return;
        _flipCtrls[a].reverse();
        _flipCtrls[b].reverse();
        setState(() {
          _faceUp.clear();
          _blocked = false;
        });
      });
    }
  }

  void _showClear() {
    final e = _stopwatch.elapsed;
    final mm = e.inMinutes.toString().padLeft(2, '0');
    final ss = (e.inSeconds % 60).toString().padLeft(2, '0');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('🎉 クリア！'),
        content: Text('タイム: $mm:$ss\nペア数: $_matchedPairs / $_kPairCount'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // ダイアログを閉じる
              Navigator.of(context).pop(); // スタート画面へ戻る
            },
            child: const Text('スタートにもどる'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop(); // ダイアログを閉じる
              setState(_startGame);
            },
            child: const Text('もう一度'),
          ),
        ],
      ),
    );
  }

  String get _timeStr {
    final e = _stopwatch.elapsed;
    final mm = e.inMinutes.toString().padLeft(2, '0');
    final ss = (e.inSeconds % 60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: cs.primaryContainer,
        title: Text('ペア: $_matchedPairs / $_kPairCount　⏱ $_timeStr'),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            const cols = 4;
            const rows = _kCardCount ~/ cols; // 4
            const spacing = 12.0;
            const padding = 12.0;
            final cardW =
                (constraints.maxWidth - 2 * padding - (cols - 1) * spacing) /
                cols;
            final cardH =
                (constraints.maxHeight - 2 * padding - (rows - 1) * spacing) /
                rows;
            final aspectRatio = cardW / cardH;
            return Padding(
              padding: const EdgeInsets.all(padding),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  mainAxisSpacing: spacing,
                  crossAxisSpacing: spacing,
                  childAspectRatio: aspectRatio,
                ),
                itemCount: _kCardCount,
                itemBuilder: (_, i) => GestureDetector(
                  onTap: () => _onTap(i),
                  child: FlipCardPlusTransition(
                    animation: _flipCtrls[i],
                    front: _CardBack(colorScheme: cs),
                    back: _CardFace(emoji: _values[i], colorScheme: cs),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ==================== Card Widgets ====================

class _CardBack extends StatelessWidget {
  final ColorScheme colorScheme;
  const _CardBack({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      color: colorScheme.primary,
      child: Center(
        child: Icon(Icons.question_mark, color: colorScheme.onPrimary, size: 38),
      ),
    );
  }
}

class _CardFace extends StatelessWidget {
  final String emoji;
  final ColorScheme colorScheme;
  const _CardFace({required this.emoji, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: colorScheme.secondaryContainer,
      child: Center(
        child: Text(emoji, style: const TextStyle(fontSize: 42)),
      ),
    );
  }
}
