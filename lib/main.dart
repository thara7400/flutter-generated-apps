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
  bool _hasError = false;

  void _onButtonPressed(String label) {
    setState(() {
      if (_hasError && label != 'C') return;

      if (label == 'C') {
        _display = '0';
        _firstOperand = 0;
        _secondOperand = 0;
        _operator = '';
        _shouldResetDisplay = false;
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
        _display = _formatNumber(value / 100);
        _shouldResetDisplay = true;
      } else if (label == '÷' || label == '×' || label == '−' || label == '+') {
        _firstOperand = double.tryParse(_display) ?? 0;
        _operator = label;
        _shouldResetDisplay = true;
      } else if (label == '=') {
        if (_operator.isEmpty) return;
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
          _hasError = true;
        } else {
          _display = _formatNumber(result);
        }
        _operator = '';
        _shouldResetDisplay = true;
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
          if (_display == '0') {
            _display = label;
          } else {
            if (_display.length < 15) {
              _display = '$_display$label';
            }
          }
        }
      }
    });
  }

  String _formatNumber(double value) {
    if (value == value.truncateToDouble()) {
      final intValue = value.toInt();
      return intValue.toString();
    } else {
      String str = value.toString();
      return str;
    }
  }

  Widget _buildButton({
    required String label,
    Color? backgroundColor,
    Color? foregroundColor,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: ElevatedButton(
          onPressed: () => _onButtonPressed(label),
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? Colors.grey[800],
            foregroundColor: foregroundColor ?? Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
            padding: const EdgeInsets.symmetric(vertical: 20),
            textStyle: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w500,
            ),
            elevation: 2,
          ),
          child: Text(label),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ニケちゃん',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.red,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('ニケちゃん'),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(
            children: [
              // Display area
              Expanded(
                flex: 2,
                child: Container(
                  alignment: Alignment.bottomRight,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      _display,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 72,
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
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      // Row 1: C, ±, %, ÷
                      Expanded(
                        child: Row(
                          children: [
                            _buildButton(
                              label: 'C',
                              backgroundColor: Colors.grey[500],
                              foregroundColor: Colors.black,
                            ),
                            _buildButton(
                              label: '±',
                              backgroundColor: Colors.grey[500],
                              foregroundColor: Colors.black,
                            ),
                            _buildButton(
                              label: '%',
                              backgroundColor: Colors.grey[500],
                              foregroundColor: Colors.black,
                            ),
                            _buildButton(
                              label: '÷',
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                            ),
                          ],
                        ),
                      ),
                      // Row 2: 7, 8, 9, ×
                      Expanded(
                        child: Row(
                          children: [
                            _buildButton(label: '7'),
                            _buildButton(label: '8'),
                            _buildButton(label: '9'),
                            _buildButton(
                              label: '×',
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                            ),
                          ],
                        ),
                      ),
                      // Row 3: 4, 5, 6, −
                      Expanded(
                        child: Row(
                          children: [
                            _buildButton(label: '4'),
                            _buildButton(label: '5'),
                            _buildButton(label: '6'),
                            _buildButton(
                              label: '−',
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                            ),
                          ],
                        ),
                      ),
                      // Row 4: 1, 2, 3, +
                      Expanded(
                        child: Row(
                          children: [
                            _buildButton(label: '1'),
                            _buildButton(label: '2'),
                            _buildButton(label: '3'),
                            _buildButton(
                              label: '+',
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                            ),
                          ],
                        ),
                      ),
                      // Row 5: 0, ., =
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: ElevatedButton(
                                  onPressed: () => _onButtonPressed('0'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey[800],
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 20),
                                    textStyle: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    alignment: Alignment.centerLeft,
                                    elevation: 2,
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.only(left: 24),
                                    child: Text('0'),
                                  ),
                                ),
                              ),
                            ),
                            _buildButton(label: '.'),
                            _buildButton(
                              label: '=',
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                            ),
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
      ),
    );
  }
}
