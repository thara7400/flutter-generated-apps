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
  double _operand1 = 0;
  double _operand2 = 0;
  String _operator = '';
  bool _shouldResetDisplay = false;
  bool _hasError = false;
  bool _justEvaluated = false;

  void _onButtonPressed(String label) {
    HapticFeedback.lightImpact();

    if (_hasError && label != 'C') return;

    if (label == 'C') {
      _clear();
    } else if (label == '±') {
      _toggleSign();
    } else if (label == '%') {
      _percentage();
    } else if (label == '÷' || label == '×' || label == '−' || label == '+') {
      _setOperator(label);
    } else if (label == '=') {
      _evaluate();
    } else if (label == '.') {
      _addDecimal();
    } else {
      _appendDigit(label);
    }
  }

  void _clear() {
    setState(() {
      _display = '0';
      _operand1 = 0;
      _operand2 = 0;
      _operator = '';
      _shouldResetDisplay = false;
      _hasError = false;
      _justEvaluated = false;
    });
  }

  void _toggleSign() {
    setState(() {
      if (_display == '0' || _display == '-0') return;
      if (_display.startsWith('-')) {
        _display = _display.substring(1);
      } else {
        _display = '-$_display';
      }
    });
  }

  void _percentage() {
    setState(() {
      final value = double.tryParse(_display);
      if (value == null) return;
      _display = _formatResult(value / 100);
    });
  }

  void _setOperator(String op) {
    setState(() {
      if (_operator.isNotEmpty && !_shouldResetDisplay) {
        _evaluate(keepOperator: true);
        _operator = op;
        _shouldResetDisplay = true;
        return;
      }
      _operand1 = double.tryParse(_display) ?? 0;
      _operator = op;
      _shouldResetDisplay = true;
      _justEvaluated = false;
    });
  }

  void _evaluate({bool keepOperator = false}) {
    if (_operator.isEmpty) return;

    setState(() {
      _operand2 = double.tryParse(_display) ?? 0;
      double result;

      switch (_operator) {
        case '+':
          result = _operand1 + _operand2;
          break;
        case '−':
          result = _operand1 - _operand2;
          break;
        case '×':
          result = _operand1 * _operand2;
          break;
        case '÷':
          if (_operand2 == 0) {
            _display = 'Error';
            _hasError = true;
            _operator = '';
            _shouldResetDisplay = true;
            return;
          }
          result = _operand1 / _operand2;
          break;
        default:
          return;
      }

      _display = _formatResult(result);
      if (!keepOperator) {
        _operand1 = result;
        _operator = '';
        _justEvaluated = true;
        _shouldResetDisplay = true;
      } else {
        _operand1 = result;
        _shouldResetDisplay = true;
      }
    });
  }

  void _addDecimal() {
    setState(() {
      if (_shouldResetDisplay) {
        _display = '0.';
        _shouldResetDisplay = false;
        return;
      }
      if (!_display.contains('.')) {
        _display = '$_display.';
      }
    });
  }

  void _appendDigit(String digit) {
    setState(() {
      if (_shouldResetDisplay || _display == '0') {
        _display = digit;
        _shouldResetDisplay = false;
        _justEvaluated = false;
      } else {
        if (_display.length >= 15) return;
        _display = '$_display$digit';
      }
    });
  }

  String _formatResult(double value) {
    if (value == value.truncateToDouble() && value.abs() < 1e12) {
      return value.toInt().toString();
    }
    String result = value.toStringAsPrecision(10).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '簡単デンタル',
      theme: ThemeData(useMaterial3: true),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('簡単デンタル'),
          backgroundColor: Colors.blue,
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
                  width: double.infinity,
                  color: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  alignment: Alignment.bottomRight,
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
                child: Container(
                  color: Colors.black,
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      _buildRow(['C', '±', '%', '÷'], isTopRow: true),
                      _buildRow(['7', '8', '9', '×']),
                      _buildRow(['4', '5', '6', '−']),
                      _buildRow(['1', '2', '3', '+']),
                      _buildBottomRow(),
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

  Widget _buildRow(List<String> labels, {bool isTopRow = false}) {
    return Expanded(
      child: Row(
        children: labels.map((label) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: _buildButton(label, isTopRow: isTopRow),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBottomRow() {
    return Expanded(
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: _buildButton('0', isWide: true),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: _buildButton('.'),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: _buildButton('='),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String label, {bool isTopRow = false, bool isWide = false}) {
    Color bgColor;
    Color fgColor;

    if (label == 'C' || label == '±' || label == '%') {
      bgColor = Colors.grey.shade600;
      fgColor = Colors.white;
    } else if (label == '÷' || label == '×' || label == '−' || label == '+' || label == '=') {
      bgColor = Colors.orange;
      fgColor = Colors.white;
    } else {
      bgColor = Colors.grey.shade800;
      fgColor = Colors.white;
    }

    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: ElevatedButton(
        onPressed: () => _onButtonPressed(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          padding: EdgeInsets.zero,
          elevation: 2,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: isWide ? 28 : 26,
            fontWeight: FontWeight.w400,
            color: fgColor,
          ),
          textAlign: isWide ? TextAlign.left : TextAlign.center,
        ),
      ),
    );
  }
}
