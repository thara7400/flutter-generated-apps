import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const StopwatchApp());
}

class StopwatchApp extends StatelessWidget {
  const StopwatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '簡単 ストップウォッチ',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1565C0),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const StopwatchScreen(),
    );
  }
}

class StopwatchScreen extends StatefulWidget {
  const StopwatchScreen({super.key});

  @override
  State<StopwatchScreen> createState() => _StopwatchScreenState();
}

class _StopwatchScreenState extends State<StopwatchScreen> {
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;

  void _start() {
    if (_stopwatch.isRunning) return;
    _stopwatch.start();
    _timer = Timer.periodic(const Duration(milliseconds: 30), (_) {
      setState(() {});
    });
  }

  void _stop() {
    if (!_stopwatch.isRunning) return;
    _stopwatch.stop();
    _timer?.cancel();
    _timer = null;
    setState(() {});
  }

  void _reset() {
    _stopwatch.stop();
    _timer?.cancel();
    _timer = null;
    _stopwatch.reset();
    setState(() {});
  }

  String _formatTime(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final centis = (d.inMilliseconds.remainder(1000) ~/ 10)
        .toString()
        .padLeft(2, '0');
    return '$minutes:$seconds.$centis';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final elapsed = _stopwatch.elapsed;
    final isRunning = _stopwatch.isRunning;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text('簡単 ストップウォッチ'),
        centerTitle: true,
        backgroundColor: cs.primaryContainer,
        foregroundColor: cs.onPrimaryContainer,
      ),
      body: Column(
        children: [
          // ── 時間表示エリア ──────────────────────────────
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatTime(elapsed),
                    style: TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 4,
                      color: isRunning ? cs.primary : cs.onSurface,
                      fontFeatures: const [
                        // 等幅数字
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isRunning ? '計測中…' : (elapsed == Duration.zero ? '準備完了' : '停止中'),
                    style: TextStyle(
                      fontSize: 16,
                      color: isRunning ? cs.primary : cs.outline,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── ボタンエリア ────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(bottom: 56, left: 32, right: 32),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // リセット
                _CircleButton(
                  label: 'リセット',
                  icon: Icons.refresh,
                  onPressed: _reset,
                  foreground: cs.onSecondaryContainer,
                  background: cs.secondaryContainer,
                ),

                // 開始 / 停止（大きめ）
                _CircleButton(
                  label: isRunning ? '停止' : '開始',
                  icon: isRunning ? Icons.pause : Icons.play_arrow,
                  onPressed: isRunning ? _stop : _start,
                  foreground: cs.onPrimary,
                  background: cs.primary,
                  size: 80,
                  iconSize: 36,
                ),

                // 予備スペース（対称バランス用に透明ボタン）
                Opacity(
                  opacity: 0,
                  child: _CircleButton(
                    label: '',
                    icon: Icons.refresh,
                    onPressed: null,
                    foreground: Colors.transparent,
                    background: Colors.transparent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.foreground,
    required this.background,
    this.size = 64,
    this.iconSize = 28,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final Color foreground;
  final Color background;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              backgroundColor: background,
              foregroundColor: foreground,
              padding: EdgeInsets.zero,
              elevation: 2,
            ),
            child: Icon(icon, size: iconSize),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
