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
      title: 'ラップ付きストップウォッチ',
      theme: ThemeData(
        colorSchemeSeed: Colors.teal,
        useMaterial3: true,
      ),
      home: const StopwatchScreen(),
    );
  }
}

class LapRecord {
  final int lapNumber;
  final Duration lapTime;    // このラップの所要時間
  final Duration totalTime;  // スタートからの累計時間

  const LapRecord({
    required this.lapNumber,
    required this.lapTime,
    required this.totalTime,
  });
}

class StopwatchScreen extends StatefulWidget {
  const StopwatchScreen({super.key});

  @override
  State<StopwatchScreen> createState() => _StopwatchScreenState();
}

class _StopwatchScreenState extends State<StopwatchScreen> {
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  final List<LapRecord> _laps = [];
  Duration _lastLapTime = Duration.zero;

  bool get _isRunning => _stopwatch.isRunning;

  void _startStop() {
    if (_isRunning) {
      _stopwatch.stop();
      _timer?.cancel();
      _timer = null;
    } else {
      _stopwatch.start();
      _timer = Timer.periodic(const Duration(milliseconds: 30), (_) {
        setState(() {});
      });
    }
    setState(() {});
  }

  void _reset() {
    if (_isRunning) return;
    _stopwatch.reset();
    _timer?.cancel();
    _timer = null;
    setState(() {
      _laps.clear();
      _lastLapTime = Duration.zero;
    });
  }

  void _lap() {
    if (!_isRunning) return;
    final total = _stopwatch.elapsed;
    final lap = total - _lastLapTime;
    setState(() {
      _laps.insert(0, LapRecord(
        lapNumber: _laps.length + 1,
        lapTime: lap,
        totalTime: total,
      ));
      _lastLapTime = total;
    });
  }

  String _format(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final centis = (d.inMilliseconds.remainder(1000) ~/ 10).toString().padLeft(2, '0');
    return '$minutes:$seconds.$centis';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final elapsed = _stopwatch.elapsed;
    final hasData = _stopwatch.elapsedMilliseconds > 0 || _laps.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ストップウォッチ'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 経過時間表示
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 48),
            color: theme.colorScheme.surfaceContainerHighest,
            child: Center(
              child: Text(
                _format(elapsed),
                style: theme.textTheme.displayLarge?.copyWith(
                  fontFeatures: const [FontFeature.tabularFigures()],
                  fontSize: 72,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 4,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ),

          // ボタン行
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // リセット
                _CircleButton(
                  label: 'リセット',
                  icon: Icons.refresh,
                  onPressed: (!_isRunning && hasData) ? _reset : null,
                  color: theme.colorScheme.errorContainer,
                  foreground: theme.colorScheme.onErrorContainer,
                ),
                // スタート / ストップ
                _CircleButton(
                  label: _isRunning ? 'ストップ' : 'スタート',
                  icon: _isRunning ? Icons.stop : Icons.play_arrow,
                  onPressed: _startStop,
                  color: _isRunning
                      ? theme.colorScheme.primary
                      : theme.colorScheme.primaryContainer,
                  foreground: _isRunning
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onPrimaryContainer,
                  large: true,
                ),
                // ラップ
                _CircleButton(
                  label: 'ラップ',
                  icon: Icons.flag_outlined,
                  onPressed: _isRunning ? _lap : null,
                  color: theme.colorScheme.secondaryContainer,
                  foreground: theme.colorScheme.onSecondaryContainer,
                ),
              ],
            ),
          ),

          // ラップ一覧ヘッダ
          if (_laps.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  SizedBox(
                    width: 48,
                    child: Text('No.',
                        style: theme.textTheme.labelSmall
                            ?.copyWith(color: theme.colorScheme.outline)),
                  ),
                  Expanded(
                    child: Text('ラップタイム',
                        style: theme.textTheme.labelSmall
                            ?.copyWith(color: theme.colorScheme.outline)),
                  ),
                  Text('累計タイム',
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: theme.colorScheme.outline)),
                ],
              ),
            ),
            const Divider(height: 8),
          ],

          // ラップリスト
          Expanded(
            child: _laps.isEmpty
                ? Center(
                    child: Text(
                      'ラップボタンで記録できます',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: _laps.length,
                    separatorBuilder: (_, _) =>
                        const Divider(height: 1, indent: 16, endIndent: 16),
                    itemBuilder: (context, index) {
                      final lap = _laps[index];
                      final isLatest = index == 0;
                      final textStyle = theme.textTheme.bodyLarge?.copyWith(
                        fontFeatures: const [FontFeature.tabularFigures()],
                        color: isLatest
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface,
                        fontWeight:
                            isLatest ? FontWeight.bold : FontWeight.normal,
                      );
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 48,
                              child: Text(
                                'L${lap.lapNumber}',
                                style: textStyle,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                _format(lap.lapTime),
                                style: textStyle,
                              ),
                            ),
                            Text(
                              _format(lap.totalTime),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontFeatures: const [
                                  FontFeature.tabularFigures()
                                ],
                                color: theme.colorScheme.outline,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final Color color;
  final Color foreground;
  final bool large;

  const _CircleButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.color,
    required this.foreground,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    final size = large ? 80.0 : 64.0;
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
              padding: EdgeInsets.zero,
              backgroundColor:
                  onPressed == null ? Colors.grey.shade300 : color,
              foregroundColor:
                  onPressed == null ? Colors.grey.shade500 : foreground,
              elevation: onPressed == null ? 0 : 2,
            ),
            child: Icon(icon, size: large ? 36 : 28),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: onPressed == null
                    ? Colors.grey.shade400
                    : Theme.of(context).colorScheme.onSurface,
              ),
        ),
      ],
    );
  }
}
