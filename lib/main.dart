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
  bool _hasError = false;

  void _onButtonPressed(String label) {
    setState(() {
      if (label == 'C') {
        _display = '0';
        _firstOperand = 0;
        _secondOperand = 0;
        _operator = '';
        _waitingForSecondOperand = false;
        _hasError = false;
      } else if (_hasError && label != 'C') {
        // Do nothing if there's an error except clear
        return;
      } else if (label == '±') {
        if (_display != '0') {
          if (_display.startsWith('-')) {
            _display = _display.substring(1);
          } else {
            _display = '-$_display';
          }
        }
      } else if (label == '%') {
        final val = double.tryParse(_display) ?? 0;
        _display = _formatNumber(val / 100);
        _waitingForSecondOperand = false;
      } else if (label == '÷' || label == '×' || label == '−' || label == '+') {
        _firstOperand = double.tryParse(_display) ?? 0;
        _operator = label;
        _waitingForSecondOperand = true;
      } else if (label == '=') {
        if (_operator.isEmpty) return;
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
              _waitingForSecondOperand = false;
              return;
            }
            result = _firstOperand / _secondOperand;
            break;
          default:
            return;
        }
        _display = _formatNumber(result);
        _operator = '';
        _waitingForSecondOperand = false;
      } else if (label == '.') {
        if (_waitingForSecondOperand) {
          _display = '0.';
          _waitingForSecondOperand = false;
          return;
        }
        if (!_display.contains('.')) {
          _display = '$_display.';
        }
      } else {
        // Digit
        if (_waitingForSecondOperand) {
          _display = label;
          _waitingForSecondOperand = false;
        } else {
          if (_display == '0') {
            _display = label;
          } else {
            _display = '$_display$label';
          }
        }
      }
    });
  }

  String _formatNumber(double value) {
    if (value == value.truncateToDouble()) {
      // No decimal part needed
      final intVal = value.toInt();
      return intVal.toString();
    } else {
      // Remove trailing zeros
      String s = value.toString();
      return s;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'S5 Step3 Test',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.red,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('S5 Step3 Test'),
          backgroundColor: Colors.red,
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text(
                  _display,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 56,
                    fontWeight: FontWeight.w300,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
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
    final List<List<_ButtonConfig>> rows = [
      [
        _ButtonConfig('C', isFunction: true),
        _ButtonConfig('±', isFunction: true),
        _ButtonConfig('%', isFunction: true),
        _ButtonConfig('÷', isOperator: true),
      ],
      [
        _ButtonConfig('7'),
        _ButtonConfig('8'),
        _ButtonConfig('9'),
        _ButtonConfig('×', isOperator: true),
      ],
      [
        _ButtonConfig('4'),
        _ButtonConfig('5'),
        _ButtonConfig('6'),
        _ButtonConfig('−', isOperator: true),
      ],
      [
        _ButtonConfig('1'),
        _ButtonConfig('2'),
        _ButtonConfig('3'),
        _ButtonConfig('+', isOperator: true),
      ],
      [
        _ButtonConfig('0', isWide: true),
        _ButtonConfig('.'),
        _ButtonConfig('=', isOperator: true),
      ],
    ];

    return Column(
      children: rows.map((row) {
        return Expanded(
          child: Row(
            children: row.map((config) {
              return Expanded(
                flex: config.isWide ? 2 : 1,
                child: _buildButton(config),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildButton(_ButtonConfig config) {
    Color bgColor;
    Color fgColor;

    if (config.isOperator) {
      bgColor = Colors.orange;
      fgColor = Colors.white;
    } else if (config.isFunction) {
      bgColor = Colors.grey.shade700;
      fgColor = Colors.white;
    } else {
      bgColor = Colors.grey.shade900;
      fgColor = Colors.white;
    }

    return Padding(
      padding: const EdgeInsets.all(1.5),
      child: SizedBox.expand(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: bgColor,
            foregroundColor: fgColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.zero,
          ),
          onPressed: () => _onButtonPressed(config.label),
          child: Text(
            config.label,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

class _ButtonConfig {
  final String label;
  final bool isOperator;
  final bool isFunction;
  final bool isWide;

  const _ButtonConfig(
    this.label, {
    this.isOperator = false,
    this.isFunction = false,
    this.isWide = false,
  });
}
