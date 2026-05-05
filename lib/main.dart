import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'タイマー',
      theme: ThemeData(useMaterial3: true),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('タイマー'),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Stopwatch'),
              Tab(text: 'Timer'),
            ],
            labelColor: Colors.white,
            indicatorColor: Colors.white,
          ),
        ),
        body: const TabBarView(
          children: [
            StopwatchTab(),
            TimerTab(),
          ],
        ),
      ),
    );
  }
}

// ─── Stopwatch Tab ────────────────────────────────────────────────────────────

class StopwatchTab extends StatefulWidget {
  const StopwatchTab({super.key});

  @override
  State<StopwatchTab> createState() => _StopwatchTabState();
}

class _StopwatchTabState extends State<StopwatchTab>
    with AutomaticKeepAliveClientMixin {
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _timer?.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  void _start() {
    if (_stopwatch.isRunning) return;
    _stopwatch.start();
    _timer = Timer.periodic(const Duration(milliseconds: 10), (_) {
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

  String _formatTime() {
    final elapsed = _stopwatch.elapsed;
    final minutes =
        elapsed.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds =
        elapsed.inSeconds.remainder(60).toString().padLeft(2, '0');
    final hundredths =
        (elapsed.inMilliseconds.remainder(1000) ~/ 10)
            .toString()
            .padLeft(2, '0');
    return '$minutes:$seconds.$hundredths';
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _formatTime(),
            style: const TextStyle(
              fontSize: 64,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _stopwatch.isRunning ? null : _start,
                child: const Text('Start'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: _stopwatch.isRunning ? _stop : null,
                child: const Text('Stop'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: _reset,
                child: const Text('Reset'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Timer Tab ────────────────────────────────────────────────────────────────

class TimerTab extends StatefulWidget {
  const TimerTab({super.key});

  @override
  State<TimerTab> createState() => _TimerTabState();
}

class _TimerTabState extends State<TimerTab>
    with AutomaticKeepAliveClientMixin {
  int _selectedMinutes = 0;
  int _selectedSeconds = 0;
  int _remainingSeconds = 0;
  bool _isRunning = false;
  Timer? _timer;

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start() {
    if (_isRunning || _remainingSeconds <= 0) return;

    setState(() => _isRunning = true);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _remainingSeconds--;
        if (_remainingSeconds <= 0) {
          _remainingSeconds = 0;
          _isRunning = false;
        }
      });
      if (_remainingSeconds <= 0) {
        timer.cancel();
        _timer = null;
        _showTimesUpDialog();
      }
    });
  }

  void _reset() {
    _timer?.cancel();
    _timer = null;
    setState(() {
      _isRunning = false;
      _remainingSeconds = _selectedMinutes * 60 + _selectedSeconds;
    });
  }

  void _showTimesUpDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Time's up!"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _formatRemaining() {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Dropdowns row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  const Text('Minutes'),
                  const SizedBox(height: 4),
                  DropdownButton<int>(
                    value: _selectedMinutes,
                    items: List.generate(
                      60,
                      (i) => DropdownMenuItem(
                        value: i,
                        child: Text(i.toString().padLeft(2, '0')),
                      ),
                    ),
                    onChanged: _isRunning
                        ? null
                        : (value) {
                            if (value != null) {
                              setState(() {
                                _selectedMinutes = value;
                                _remainingSeconds =
                                    _selectedMinutes * 60 + _selectedSeconds;
                              });
                            }
                          },
                  ),
                ],
              ),
              const SizedBox(width: 32),
              Column(
                children: [
                  const Text('Seconds'),
                  const SizedBox(height: 4),
                  DropdownButton<int>(
                    value: _selectedSeconds,
                    items: List.generate(
                      60,
                      (i) => DropdownMenuItem(
                        value: i,
                        child: Text(i.toString().padLeft(2, '0')),
                      ),
                    ),
                    onChanged: _isRunning
                        ? null
                        : (value) {
                            if (value != null) {
                              setState(() {
                                _selectedSeconds = value;
                                _remainingSeconds =
                                    _selectedMinutes * 60 + _selectedSeconds;
                              });
                            }
                          },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          // Countdown display
          Text(
            _formatRemaining(),
            style: const TextStyle(
              fontSize: 64,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 40),
          // Buttons row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: (_isRunning || _remainingSeconds <= 0) ? null : _start,
                child: const Text('Start'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: _reset,
                child: const Text('Reset'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
