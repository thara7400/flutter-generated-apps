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

      switch (label) {
        case 'C':
          _display = '0';
          _firstOperand = 0;
          _secondOperand = 0;
          _operator = '';
          _shouldResetDisplay = false;
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
          final current = double.tryParse(_display) ?? 0;
          _display = _formatNumber(current / 100);
          break;

        case '.':
          if (_shouldResetDisplay) {
            _display = '0.';
            _shouldResetDisplay = false;
          } else if (!_display.contains('.')) {
            _display = '$_display.';
          }
          break;

        case '÷':
        case '×':
        case '−':
        case '+':
          _firstOperand = double.tryParse(_display) ?? 0;
          _operator = label;
          _shouldResetDisplay = true;
          break;

        case '=':
          if (_operator.isEmpty) break;
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
                _isError = true;
                _operator = '';
                _shouldResetDisplay = true;
                return;
              }
              result = _firstOperand / _secondOperand;
              break;
            default:
              return;
          }
          _display = _formatNumber(result);
          _operator = '';
          _shouldResetDisplay = true;
          break;

        default:
          // Digit
          if (_shouldResetDisplay) {
            _display = label;
            _shouldResetDisplay = false;
          } else {
            _display = _display == '0' ? label : '$_display$label';
          }
          break;
      }
    });
  }

  String _formatNumber(double value) {
    if (value == value.truncateToDouble()) {
      return value.toInt().toString();
    }
    // Limit decimal places to avoid overflow
    String result = value.toString();
    if (result.length > 12) {
      result = value.toStringAsFixed(6);
      // Remove trailing zeros
      result = result.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    }
    return result;
  }

  Color _buttonColor(String label) {
    if (label == 'C' || label == '±' || label == '%') {
      return Colors.pink.shade100;
    } else if (label == '÷' || label == '×' || label == '−' || label == '+' || label == '=') {
      return Colors.pink;
    }
    return Colors.grey.shade200;
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
      title: 'Webhook',
      theme: ThemeData(useMaterial3: true),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Webhook'),
          backgroundColor: Colors.pink,
          foregroundColor: Colors.white,
        ),
        body: Column(
          children: [
            // Display Area
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                color: Colors.grey.shade900,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                alignment: Alignment.centerRight,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    _display,
                    style: TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.w300,
                      color: _isError ? Colors.red.shade300 : Colors.white,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ),
            ),
            // Button Grid
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
                          final isZero = label == '0' && row.length == 3;
                          return Expanded(
                            flex: isZero ? 2 : 1,
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: SizedBox(
                                double.infinity,
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
                                      fontSize: 24,
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
