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
      title: '簡単タイマー',
      theme: ThemeData(useMaterial3: true),
      home: const MainScreen(),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Root scaffold — DefaultTabController owns the tab state
// ─────────────────────────────────────────────────────────────
class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('簡単タイマー'),
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

// ─────────────────────────────────────────────────────────────
// Stopwatch Tab
// ─────────────────────────────────────────────────────────────
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

  // ── Controls ─────────────────────────────────────────────
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

  // ── Formatting ────────────────────────────────────────────
  String _formatElapsed(Duration d) {
    final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final hs = (d.inMilliseconds.remainder(1000) ~/ 10).toString().padLeft(2, '0');
    return '$mm:$ss.$hs';
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // required by AutomaticKeepAliveClientMixin

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ── Time display ──────────────────────────────────
          Text(
            _formatElapsed(_stopwatch.elapsed),
            style: const TextStyle(
              fontSize: 64,
              fontFamily: 'monospace',
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 40),
          // ── Buttons ───────────────────────────────────────
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

// ─────────────────────────────────────────────────────────────
// Countdown Timer Tab
// ─────────────────────────────────────────────────────────────
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
  Timer? _countdown;

  @override
  bool get wantKeepAlive => true;

  // ── Helpers ───────────────────────────────────────────────
  int get _totalSelected => _selectedMinutes * 60 + _selectedSeconds;

  String _format(int totalSeconds) {
    final mm = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final ss = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  // ── Controls ──────────────────────────────────────────────
  void _start() {
    if (_isRunning) return;

    // If the remaining time was never set (or reset to 0 via dropdowns), use selection
    int startFrom = _remainingSeconds > 0 ? _remainingSeconds : _totalSelected;
    if (startFrom <= 0) return; // nothing to count down

    setState(() {
      _remainingSeconds = startFrom;
      _isRunning = true;
    });

    _countdown = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        _remainingSeconds--;
        if (_remainingSeconds <= 0) {
          _remainingSeconds = 0;
          _isRunning = false;
          t.cancel();
          _countdown = null;
          // Show dialog after the frame so the setState above is flushed
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showTimesUpDialog();
          });
        }
      });
    });
  }

  void _reset() {
    _countdown?.cancel();
    _countdown = null;
    setState(() {
      _isRunning = false;
      _remainingSeconds = _totalSelected;
    });
  }

  void _showTimesUpDialog() {
    if (!mounted) return;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
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

  @override
  void dispose() {
    _countdown?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // required by AutomaticKeepAliveClientMixin

    // What to display: remaining when running/paused mid-count, else selection
    final displaySeconds =
        (_isRunning || _remainingSeconds > 0) ? _remainingSeconds : _totalSelected;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ── Dropdown row ──────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Minutes picker
              Column(
                children: [
                  const Text('Minutes', style: TextStyle(fontSize: 14)),
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
                        : (v) {
                            setState(() {
                              _selectedMinutes = v!;
                              _remainingSeconds = 0; // reflect new selection in display
                            });
                          },
                  ),
                ],
              ),
              const SizedBox(width: 32),
              // Seconds picker
              Column(
                children: [
                  const Text('Seconds', style: TextStyle(fontSize: 14)),
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
                        : (v) {
                            setState(() {
                              _selectedSeconds = v!;
                              _remainingSeconds = 0; // reflect new selection in display
                            });
                          },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          // ── Countdown display ─────────────────────────────
          Text(
            _format(displaySeconds),
            style: const TextStyle(
              fontSize: 64,
              fontFamily: 'monospace',
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 40),
          // ── Buttons ───────────────────────────────────────
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
