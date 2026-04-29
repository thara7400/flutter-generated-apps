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
  double _firstOperand = 0;
  double _secondOperand = 0;
  String _operator = '';
  bool _waitingForSecondOperand = false;
  bool _justCalculated = false;

  void _onButtonPressed(String label) {
    setState(() {
      if (label == 'C') {
        _display = '0';
        _firstOperand = 0;
        _secondOperand = 0;
        _operator = '';
        _waitingForSecondOperand = false;
        _justCalculated = false;
      } else if (label == '±') {
        if (_display != '0' && _display != 'Error') {
          if (_display.startsWith('-')) {
            _display = _display.substring(1);
          } else {
            _display = '-$_display';
          }
        }
      } else if (label == '%') {
        if (_display != 'Error') {
          final value = double.tryParse(_display) ?? 0;
          _display = _formatResult(value / 100);
          _justCalculated = true;
        }
      } else if (label == '÷' || label == '×' || label == '−' || label == '+') {
        if (_display == 'Error') return;
        if (_operator.isNotEmpty && _waitingForSecondOperand) {
          _operator = label;
          return;
        }
        if (_operator.isNotEmpty && !_waitingForSecondOperand) {
          _secondOperand = double.tryParse(_display) ?? 0;
          final result = _calculate(_firstOperand, _secondOperand, _operator);
          if (result == null) {
            _display = 'Error';
            _operator = '';
            _waitingForSecondOperand = false;
            return;
          }
          _firstOperand = result;
          _display = _formatResult(result);
        } else {
          _firstOperand = double.tryParse(_display) ?? 0;
        }
        _operator = label;
        _waitingForSecondOperand = true;
        _justCalculated = false;
      } else if (label == '=') {
        if (_display == 'Error') return;
        if (_operator.isEmpty) return;
        _secondOperand = double.tryParse(_display) ?? 0;
        final result = _calculate(_firstOperand, _secondOperand, _operator);
        if (result == null) {
          _display = 'Error';
        } else {
          _display = _formatResult(result);
          _firstOperand = result;
        }
        _operator = '';
        _waitingForSecondOperand = false;
        _justCalculated = true;
      } else if (label == '.') {
        if (_display == 'Error') return;
        if (_waitingForSecondOperand) {
          _display = '0.';
          _waitingForSecondOperand = false;
          return;
        }
        if (_justCalculated) {
          _display = '0.';
          _justCalculated = false;
          return;
        }
        if (!_display.contains('.')) {
          _display = '$_display.';
        }
      } else {
        // Digit
        if (_display == 'Error') {
          _display = label;
          return;
        }
        if (_waitingForSecondOperand) {
          _display = label;
          _waitingForSecondOperand = false;
          _justCalculated = false;
          return;
        }
        if (_justCalculated) {
          _display = label;
          _justCalculated = false;
          return;
        }
        if (_display == '0') {
          _display = label;
        } else if (_display == '-0') {
          _display = '-$label';
        } else {
          _display = '$_display$label';
        }
      }
    });
  }

  double? _calculate(double a, double b, String op) {
    switch (op) {
      case '+':
        return a + b;
      case '−':
        return a - b;
      case '×':
        return a * b;
      case '÷':
        if (b == 0) return null;
        return a / b;
    }
    return null;
  }

  String _formatResult(double value) {
    if (value.isNaN || value.isInfinite) return 'Error';
    if (value == value.truncateToDouble()) {
      final intVal = value.toInt();
      return intVal.toString();
    }
    String result = value.toString();
    // Limit decimal places to avoid overly long numbers
    if (result.contains('.')) {
      final parts = result.split('.');
      if (parts[1].length > 9) {
        result = value.toStringAsFixed(9);
        // Remove trailing zeros
        result = result.replaceAll(RegExp(r'0+$'), '');
        result = result.replaceAll(RegExp(r'\.$'), '');
      }
    }
    return result;
  }

  Widget _buildButton(String label, {Color? bgColor, Color? fgColor}) {
    return Expanded(
      flex: label == '0' ? 2 : 1,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: ElevatedButton(
          onPressed: () => _onButtonPressed(label),
          style: ElevatedButton.styleFrom(
            backgroundColor: bgColor ?? Colors.grey[200],
            foregroundColor: fgColor ?? Colors.black87,
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
            textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
          ),
          child: Text(label),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Calc',
      theme: ThemeData(useMaterial3: true),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('My Calc'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        backgroundColor: Colors.grey[100],
        body: Column(
          children: [
            // Display area
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                color: Colors.black87,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                alignment: Alignment.centerRight,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    _display,
                    style: const TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.right,
                  ),
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
                    Expanded(
                      child: Row(
                        children: [
                          _buildButton('C',
                              bgColor: Colors.orange[200],
                              fgColor: Colors.black87),
                          _buildButton('±',
                              bgColor: Colors.grey[400],
                              fgColor: Colors.black87),
                          _buildButton('%',
                              bgColor: Colors.grey[400],
                              fgColor: Colors.black87),
                          _buildButton('÷',
                              bgColor: Colors.blue,
                              fgColor: Colors.white),
                        ],
                      ),
                    ),
                    // Row 2: 7, 8, 9, ×
                    Expanded(
                      child: Row(
                        children: [
                          _buildButton('7'),
                          _buildButton('8'),
                          _buildButton('9'),
                          _buildButton('×',
                              bgColor: Colors.blue,
                              fgColor: Colors.white),
                        ],
                      ),
                    ),
                    // Row 3: 4, 5, 6, −
                    Expanded(
                      child: Row(
                        children: [
                          _buildButton('4'),
                          _buildButton('5'),
                          _buildButton('6'),
                          _buildButton('−',
                              bgColor: Colors.blue,
                              fgColor: Colors.white),
                        ],
                      ),
                    ),
                    // Row 4: 1, 2, 3, +
                    Expanded(
                      child: Row(
                        children: [
                          _buildButton('1'),
                          _buildButton('2'),
                          _buildButton('3'),
                          _buildButton('+',
                              bgColor: Colors.blue,
                              fgColor: Colors.white),
                        ],
                      ),
                    ),
                    // Row 5: 0 (wide), ., =
                    Expanded(
                      child: Row(
                        children: [
                          _buildButton('0',
                              bgColor: Colors.grey[200],
                              fgColor: Colors.black87),
                          _buildButton('.',
                              bgColor: Colors.grey[200],
                              fgColor: Colors.black87),
                          _buildButton('=',
                              bgColor: Colors.blue,
                              fgColor: Colors.white),
                        ],
                      ),
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
