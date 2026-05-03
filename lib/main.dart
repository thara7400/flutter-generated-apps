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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('タイマー'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Stopwatch'),
              Tab(text: 'Timer'),
            ],
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
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

// ─────────────────────────────────────────────
// Stopwatch Tab
// ─────────────────────────────────────────────

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

  void _start() {
    if (_stopwatch.isRunning) return;
    _stopwatch.start();
    _ticker = Timer.periodic(const Duration(milliseconds: 10), (_) {
      setState(() {});
    });
  }

  void _stop() {
    if (!_stopwatch.isRunning) return;
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

  String _formatElapsed() {
    final elapsed = _stopwatch.elapsed;
    final mm = elapsed.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = elapsed.inSeconds.remainder(60).toString().padLeft(2, '0');
    final hh =
        (elapsed.inMilliseconds.remainder(1000) ~/ 10).toString().padLeft(2, '0');
    return '$mm:$ss.$hh';
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _formatElapsed(),
            style: const TextStyle(
              fontSize: 64,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 48),
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

// ─────────────────────────────────────────────
// Timer (Countdown) Tab
// ─────────────────────────────────────────────

class TimerTab extends StatefulWidget {
  const TimerTab({super.key});

  @override
  State<TimerTab> createState() => _TimerTabState();
}

class _TimerTabState extends State<TimerTab>
    with AutomaticKeepAliveClientMixin {
  int _selectedMinutes = 0;
  int _selectedSeconds = 30;
  late int _remainingSeconds;
  bool _isRunning = false;
  Timer? _ticker;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = _selectedMinutes * 60 + _selectedSeconds;
  }

  void _start() {
    if (_isRunning) return;
    if (_remainingSeconds <= 0) return;

    setState(() => _isRunning = true);

    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _remainingSeconds--;
        if (_remainingSeconds <= 0) {
          _remainingSeconds = 0;
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
      _remainingSeconds = _selectedMinutes * 60 + _selectedSeconds;
    });
  }

  void _showTimeUpDialog() {
    if (!mounted) return;
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

  String _formatRemaining() {
    final mm = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final ss = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final dropdownItems = List.generate(
      60,
      (i) => DropdownMenuItem<int>(
        value: i,
        child: Text(i.toString().padLeft(2, '0')),
      ),
    );

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Dropdowns
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Minutes picker
              Column(
                children: [
                  const Text('Minutes'),
                  const SizedBox(height: 4),
                  DropdownButton<int>(
                    value: _selectedMinutes,
                    items: dropdownItems,
                    onChanged: _isRunning
                        ? null
                        : (value) {
                            if (value == null) return;
                            setState(() {
                              _selectedMinutes = value;
                              _remainingSeconds =
                                  _selectedMinutes * 60 + _selectedSeconds;
                            });
                          },
                  ),
                ],
              ),
              const SizedBox(width: 40),
              // Seconds picker
              Column(
                children: [
                  const Text('Seconds'),
                  const SizedBox(height: 4),
                  DropdownButton<int>(
                    value: _selectedSeconds,
                    items: dropdownItems,
                    onChanged: _isRunning
                        ? null
                        : (value) {
                            if (value == null) return;
                            setState(() {
                              _selectedSeconds = value;
                              _remainingSeconds =
                                  _selectedMinutes * 60 + _selectedSeconds;
                            });
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
          const SizedBox(height: 48),
          // Buttons
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
