import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // for HapticFeedback
import 'dart:async'; // for Future.delayed
import 'dart:math'; // for Random

void main() {
  runApp(const MemoryMatchApp());
}

class MemoryMatchApp extends StatefulWidget {
  const MemoryMatchApp({super.key});

  @override
  State<MemoryMatchApp> createState() => _MemoryMatchAppState();
}

class _MemoryMatchAppState extends State<MemoryMatchApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'メモリーマッチ',
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
  late List<String> _cards;
  final Set<int> _matchedIndices = <int>{};
  final List<int> _revealedIndices = <int>[];
  int _moves = 0;
  bool _isProcessing = false;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  void _startGame() {
    final pool = ["🐶", "🐱", "🐰", "🦊", "🐻", "🐼", "🐸", "🐯"];
    final List<String> deck = [...pool, ...pool]; // duplicate to make pairs
    deck.shuffle(_random);
    setState(() {
      _cards = deck;
      _matchedIndices.clear();
      _revealedIndices.clear();
      _moves = 0;
      _isProcessing = false;
    });
  }

  void _evaluatePair() {
    setState(() {
      _moves++;
      _isProcessing = true;
    });
    final a = _revealedIndices[0];
    final b = _revealedIndices[1];
    if (_cards[a] == _cards[b]) {
      // Match: trigger haptic feedback FIRST for immediate response,
      // then keep them face-up permanently.
      HapticFeedback.lightImpact();
      Future.delayed(const Duration(milliseconds: 400), () {
        if (!mounted) return;
        setState(() {
          _matchedIndices.add(a);
          _matchedIndices.add(b);
          _revealedIndices.clear();
          _isProcessing = false;
        });
        _checkWin();
      });
    } else {
      // No match: flip them back after 1 second.
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (!mounted) return;
        setState(() {
          _revealedIndices.clear();
          _isProcessing = false;
        });
      });
    }
  }

  void _checkWin() {
    if (_matchedIndices.length == 16) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('You Win!'),
          content: Text('Moves: $_moves'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _startGame();
              },
              child: const Text('New Game'),
            ),
          ],
        ),
      );
    }
  }

  void _onTap(int i) {
    if (_isProcessing) return;
    if (_matchedIndices.contains(i)) return;
    if (_revealedIndices.contains(i)) return;

    setState(() {
      _revealedIndices.add(i);
    });

    if (_revealedIndices.length == 2) {
      _evaluatePair();
    }
  }

  Widget _buildCard(int index) {
    final bool isFaceUp =
        _revealedIndices.contains(index) || _matchedIndices.contains(index);
    final bool isMatched = _matchedIndices.contains(index);

    return GestureDetector(
      onTap: () => _onTap(index),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: isFaceUp
            ? Container(
                key: ValueKey('face-up-$index'),
                decoration: BoxDecoration(
                  color: isMatched
                      ? Colors.green.shade300
                      : Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    _cards[index],
                    style: const TextStyle(fontSize: 36),
                  ),
                ),
              )
            : Container(
                key: ValueKey('face-down-$index'),
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    '?',
                    style: TextStyle(fontSize: 36, color: Colors.white),
                  ),
                ),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('メモリーマッチ'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Moves: $_moves',
              style: const TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
          ),
          GridView.count(
            crossAxisCount: 4,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            padding: const EdgeInsets.all(16),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: List.generate(16, (index) => _buildCard(index)),
          ),
        ],
      ),
    );
  }
}
