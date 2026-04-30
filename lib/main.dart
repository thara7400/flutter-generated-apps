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
  String _operator = '';
  bool _waitingForSecondOperand = false;
  bool _hasError = false;

  void _onButtonPressed(String label) {
    setState(() {
      if (_hasError && label != 'C') return;

      if (label == 'C') {
        _display = '0';
        _firstOperand = 0;
        _operator = '';
        _waitingForSecondOperand = false;
        _hasError = false;
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
      } else if (label == '.' ) {
        if (_waitingForSecondOperand) {
          _display = '0.';
          _waitingForSecondOperand = false;
          return;
        }
        if (!_display.contains('.')) {
          _display = '$_display.';
        }
      } else if ('0123456789'.contains(label)) {
        if (_waitingForSecondOperand) {
          _display = label;
          _waitingForSecondOperand = false;
        } else {
          _display = (_display == '0') ? label : '$_display$label';
        }
      } else if (label == '÷' || label == '×' || label == '−' || label == '+') {
        _firstOperand = double.tryParse(_display) ?? 0;
        _operator = label;
        _waitingForSecondOperand = true;
      } else if (label == '=') {
        if (_operator.isEmpty) return;
        final secondOperand = double.tryParse(_display) ?? 0;
        double result = 0;
        switch (_operator) {
          case '+':
            result = _firstOperand + secondOperand;
            break;
          case '−':
            result = _firstOperand - secondOperand;
            break;
          case '×':
            result = _firstOperand * secondOperand;
            break;
          case '÷':
            if (secondOperand == 0) {
              _display = 'Error';
              _hasError = true;
              _operator = '';
              _waitingForSecondOperand = false;
              return;
            }
            result = _firstOperand / secondOperand;
            break;
        }
        _display = _formatResult(result);
        _operator = '';
        _waitingForSecondOperand = false;
      }
    });
  }

  String _formatResult(double value) {
    if (value == value.truncateToDouble()) {
      return value.toInt().toString();
    }
    String result = value.toString();
    if (result.length > 12) {
      result = double.parse(value.toStringAsFixed(10)).toString();
    }
    return result;
  }

  Color _buttonColor(String label) {
    if (label == 'C' || label == '±' || label == '%') {
      return Colors.blue.shade100;
    } else if (label == '÷' || label == '×' || label == '−' || label == '+' || label == '=') {
      return Colors.blue;
    } else {
      return Colors.grey.shade200;
    }
  }

  Color _buttonTextColor(String label) {
    if (label == '÷' || label == '×' || label == '−' || label == '+' || label == '=') {
      return Colors.white;
    }
    return Colors.black87;
  }

  @override
  Widget build(BuildContext context) {
    final buttons = [
      ['C', '±', '%', '÷'],
      ['7', '8', '9', '×'],
      ['4', '5', '6', '−'],
      ['1', '2', '3', '+'],
      ['0', '.', '='],
    ];

    return MaterialApp(
      title: 'でんたく',
      theme: ThemeData(useMaterial3: true),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('でんたく'),
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
                color: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                alignment: Alignment.centerRight,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    _display,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 64,
                      fontWeight: FontWeight.w300,
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
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: buttons.map((row) {
                    return Expanded(
                      child: Row(
                        children: row.map((label) {
                          final isZero = label == '0';
                          return Expanded(
                            flex: isZero ? 2 : 1,
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: ElevatedButton(
                                onPressed: () => _onButtonPressed(label),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _buttonColor(label),
                                  foregroundColor: _buttonTextColor(label),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  elevation: 2,
                                  padding: EdgeInsets.zero,
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
                          );
                        }).toList(),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
