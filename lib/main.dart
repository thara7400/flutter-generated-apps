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
  bool _shouldResetDisplay = false;
  bool _isError = false;

  void _onButtonPressed(String label) {
    setState(() {
      if (_isError && label != 'C') return;

      if (label == 'C') {
        _display = '0';
        _firstOperand = 0;
        _secondOperand = 0;
        _operator = '';
        _shouldResetDisplay = false;
        _isError = false;
      } else if (label == '±') {
        if (_display != '0') {
          if (_display.startsWith('-')) {
            _display = _display.substring(1);
          } else {
            _display = '-$_display';
          }
        }
      } else if (label == '%') {
        final value = double.tryParse(_display) ?? 0;
        _display = _formatResult(value / 100);
        _shouldResetDisplay = true;
      } else if (label == '÷' || label == '×' || label == '−' || label == '+') {
        _firstOperand = double.tryParse(_display) ?? 0;
        _operator = label;
        _shouldResetDisplay = true;
      } else if (label == '=') {
        if (_operator.isNotEmpty) {
          _secondOperand = double.tryParse(_display) ?? 0;
          double result = 0;
          bool error = false;

          switch (_operator) {
            case '+':
              result = _firstOperand + _secondOperand;
              break;
            case '−':
              result = _firstOperand - _secondOperand;
              break;
            case '×':
              result = _firstOperand * _secondOperand;
              break;
            case '÷':
              if (_secondOperand == 0) {
                error = true;
              } else {
                result = _firstOperand / _secondOperand;
              }
              break;
          }

          if (error) {
            _display = 'Error';
            _isError = true;
          } else {
            _display = _formatResult(result);
          }

          _operator = '';
          _shouldResetDisplay = true;
        }
      } else if (label == '.') {
        if (_shouldResetDisplay) {
          _display = '0.';
          _shouldResetDisplay = false;
        } else if (!_display.contains('.')) {
          _display = '$_display.';
        }
      } else {
        // Digit
        if (_shouldResetDisplay) {
          _display = label;
          _shouldResetDisplay = false;
        } else {
          _display = _display == '0' ? label : '$_display$label';
        }
      }
    });
  }

  String _formatResult(double value) {
    if (value == value.truncateToDouble()) {
      final intVal = value.toInt();
      return intVal.toString();
    }
    // Limit decimal places to avoid floating point noise
    String result = value.toStringAsFixed(10);
    result = result.replaceAll(RegExp(r'0+$'), '');
    result = result.replaceAll(RegExp(r'\.$'), '');
    return result;
  }

  Widget _buildButton(String label, {Color? bgColor, Color? fgColor}) {
    return Expanded(
      flex: label == '0' ? 2 : 1,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: bgColor ?? Colors.grey[200],
            foregroundColor: fgColor ?? Colors.black87,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w500,
            ),
          ),
          onPressed: () => _onButtonPressed(label),
          child: Text(label),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('楽しい電卓'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: Column(
          children: [
            // Display area
            Expanded(
              flex: 2,
              child: Container(
                color: Colors.black,
                alignment: Alignment.bottomRight,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Text(
                  _display,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: _isError ? Colors.red[300] : Colors.white,
                    fontSize: 56,
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
              child: Container(
                color: Colors.grey[100],
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    // Row 1: C, ±, %, ÷
                    Expanded(
                      child: Row(
                        children: [
                          _buildButton('C', bgColor: Colors.grey[400], fgColor: Colors.black),
                          _buildButton('±', bgColor: Colors.grey[400], fgColor: Colors.black),
                          _buildButton('%', bgColor: Colors.grey[400], fgColor: Colors.black),
                          _buildButton('÷', bgColor: Colors.orange, fgColor: Colors.white),
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
                          _buildButton('×', bgColor: Colors.orange, fgColor: Colors.white),
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
                          _buildButton('−', bgColor: Colors.orange, fgColor: Colors.white),
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
                          _buildButton('+', bgColor: Colors.orange, fgColor: Colors.white),
                        ],
                      ),
                    ),
                    // Row 5: 0 (wide), ., =
                    Expanded(
                      child: Row(
                        children: [
                          _buildButton('0'),
                          _buildButton('.'),
                          _buildButton('=', bgColor: Colors.orange, fgColor: Colors.white),
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
