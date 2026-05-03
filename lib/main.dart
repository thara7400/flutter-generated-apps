import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

void main() {
  runApp(const NumberQuizApp());
}

class NumberQuizApp extends StatefulWidget {
  const NumberQuizApp({super.key});

  @override
  State<NumberQuizApp> createState() => _NumberQuizAppState();
}

class _NumberQuizAppState extends State<NumberQuizApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
  late int _answer;
  final TextEditingController _guessController = TextEditingController();
  final List<_GuessEntry> _history = <_GuessEntry>[];
  String _feedback = '';
  Color _feedbackColor = Colors.black;
  int _attempts = 0;
  bool _isGameOver = false;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  void _startGame() {
    setState(() {
      _answer = _random.nextInt(100) + 1; // 1..100
      _guessController.clear();
      _history.clear();
      _feedback = '';
      _feedbackColor = Colors.black;
      _attempts = 0;
      _isGameOver = false;
    });
  }

  void _onGuessPressed() {
    if (_isGameOver) return;
    final raw = _guessController.text.trim();
    if (raw.isEmpty) return;
    final parsed = int.tryParse(raw);
    if (parsed == null || parsed < 1 || parsed > 100) {
      setState(() {
        _feedback = 'Enter a number between 1 and 100';
        _feedbackColor = Colors.orange;
      });
      return;
    }

    setState(() {
      _attempts++;
      String hint;
      Color color;
      if (parsed == _answer) {
        hint = 'Correct!';
        color = Colors.green;
      } else if (parsed > _answer) {
        hint = 'Too high';
        color = Colors.red;
      } else {
        hint = 'Too low';
        color = Colors.blue;
      }
      _feedback = hint;
      _feedbackColor = color;
      _history.add(_GuessEntry(parsed, hint, color));
      _guessController.clear();

      if (parsed == _answer) {
        _isGameOver = true;
      }
    });

    if (_history.last.guess == _answer) {
      HapticFeedback.lightImpact();
      _showWinDialog();
      return;
    }

    // No attempt limit — nothing to do here.
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Correct!'),
        content: Text('You guessed it in $_attempts attempts.'),
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

  @override
  void dispose() {
    _guessController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('数字当てチャレンジ'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Attempts: $_attempts',
              style: const TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: const Text(
                'Guess a number between 1 and 100',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
            TextField(
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              controller: _guessController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Your guess',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _isGameOver ? null : _onGuessPressed,
              child: const Text('Guess'),
            ),
            const SizedBox(height: 16),
            Text(
              _feedback,
              style: TextStyle(fontSize: 18, color: _feedbackColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _history.length,
                itemBuilder: (context, index) {
                  final entry = _history[_history.length - 1 - index]; // reverse order
                  final attemptNumber = _history.length - index;
                  return ListTile(
                    dense: true,
                    leading: Text('#$attemptNumber',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    title: Text('${entry.guess}'),
                    trailing: Text(entry.hint, style: TextStyle(color: entry.color)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuessEntry {
  final int guess;
  final String hint; // 'Too high', 'Too low', or 'Correct!'
  final Color color;
  _GuessEntry(this.guess, this.hint, this.color);
}
