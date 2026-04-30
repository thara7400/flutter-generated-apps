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
  double? _firstOperand;
  String? _operator;
  bool _shouldResetDisplay = false;
  bool _isError = false;

  void _onButtonPressed(String label) {
    setState(() {
      if (_isError && label != 'C') return;

      if (label == 'C') {
        _display = '0';
        _firstOperand = null;
        _operator = null;
        _shouldResetDisplay = false;
        _isError = false;
        return;
      }

      if (label == '±') {
        if (_display != '0') {
          if (_display.startsWith('-')) {
            _display = _display.substring(1);
          } else {
            _display = '-$_display';
          }
        }
        return;
      }

      if (label == '%') {
        final val = double.tryParse(_display);
        if (val != null) {
          _display = _formatNumber(val / 100);
        }
        return;
      }

      if (label == '÷' || label == '×' || label == '−' || label == '+') {
        _firstOperand = double.tryParse(_display);
        _operator = label;
        _shouldResetDisplay = true;
        return;
      }

      if (label == '=') {
        if (_firstOperand != null && _operator != null) {
          final secondOperand = double.tryParse(_display);
          if (secondOperand == null) return;
          double result;
          switch (_operator!) {
            case '÷':
              if (secondOperand == 0) {
                _display = 'Error';
                _isError = true;
                _firstOperand = null;
                _operator = null;
                _shouldResetDisplay = false;
                return;
              }
              result = _firstOperand! / secondOperand;
              break;
            case '×':
              result = _firstOperand! * secondOperand;
              break;
            case '−':
              result = _firstOperand! - secondOperand;
              break;
            case '+':
              result = _firstOperand! + secondOperand;
              break;
            default:
              return;
          }
          _display = _formatNumber(result);
          _firstOperand = null;
          _operator = null;
          _shouldResetDisplay = true;
        }
        return;
      }

      if (label == '.') {
        if (_shouldResetDisplay) {
          _display = '0.';
          _shouldResetDisplay = false;
          return;
        }
        if (!_display.contains('.')) {
          _display = '$_display.';
        }
        return;
      }

      // Digit
      if (_shouldResetDisplay) {
        _display = label;
        _shouldResetDisplay = false;
      } else {
        if (_display == '0') {
          _display = label;
        } else {
          _display = '$_display$label';
        }
      }
    });
  }

  String _formatNumber(double value) {
    if (value == value.truncateToDouble()) {
      final intVal = value.toInt();
      return intVal.toString();
    }
    String result = value.toString();
    if (result.length > 12) {
      result = value.toStringAsFixed(8).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    }
    return result;
  }

  Color _buttonColor(String label) {
    if (label == 'C' || label == '±' || label == '%') {
      return Colors.pink.shade100;
    } else if (label == '÷' || label == '×' || label == '−' || label == '+' || label == '=') {
      return Colors.pink;
    } else {
      return Colors.pink.shade50;
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
    final List<List<String>> buttons = [
      ['C', '±', '%', '÷'],
      ['7', '8', '9', '×'],
      ['4', '5', '6', '−'],
      ['1', '2', '3', '+'],
      ['0', '.', '='],
    ];

    return MaterialApp(
      title: 'いけちゃん 電卓',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.pink,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('いけちゃん 電卓'),
          backgroundColor: Colors.pink,
          foregroundColor: Colors.white,
        ),
        body: Column(
          children: [
            // Display area
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                color: Colors.grey.shade900,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                alignment: Alignment.centerRight,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    _display,
                    style: TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.w300,
                      color: _isError ? Colors.red.shade300 : Colors.white,
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
                color: Colors.grey.shade100,
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
                              child: SizedBox.expand(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _buttonColor(label),
                                    foregroundColor: _buttonTextColor(label),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 2,
                                    padding: EdgeInsets.zero,
                                  ),
                                  onPressed: () => _onButtonPressed(label),
                                  child: Text(
                                    label,
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w500,
                                    ),
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
