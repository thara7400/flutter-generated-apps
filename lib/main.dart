import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(const WhackAMoleApp());
}

class WhackAMoleApp extends StatefulWidget {
  const WhackAMoleApp({super.key});

  @override
  State<WhackAMoleApp> createState() => _WhackAMoleAppState();
}

class _WhackAMoleAppState extends State<WhackAMoleApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'モグラハンター',
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
  int _score = 0;
  int _remainingSeconds = 30;
  int? _activeMoleIndex;
  Timer? _spawnTimer;
  Timer? _gameTimer;
  Timer? _hideMoleTimer;
  final Random _random = Random();
  bool _isGameOver = false;

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  void _startGame() {
    _spawnTimer?.cancel();
    _gameTimer?.cancel();
    _hideMoleTimer?.cancel();
    setState(() {
      _score = 0;
      _remainingSeconds = 30;
      _activeMoleIndex = null;
      _isGameOver = false;
    });
    _spawnTimer = Timer.periodic(
      const Duration(milliseconds: 1500),
      (_) => _spawnMole(),
    );
    _gameTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _tickGameTimer(),
    );
  }

  void _spawnMole() {
    if (_isGameOver) return;
    setState(() {
      _activeMoleIndex = _random.nextInt(9);
    });
    _hideMoleTimer?.cancel();
    _hideMoleTimer = Timer(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _activeMoleIndex = null;
        });
      }
    });
  }

  void _tickGameTimer() {
    if (!mounted) return;
    setState(() {
      _remainingSeconds -= 1;
    });
    if (_remainingSeconds <= 0) {
      _endGame();
    }
  }

  void _endGame() {
    setState(() {
      _isGameOver = true;
    });
    _spawnTimer?.cancel();
    _gameTimer?.cancel();
    _hideMoleTimer?.cancel();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Time's up!"),
        content: Text('Score: $_score'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startGame();
            },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  void _onCellTap(int cellIndex) {
    if (_isGameOver) return;
    if (_activeMoleIndex == cellIndex) {
      HapticFeedback.lightImpact();
      setState(() {
        _score += 1;
        _activeMoleIndex = null;
      });
      _hideMoleTimer?.cancel();
    }
  }

  @override
  void dispose() {
    _spawnTimer?.cancel();
    _gameTimer?.cancel();
    _hideMoleTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('モグラハンター'),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Score: $_score',
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Time: ${_remainingSeconds}s',
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ],
            ),
          ),
          GridView.count(
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            padding: const EdgeInsets.all(16),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: List.generate(9, (index) {
              final isMoleHere = _activeMoleIndex == index;
              return GestureDetector(
                onTap: () => _onCellTap(index),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: isMoleHere ? 1.0 : 0.0,
                      child: const Text(
                        '🐰',
                        style: TextStyle(fontSize: 48),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
