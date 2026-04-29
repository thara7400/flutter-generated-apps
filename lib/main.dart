import 'package:flutter/material.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatefulWidget {
  const CalculatorApp({super.key});

  @override
  State<CalculatorApp> createState() => _CalculatorAppState();
}

class _CalculatorAppState extends State<CalculatorApp> {
  String _display = '0';
  String _operator = '';
  double _firstOperand = 0;
  bool _waitingForSecond = false;
  bool _hasResult = false;

  void _onButtonPressed(String label) {
    setState(() {
      if (label == 'C') {
        _display = '0';
        _operator = '';
        _firstOperand = 0;
        _waitingForSecond = false;
        _hasResult = false;
      } else if (label == '±') {
        if (_display != 'Error') {
          final double val = double.tryParse(_display) ?? 0;
          _display = _formatNumber(-val);
        }
      } else if (label == '%') {
        if (_display != 'Error') {
          final double val = double.tryParse(_display) ?? 0;
          _display = _formatNumber(val / 100);
        }
      } else if (label == '÷' ||
          label == '×' ||
          label == '−' ||
          label == '+') {
        if (_display != 'Error') {
          _firstOperand = double.tryParse(_display) ?? 0;
          _operator = label;
          _waitingForSecond = true;
          _hasResult = false;
        }
      } else if (label == '=') {
        if (_operator.isNotEmpty && _display != 'Error') {
          final double second = double.tryParse(_display) ?? 0;
          double result = 0;
          switch (_operator) {
            case '+':
              result = _firstOperand + second;
              break;
            case '−':
              result = _firstOperand - second;
              break;
            case '×':
              result = _firstOperand * second;
              break;
            case '÷':
              if (second == 0) {
                _display = 'Error';
                _operator = '';
                _waitingForSecond = false;
                _hasResult = true;
                return;
              }
              result = _firstOperand / second;
              break;
            default:
              return;
          }
          _display = _formatNumber(result);
          _operator = '';
          _waitingForSecond = false;
          _hasResult = true;
        }
      } else if (label == '.') {
        if (_waitingForSecond) {
          _display = '0.';
          _waitingForSecond = false;
        } else if (_display == 'Error') {
          _display = '0.';
        } else if (!_display.contains('.')) {
          _display = '$_display.';
        }
      } else {
        // Digit 0-9
        if (_waitingForSecond) {
          _display = label;
          _waitingForSecond = false;
        } else if (_hasResult) {
          _display = label;
          _hasResult = false;
        } else if (_display == '0' || _display == 'Error') {
          _display = label;
        } else {
          _display = '$_display$label';
        }
      }
    });
  }

  String _formatNumber(double val) {
    if (val.isNaN || val.isInfinite) return 'Error';
    if (val == val.truncateToDouble()) {
      return val.toInt().toString();
    }
    // Trim trailing zeros from decimal representation
    String s = val.toString();
    return s;
  }

  Color _buttonBgColor(String label) {
    const operators = {'÷', '×', '−', '+', '='};
    const topRow = {'C', '±', '%'};
    if (operators.contains(label)) return Colors.purple;
    if (topRow.contains(label)) return Colors.grey.shade400;
    return Colors.grey.shade800;
  }

  Color _buttonFgColor(String label) {
    const topRow = {'C', '±', '%'};
    return topRow.contains(label) ? Colors.black : Colors.white;
  }

  Widget _calcButton(String label, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: ElevatedButton(
          onPressed: () => _onButtonPressed(label),
          style: ElevatedButton.styleFrom(
            backgroundColor: _buttonBgColor(label),
            foregroundColor: _buttonFgColor(label),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.zero,
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buttonRow(List<String> labels) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: labels.map((l) => _calcButton(l)).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'S5 Docker E2E',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.purple,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('S5 Docker E2E'),
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
        ),
        body: Column(
          children: [
            // ── Display area ──────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
              color: Colors.black,
              child: Text(
                _display,
                style: const TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                ),
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // ── Button grid ───────────────────────────────────
            Expanded(
              child: Column(
                children: [
                  _buttonRow(['C', '±', '%', '÷']),
                  _buttonRow(['7', '8', '9', '×']),
                  _buttonRow(['4', '5', '6', '−']),
                  _buttonRow(['1', '2', '3', '+']),
                  // Last row: 0 is double-wide
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _calcButton('0', flex: 2),
                        _calcButton('.'),
                        _calcButton('='),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
