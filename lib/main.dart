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
      title: 'マイタイマー',
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
          title: const Text('マイタイマー'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Stopwatch'),
              Tab(text: 'Timer'),
            ],
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

// ─────────────────────────────────────────────────────────────────────────────
// Stopwatch Tab
// ─────────────────────────────────────────────────────────────────────────────

class StopwatchTab extends StatefulWidget {
  const StopwatchTab({super.key});

  @override
  State<StopwatchTab> createState() => _StopwatchTabState();
}

class _StopwatchTabState extends State<StopwatchTab>
    with AutomaticKeepAliveClientMixin {
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _ticker;

  @override
  bool get wantKeepAlive => true;

  // ── Actions ────────────────────────────────────────────────────────────────

  void _start() {
    if (_stopwatch.isRunning) return;
    _stopwatch.start();
    _ticker = Timer.periodic(const Duration(milliseconds: 10), (_) {
      setState(() {});
    });
  }

  void _stop() {
    _stopwatch.stop();
    _ticker?.cancel();
    _ticker = null;
    setState(() {});
  }

  void _reset() {
    _stopwatch.stop();
    _stopwatch.reset();
    _ticker?.cancel();
    _ticker = null;
    setState(() {});
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _formatElapsed() {
    final elapsed = _stopwatch.elapsed;
    final mm = elapsed.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = elapsed.inSeconds.remainder(60).toString().padLeft(2, '0');
    final hh =
        (elapsed.inMilliseconds.remainder(1000) ~/ 10).toString().padLeft(2, '0');
    return '$mm:$ss.$hh';
  }

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _ticker?.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Time display
          Text(
            _formatElapsed(),
            style: const TextStyle(
              fontSize: 64,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 40),
          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _start,
                child: const Text('Start'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: _stop,
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

// ─────────────────────────────────────────────────────────────────────────────
// Timer (Countdown) Tab
// ─────────────────────────────────────────────────────────────────────────────

class TimerTab extends StatefulWidget {
  const TimerTab({super.key});

  @override
  State<TimerTab> createState() => _TimerTabState();
}

class _TimerTabState extends State<TimerTab>
    with AutomaticKeepAliveClientMixin {
  int _selectedMinutes = 0;
  int _selectedSeconds = 0;

  // Remaining time in seconds; kept in sync with dropdown selections when idle.
  int _remaining = 0;
  bool _isRunning = false;
  Timer? _ticker;

  @override
  bool get wantKeepAlive => true;

  // ── Actions ────────────────────────────────────────────────────────────────

  void _start() {
    if (_isRunning) return;

    // If nothing left (fresh start or post-completion), load from dropdowns.
    if (_remaining == 0) {
      _remaining = _selectedMinutes * 60 + _selectedSeconds;
    }
    if (_remaining == 0) return; // nothing to count down

    setState(() => _isRunning = true);

    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _remaining--;
        if (_remaining <= 0) {
          _remaining = 0;
          _isRunning = false;
          _ticker?.cancel();
          _ticker = null;
          _showTimeUpDialog();
        }
      });
    });
  }

  void _reset() {
    _ticker?.cancel();
    _ticker = null;
    setState(() {
      _isRunning = false;
      _remaining = _selectedMinutes * 60 + _selectedSeconds;
    });
  }

  void _showTimeUpDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Time's up!"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _formatRemaining() {
    final mm = (_remaining ~/ 60).toString().padLeft(2, '0');
    final ss = (_remaining % 60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final dropdownItems = (int count) => List.generate(
          count,
          (i) => DropdownMenuItem<int>(value: i, child: Text('$i')),
        );

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ── Dropdowns ───────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Minutes
              Column(
                children: [
                  const Text('Minutes'),
                  const SizedBox(height: 4),
                  DropdownButton<int>(
                    value: _selectedMinutes,
                    items: dropdownItems(60),
                    onChanged: _isRunning
                        ? null
                        : (value) {
                            setState(() {
                              _selectedMinutes = value!;
                              _remaining =
                                  _selectedMinutes * 60 + _selectedSeconds;
                            });
                          },
                  ),
                ],
              ),
              const SizedBox(width: 40),
              // Seconds
              Column(
                children: [
                  const Text('Seconds'),
                  const SizedBox(height: 4),
                  DropdownButton<int>(
                    value: _selectedSeconds,
                    items: dropdownItems(60),
                    onChanged: _isRunning
                        ? null
                        : (value) {
                            setState(() {
                              _selectedSeconds = value!;
                              _remaining =
                                  _selectedMinutes * 60 + _selectedSeconds;
                            });
                          },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),

          // ── Countdown display ────────────────────────────────────────────
          Text(
            _formatRemaining(),
            style: const TextStyle(
              fontSize: 64,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 40),

          // ── Controls ─────────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _isRunning ? null : _start,
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
