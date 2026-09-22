import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '簡単計算機',
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
  final _leftController = TextEditingController();
  final _rightController = TextEditingController();
  String? _selectedOp;
  String _result = '';
  String? _error;

  static const _ops = [
    (label: '+', symbol: '+'),
    (label: '−', symbol: '-'),
    (label: '×', symbol: '*'),
    (label: '÷', symbol: '/'),
  ];

  void _calculate() {
    final leftText = _leftController.text.trim();
    final rightText = _rightController.text.trim();

    if (leftText.isEmpty || rightText.isEmpty) {
      setState(() {
        _error = '数値を両方入力してください';
        _result = '';
      });
      return;
    }
    if (_selectedOp == null) {
      setState(() {
        _error = '演算子を選択してください';
        _result = '';
      });
      return;
    }

    final left = double.tryParse(leftText);
    final right = double.tryParse(rightText);
    if (left == null || right == null) {
      setState(() {
        _error = '正しい数値を入力してください';
        _result = '';
      });
      return;
    }

    double value;
    switch (_selectedOp) {
      case '+':
        value = left + right;
      case '-':
        value = left - right;
      case '*':
        value = left * right;
      case '/':
        if (right == 0) {
          setState(() {
            _error = 'ゼロでは割れません';
            _result = '';
          });
          return;
        }
        value = left / right;
      default:
        return;
    }

    final display =
        value == value.truncateToDouble() ? value.toInt().toString() : value.toString();

    setState(() {
      _error = null;
      _result = display;
    });
  }

  void _clear() {
    _leftController.clear();
    _rightController.clear();
    setState(() {
      _selectedOp = null;
      _result = '';
      _error = null;
    });
  }

  @override
  void dispose() {
    _leftController.dispose();
    _rightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('簡単計算機'),
        backgroundColor: cs.inversePrimary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── 入力欄 ──────────────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: _NumberField(controller: _leftController, label: '数値 A')),
                  const SizedBox(width: 16),
                  _OpLabel(op: _selectedOp),
                  const SizedBox(width: 16),
                  Expanded(child: _NumberField(controller: _rightController, label: '数値 B')),
                ],
              ),
              const SizedBox(height: 32),

              // ── 演算子ボタン ────────────────────────────────────
              const Text('演算子を選んでください',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.black54)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _ops
                    .map((op) => _OpButton(
                          label: op.label,
                          selected: _selectedOp == op.symbol,
                          onTap: () => setState(() => _selectedOp = op.symbol),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 32),

              // ── 計算ボタン ──────────────────────────────────────
              FilledButton.icon(
                onPressed: _calculate,
                icon: const Icon(Icons.calculate),
                label: const Text('計　算', style: TextStyle(fontSize: 18)),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 12),

              // ── クリアボタン ────────────────────────────────────
              OutlinedButton.icon(
                onPressed: _clear,
                icon: const Icon(Icons.refresh),
                label: const Text('やり直す', style: TextStyle(fontSize: 16)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
              const SizedBox(height: 36),

              // ── 結果 ────────────────────────────────────────────
              if (_error != null)
                _ResultCard(
                  label: 'エラー',
                  value: _error!,
                  color: cs.errorContainer,
                  textColor: cs.onErrorContainer,
                )
              else if (_result.isNotEmpty)
                _ResultCard(
                  label: '計算結果',
                  value: _result,
                  color: cs.primaryContainer,
                  textColor: cs.onPrimaryContainer,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── サブウィジェット ──────────────────────────────────────────────────────────

class _NumberField extends StatelessWidget {
  const _NumberField({required this.controller, required this.label});
  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[-0-9.]')),
      ],
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      textAlign: TextAlign.center,
    );
  }
}

class _OpLabel extends StatelessWidget {
  const _OpLabel({required this.op});
  final String? op;

  static const _display = {'+': '+', '-': '−', '*': '×', '/': '÷'};

  @override
  Widget build(BuildContext context) {
    return Text(
      op != null ? (_display[op] ?? '?') : '　',
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

class _OpButton extends StatelessWidget {
  const _OpButton({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: selected ? cs.primary : cs.surfaceContainerHighest,
          shape: BoxShape.circle,
          boxShadow: selected
              ? [BoxShadow(color: cs.primary.withValues(alpha: 0.35), blurRadius: 8, offset: const Offset(0, 3))]
              : [],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: selected ? cs.onPrimary : cs.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.label,
    required this.value,
    required this.color,
    required this.textColor,
  });
  final String label;
  final String value;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(label,
              style: TextStyle(fontSize: 14, color: textColor.withValues(alpha: 0.7))),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
