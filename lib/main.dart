import 'dart:async';

import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stopwatch',
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      home: const StopwatchPage(),
    );
  }
}

class StopwatchPage extends StatefulWidget {
  const StopwatchPage({super.key});

  @override
  State<StopwatchPage> createState() => _StopwatchPageState();
}

class _StopwatchPageState extends State<StopwatchPage> {
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  final List<Duration> _laps = [];

  void _startStop() {
    if (_stopwatch.isRunning) {
      _stopwatch.stop();
      _timer?.cancel();
      _timer = null;
      setState(() {});
    } else {
      _stopwatch.start();
      _timer = Timer.periodic(const Duration(milliseconds: 30), (_) {
        setState(() {});
      });
    }
  }

  void _reset() {
    _stopwatch.stop();
    _timer?.cancel();
    _timer = null;
    _stopwatch.reset();
    setState(() {
      _laps.clear();
    });
  }

  void _lap() {
    setState(() {
      _laps.insert(0, _stopwatch.elapsed);
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
    final isRunning = _stopwatch.isRunning;
    final elapsed = _stopwatch.elapsed;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stopwatch'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Timer display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 48),
            color: colorScheme.primaryContainer,
            child: Text(
              _format(elapsed),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 64,
                fontFeatures: const [FontFeature.tabularFigures()],
                fontWeight: FontWeight.w300,
                letterSpacing: 4,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
          ),

          // Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Start / Stop
                FilledButton.icon(
                  onPressed: _startStop,
                  icon: Icon(isRunning ? Icons.pause : Icons.play_arrow),
                  label: Text(isRunning ? 'Stop' : 'Start'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(120, 48),
                    backgroundColor:
                        isRunning ? colorScheme.error : colorScheme.primary,
                    foregroundColor:
                        isRunning ? colorScheme.onError : colorScheme.onPrimary,
                  ),
                ),

                // Lap
                OutlinedButton.icon(
                  onPressed: isRunning ? _lap : null,
                  icon: const Icon(Icons.flag_outlined),
                  label: const Text('Lap'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(100, 48),
                  ),
                ),

                // Reset
                OutlinedButton.icon(
                  onPressed: (!isRunning && elapsed > Duration.zero) ? _reset : null,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(100, 48),
                  ),
                ),
              ],
            ),
          ),

          // Lap list header
          if (_laps.isNotEmpty) ...[
            Divider(height: 1, color: colorScheme.outlineVariant),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    'Lap',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Time',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: colorScheme.outlineVariant),
          ],

          // Lap list
          Expanded(
            child: _laps.isEmpty
                ? Center(
                    child: Text(
                      'No laps recorded',
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  )
                : ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: _laps.length,
                    separatorBuilder: (_, _) =>
                        Divider(height: 1, color: colorScheme.outlineVariant),
                    itemBuilder: (context, index) {
                      final lapNumber = _laps.length - index;
                      final lapTime = _laps[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            Text(
                              'Lap $lapNumber',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const Spacer(),
                            Text(
                              _format(lapTime),
                              style: TextStyle(
                                fontSize: 16,
                                fontFeatures: const [FontFeature.tabularFigures()],
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w500,
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
