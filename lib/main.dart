import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  bool _hasResult = false;

  void _onButtonPressed(String label) {
    HapticFeedback.lightImpact();

    if (label == 'C') {
      _clear();
    } else if (label == '±') {
      _toggleSign();
    } else if (label == '%') {
      _percentage();
    } else if (label == '÷' || label == '×' || label == '−' || label == '+') {
      _setOperator(label);
    } else if (label == '=') {
      _calculate();
    } else if (label == '.') {
      _inputDecimal();
    } else {
      _inputDigit(label);
    }
  }

  void _clear() {
    setState(() {
      _display = '0';
      _firstOperand = 0;
      _secondOperand = 0;
      _operator = '';
      _waitingForSecondOperand = false;
      _hasResult = false;
    });
  }

  void _toggleSign() {
    setState(() {
      if (_display == 'Error') return;
      double value = double.tryParse(_display) ?? 0;
      value = -value;
      _display = _formatNumber(value);
    });
  }

  void _percentage() {
    setState(() {
      if (_display == 'Error') return;
      double value = double.tryParse(_display) ?? 0;
      value = value / 100;
      _display = _formatNumber(value);
    });
  }

  void _setOperator(String op) {
    setState(() {
      if (_display == 'Error') return;
      if (_operator.isNotEmpty && !_waitingForSecondOperand) {
        _calculate(settingNewOperator: true);
        if (_display == 'Error') return;
      }
      _firstOperand = double.tryParse(_display) ?? 0;
      _operator = op;
      _waitingForSecondOperand = true;
      _hasResult = false;
    });
  }

  void _calculate({bool settingNewOperator = false}) {
    if (_operator.isEmpty) return;

    double second = double.tryParse(_display) ?? 0;
    if (_waitingForSecondOperand) {
      second = _firstOperand;
    }
    _secondOperand = second;

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

    setState(() {
      if (error) {
        _display = 'Error';
        _operator = '';
        _waitingForSecondOperand = false;
        _hasResult = false;
      } else {
        _display = _formatNumber(result);
        if (!settingNewOperator) {
          _firstOperand = result;
          _operator = '';
          _waitingForSecondOperand = false;
          _hasResult = true;
        } else {
          _firstOperand = result;
        }
      }
    });
  }

  void _inputDecimal() {
    setState(() {
      if (_display == 'Error') return;
      if (_waitingForSecondOperand || _hasResult) {
        _display = '0.';
        _waitingForSecondOperand = false;
        _hasResult = false;
        return;
      }
      if (!_display.contains('.')) {
        _display = '$_display.';
      }
    });
  }

  void _inputDigit(String digit) {
    setState(() {
      if (_display == 'Error') {
        _display = digit;
        _operator = '';
        _waitingForSecondOperand = false;
        _hasResult = false;
        return;
      }
      if (_waitingForSecondOperand || _hasResult) {
        _display = digit;
        _waitingForSecondOperand = false;
        _hasResult = false;
      } else {
        _display = _display == '0' ? digit : _display + digit;
      }
    });
  }

  String _formatNumber(double value) {
    if (value == value.truncateToDouble()) {
      return value.toInt().toString();
    }
    // Trim unnecessary trailing zeros after decimal
    String result = value.toString();
    return result;
  }

  // Button layout definition
  static const List<List<String>> _buttons = [
    ['C', '±', '%', '÷'],
    ['7', '8', '9', '×'],
    ['4', '5', '6', '−'],
    ['1', '2', '3', '+'],
    ['0', '.', '='],
  ];

  Color _buttonColor(String label) {
    if (label == 'C' || label == '±' || label == '%') {
      return Colors.blueGrey.shade200;
    } else if (label == '÷' || label == '×' || label == '−' || label == '+' || label == '=') {
      return Colors.blue;
    }
    return Colors.grey.shade800;
  }

  Color _buttonTextColor(String label) {
    if (label == 'C' || label == '±' || label == '%') {
      return Colors.black87;
    }
    return Colors.white;
  }

  Widget _buildButton(String label, {bool wide = false}) {
    return Expanded(
      flex: wide ? 2 : 1,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: ElevatedButton(
          onPressed: () => _onButtonPressed(label),
          style: ElevatedButton.styleFrom(
            backgroundColor: _buttonColor(label),
            foregroundColor: _buttonTextColor(label),
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonRow(List<String> labels) {
    // The last row has '0' as wide button
    if (labels.contains('0') && labels.length == 3) {
      return Row(
        children: [
          _buildButton('0', wide: true),
          _buildButton('.'),
          _buildButton('='),
        ],
      );
    }
    return Row(
      children: labels.map((l) => _buildButton(l)).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '電卓',
      theme: ThemeData(useMaterial3: true),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('電卓'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        backgroundColor: Colors.grey.shade900,
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
                  style: TextStyle(
                    fontSize: _display.length > 10 ? 36 : 56,
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const Divider(color: Colors.grey, height: 1),
            // Button grid
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: _buttons
                      .map((row) => Expanded(child: _buildButtonRow(row)))
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
