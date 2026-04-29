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
  double _operand1 = 0;
  double _operand2 = 0;
  String _operator = '';
  bool _hasOperator = false;
  bool _justEvaluated = false;
  bool _isError = false;

  void _onButton(String label) {
    setState(() {
      if (_isError && label != 'C') return;

      switch (label) {
        case 'C':
          _display = '0';
          _operand1 = 0;
          _operand2 = 0;
          _operator = '';
          _hasOperator = false;
          _justEvaluated = false;
          _isError = false;
          break;

        case '±':
          if (_display != '0') {
            if (_display.startsWith('-')) {
              _display = _display.substring(1);
            } else {
              _display = '-$_display';
            }
          }
          break;

        case '%':
          double val = double.tryParse(_display) ?? 0;
          _display = _formatResult(val / 100);
          _justEvaluated = true;
          break;

        case '÷':
        case '×':
        case '−':
        case '+':
          _operand1 = double.tryParse(_display) ?? 0;
          _operator = label;
          _hasOperator = true;
          _justEvaluated = false;
          break;

        case '=':
          if (_hasOperator) {
            _operand2 = double.tryParse(_display) ?? 0;
            double result = _evaluate(_operand1, _operand2, _operator);
            if (result.isNaN || result.isInfinite) {
              _display = 'Error';
              _isError = true;
            } else {
              _display = _formatResult(result);
            }
            _hasOperator = false;
            _justEvaluated = true;
          }
          break;

        case '.':
          if (_justEvaluated) {
            _display = '0.';
            _justEvaluated = false;
          } else if (!_display.contains('.')) {
            _display = '$_display.';
          }
          break;

        default:
          // Digit
          if (_justEvaluated || (_hasOperator && _display == _formatResult(_operand1))) {
            // Start fresh input after evaluation or after operator pressed
            if (_hasOperator && _display == _formatResult(_operand1)) {
              _display = label;
            } else {
              _display = label;
              _justEvaluated = false;
            }
          } else if (_display == '0') {
            _display = label;
          } else {
            if (_display.length < 15) {
              _display = '$_display$label';
            }
          }
          break;
      }
    });
  }

  String _formatResult(double value) {
    if (value == value.truncateToDouble()) {
      return value.toInt().toString();
    }
    String result = value.toStringAsFixed(10);
    result = result.replaceAll(RegExp(r'0+$'), '');
    result = result.replaceAll(RegExp(r'\.$'), '');
    return result;
  }

  double _evaluate(double a, double b, String op) {
    switch (op) {
      case '+':
        return a + b;
      case '−':
        return a - b;
      case '×':
        return a * b;
      case '÷':
        if (b == 0) return double.nan;
        return a / b;
      default:
        return b;
    }
  }

  Widget _buildButton(String label, {Color? bgColor, Color? fgColor}) {
    return Expanded(
      flex: label == '0' ? 2 : 1,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: ElevatedButton(
          onPressed: () => _onButton(label),
          style: ElevatedButton.styleFrom(
            backgroundColor: bgColor ?? Colors.grey[800],
            foregroundColor: fgColor ?? Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w500,
            ),
          ),
          child: Text(label),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'S5 Final E2E',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('S5 Final E2E'),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
        backgroundColor: Colors.black,
        body: Column(
          children: [
            // Display area
            Expanded(
              flex: 2,
              child: Container(
                alignment: Alignment.bottomRight,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Text(
                  _display,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: _isError ? Colors.red : Colors.white,
                    fontSize: 64,
                    fontWeight: FontWeight.w300,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            // Button grid
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    // Row 1: C, ±, %, ÷
                    Row(
                      children: [
                        _buildButton('C', bgColor: Colors.grey[500], fgColor: Colors.black),
                        _buildButton('±', bgColor: Colors.grey[500], fgColor: Colors.black),
                        _buildButton('%', bgColor: Colors.grey[500], fgColor: Colors.black),
                        _buildButton('÷', bgColor: Colors.green[700], fgColor: Colors.white),
                      ],
                    ),
                    // Row 2: 7, 8, 9, ×
                    Row(
                      children: [
                        _buildButton('7'),
                        _buildButton('8'),
                        _buildButton('9'),
                        _buildButton('×', bgColor: Colors.green[700], fgColor: Colors.white),
                      ],
                    ),
                    // Row 3: 4, 5, 6, −
                    Row(
                      children: [
                        _buildButton('4'),
                        _buildButton('5'),
                        _buildButton('6'),
                        _buildButton('−', bgColor: Colors.green[700], fgColor: Colors.white),
                      ],
                    ),
                    // Row 4: 1, 2, 3, +
                    Row(
                      children: [
                        _buildButton('1'),
                        _buildButton('2'),
                        _buildButton('3'),
                        _buildButton('+', bgColor: Colors.green[700], fgColor: Colors.white),
                      ],
                    ),
                    // Row 5: 0, ., =
                    Row(
                      children: [
                        _buildButton('0'),
                        _buildButton('.'),
                        _buildButton('=', bgColor: Colors.green, fgColor: Colors.white),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
