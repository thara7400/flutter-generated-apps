import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'シンプル電卓',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _expression = '';
  String _result = '';

  void _onButton(String value) {
    setState(() {
      if (value == 'C') {
        _expression = '';
        _result = '';
      } else if (value == '⌫') {
        if (_expression.isNotEmpty) {
          _expression = _expression.substring(0, _expression.length - 1);
          _tryPreview();
        }
      } else if (value == '=') {
        _calculate();
      } else {
        _expression += value;
        _tryPreview();
      }
    });
  }

  void _tryPreview() {
    if (_expression.isEmpty) {
      _result = '';
      return;
    }
    try {
      final val = _evaluate(_expression);
      _result = _formatResult(val);
    } catch (_) {
      _result = '';
    }
  }

  void _calculate() {
    if (_expression.isEmpty) return;
    try {
      final val = _evaluate(_expression);
      _expression = _formatResult(val);
      _result = '';
    } catch (_) {
      _result = 'エラー';
    }
  }

  double _evaluate(String expr) {
    final sanitized = expr.replaceAll('×', '*').replaceAll('÷', '/');
    final parser = GrammarParser();
    final exp = parser.parse(sanitized);
    final cm = ContextModel();
    final result = RealEvaluator(cm).evaluate(exp).toDouble();
    if (result.isNaN || result.isInfinite) {
      throw Exception('無効な結果');
    }
    return result;
  }

  String _formatResult(double value) {
    if (value == value.roundToDouble() && value.abs() < 1e15) {
      return value.toInt().toString();
    }
    final s = value.toStringAsPrecision(10);
    return double.parse(s).toString();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surfaceContainerHighest,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: _buildDisplay(cs),
            ),
            Expanded(
              flex: 3,
              child: _buildKeypad(cs),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisplay(ColorScheme cs) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'シンプル電卓',
            style: TextStyle(fontSize: 15, color: cs.outline),
          ),
          const Spacer(),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: true,
            child: Text(
              _expression.isEmpty ? '0' : _expression,
              style: TextStyle(
                fontSize: 44,
                fontWeight: FontWeight.w300,
                color: cs.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 36,
            child: _result.isEmpty
                ? const SizedBox.shrink()
                : Text(
                    '= $_result',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: cs.primary,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeypad(ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          // Row 1: C (wide), ⌫, ÷
          Expanded(
            child: Row(children: [
              _btn('C',
                  bg: cs.errorContainer,
                  fg: cs.onErrorContainer,
                  flex: 2),
              _btn('⌫',
                  bg: cs.secondaryContainer,
                  fg: cs.onSecondaryContainer),
              _btn('÷',
                  bg: cs.primaryContainer,
                  fg: cs.onPrimaryContainer),
            ]),
          ),
          // Row 2: 7, 8, 9, ×
          Expanded(
            child: Row(children: [
              _btn('7'),
              _btn('8'),
              _btn('9'),
              _btn('×',
                  bg: cs.primaryContainer,
                  fg: cs.onPrimaryContainer),
            ]),
          ),
          // Row 3: 4, 5, 6, -
          Expanded(
            child: Row(children: [
              _btn('4'),
              _btn('5'),
              _btn('6'),
              _btn('-',
                  bg: cs.primaryContainer,
                  fg: cs.onPrimaryContainer),
            ]),
          ),
          // Row 4: 1, 2, 3, +
          Expanded(
            child: Row(children: [
              _btn('1'),
              _btn('2'),
              _btn('3'),
              _btn('+',
                  bg: cs.primaryContainer,
                  fg: cs.onPrimaryContainer),
            ]),
          ),
          // Row 5: 0 (wide), ., =
          Expanded(
            child: Row(children: [
              _btn('0', flex: 2),
              _btn('.'),
              _btn('=', bg: cs.primary, fg: cs.onPrimary),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _btn(
    String label, {
    Color? bg,
    Color? fg,
    int flex = 1,
  }) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: SizedBox.expand(
          child: FilledButton(
            onPressed: () => _onButton(label),
            style: FilledButton.styleFrom(
              backgroundColor: bg ?? Colors.grey.shade200,
              foregroundColor: fg ?? Colors.black87,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
