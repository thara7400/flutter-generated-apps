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
  bool _waitingForOperand = false;
  bool _hasError = false;

  void _onButtonPressed(String label) {
    setState(() {
      if (_hasError && label != 'C') return;

      switch (label) {
        case 'C':
          _display = '0';
          _firstOperand = 0;
          _secondOperand = 0;
          _operator = '';
          _waitingForOperand = false;
          _hasError = false;
          break;

        case '±':
          if (_display != '0' && !_hasError) {
            if (_display.startsWith('-')) {
              _display = _display.substring(1);
            } else {
              _display = '-$_display';
            }
          }
          break;

        case '%':
          if (!_hasError) {
            final val = double.tryParse(_display) ?? 0;
            _display = _formatNumber(val / 100);
            _waitingForOperand = false;
          }
          break;

        case '÷':
        case '×':
        case '−':
        case '+':
          if (!_hasError) {
            _firstOperand = double.tryParse(_display) ?? 0;
            _operator = label;
            _waitingForOperand = true;
          }
          break;

        case '=':
          if (_operator.isNotEmpty && !_hasError) {
            _secondOperand = double.tryParse(_display) ?? 0;
            double result;
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
                  _display = 'Error';
                  _hasError = true;
                  _operator = '';
                  _waitingForOperand = false;
                  return;
                }
                result = _firstOperand / _secondOperand;
                break;
              default:
                result = _secondOperand;
            }
            _display = _formatNumber(result);
            _operator = '';
            _waitingForOperand = false;
          }
          break;

        case '.':
          if (_waitingForOperand) {
            _display = '0.';
            _waitingForOperand = false;
          } else if (!_display.contains('.')) {
            _display = '$_display.';
          }
          break;

        default:
          // Numeric digit
          if (_waitingForOperand) {
            _display = label;
            _waitingForOperand = false;
          } else {
            if (_display == '0') {
              _display = label;
            } else {
              if (_display.length < 12) {
                _display = '$_display$label';
              }
            }
          }
          break;
      }
    });
  }

  String _formatNumber(double value) {
    if (value.isInfinite || value.isNaN) return 'Error';
    if (value == value.truncateToDouble()) {
      final intVal = value.toInt();
      return intVal.toString();
    }
    // Limit decimal places
    String result = value.toStringAsFixed(10);
    // Remove trailing zeros after decimal
    result = result.replaceAll(RegExp(r'0+$'), '');
    result = result.replaceAll(RegExp(r'\.$'), '');
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ニケちゃん 電卓',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('ニケちゃん 電卓'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: Column(
          children: [
            // Display area
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                color: Colors.black87,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              child: Container(
                color: Colors.black,
                child: _buildButtonGrid(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonGrid() {
    final List<List<String>> buttonRows = [
      ['C', '±', '%', '÷'],
      ['7', '8', '9', '×'],
      ['4', '5', '6', '−'],
      ['1', '2', '3', '+'],
      ['0', '.', '='],
    ];

    return Column(
      children: buttonRows.map((row) {
        return Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: row.map((label) {
              final isWide = label == '0';
              return Expanded(
                flex: isWide ? 2 : 1,
                child: _buildButton(label),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildButton(String label) {
    Color bgColor;
    Color fgColor = Colors.white;

    if (label == 'C' || label == '±' || label == '%') {
      bgColor = Colors.grey.shade600;
    } else if (label == '÷' || label == '×' || label == '−' || label == '+' || label == '=') {
      bgColor = Colors.orange;
    } else {
      bgColor = Colors.grey.shade800;
    }

    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(4)),
          ),
          padding: EdgeInsets.zero,
          elevation: 0,
        ),
        onPressed: () => _onButtonPressed(label),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
