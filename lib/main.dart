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
  String _input = '';
  double _firstOperand = 0;
  String _operator = '';
  bool _waitingForSecond = false;
  bool _hasResult = false;

  void _onButton(String label) {
    HapticFeedback.lightImpact();
    setState(() {
      if (label == 'C') {
        _display = '0';
        _input = '';
        _firstOperand = 0;
        _operator = '';
        _waitingForSecond = false;
        _hasResult = false;
      } else if (label == '±') {
        if (_display != '0' && _display != 'Error') {
          if (_display.startsWith('-')) {
            _display = _display.substring(1);
          } else {
            _display = '-$_display';
          }
          _input = _display;
        }
      } else if (label == '%') {
        if (_display != 'Error') {
          final val = double.tryParse(_display);
          if (val != null) {
            _display = _formatNumber(val / 100);
            _input = _display;
          }
        }
      } else if (label == '÷' || label == '×' || label == '−' || label == '+') {
        if (_display == 'Error') return;
        if (_operator.isNotEmpty && _waitingForSecond) {
          _operator = label;
          return;
        }
        if (_operator.isNotEmpty && !_waitingForSecond) {
          _calculate();
        }
        _firstOperand = double.tryParse(_display) ?? 0;
        _operator = label;
        _waitingForSecond = true;
        _hasResult = false;
      } else if (label == '=') {
        if (_display == 'Error') return;
        if (_operator.isEmpty) return;
        _calculate();
        _operator = '';
        _waitingForSecond = false;
        _hasResult = true;
      } else if (label == '.') {
        if (_display == 'Error') {
          _display = '0.';
          _input = _display;
          _waitingForSecond = false;
          _hasResult = false;
          return;
        }
        if (_hasResult) {
          _display = '0.';
          _input = _display;
          _hasResult = false;
          return;
        }
        if (_waitingForSecond) {
          _display = '0.';
          _input = _display;
          _waitingForSecond = false;
          return;
        }
        if (!_display.contains('.')) {
          _display = '$_display.';
          _input = _display;
        }
      } else {
        // digit
        if (_display == 'Error') {
          _display = label;
          _input = _display;
          _waitingForSecond = false;
          _hasResult = false;
          return;
        }
        if (_hasResult) {
          _display = label;
          _input = _display;
          _operator = '';
          _firstOperand = 0;
          _hasResult = false;
          return;
        }
        if (_waitingForSecond) {
          _display = label;
          _input = _display;
          _waitingForSecond = false;
        } else {
          if (_display == '0' && label != '.') {
            _display = label;
          } else {
            if (_display.length < 15) {
              _display = '$_display$label';
            }
          }
          _input = _display;
        }
      }
    });
  }

  void _calculate() {
    final second = double.tryParse(_display) ?? 0;
    double result;
    if (_operator == '÷') {
      if (second == 0) {
        _display = 'Error';
        return;
      }
      result = _firstOperand / second;
    } else if (_operator == '×') {
      result = _firstOperand * second;
    } else if (_operator == '−') {
      result = _firstOperand - second;
    } else if (_operator == '+') {
      result = _firstOperand + second;
    } else {
      return;
    }
    _display = _formatNumber(result);
    _input = _display;
  }

  String _formatNumber(double value) {
    if (value.isInfinite || value.isNaN) return 'Error';
    if (value == value.truncateToDouble() &&
        value.abs() < 1e15) {
      final intVal = value.toInt();
      return intVal.toString();
    }
    String s = value.toStringAsFixed(10);
    s = s.replaceAll(RegExp(r'0+$'), '');
    s = s.replaceAll(RegExp(r'\.$'), '');
    return s;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'マイ電卓',
      theme: ThemeData(useMaterial3: true),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('マイ電卓'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        backgroundColor: Colors.black,
        body: Column(
          children: [
            // Display area
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                color: Colors.black,
                alignment: Alignment.centerRight,
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
    const rows = [
      ['C', '±', '%', '÷'],
      ['7', '8', '9', '×'],
      ['4', '5', '6', '−'],
      ['1', '2', '3', '+'],
      ['0', '.', '='],
    ];

    return Column(
      children: rows.map((row) {
        return Expanded(
          child: Row(
            children: row.map((label) {
              final flex = (label == '0') ? 2 : 1;
              return Expanded(
                flex: flex,
                child: _CalcButton(
                  label: label,
                  onTap: () => _onButton(label),
                  style: _buttonStyle(label),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }

  _ButtonStyle _buttonStyle(String label) {
    if (label == 'C' || label == '±' || label == '%') {
      return _ButtonStyle.function;
    }
    if (label == '÷' || label == '×' || label == '−' || label == '+' || label == '=') {
      return _ButtonStyle.operator;
    }
    return _ButtonStyle.number;
  }
}

enum _ButtonStyle { number, operator, function }

class _CalcButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final _ButtonStyle style;

  const _CalcButton({
    required this.label,
    required this.onTap,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color fgColor;

    switch (style) {
      case _ButtonStyle.function:
        bgColor = const Color(0xFFA5A5A5);
        fgColor = Colors.black;
        break;
      case _ButtonStyle.operator:
        bgColor = const Color(0xFFFF9F0A);
        fgColor = Colors.white;
        break;
      case _ButtonStyle.number:
        bgColor = const Color(0xFF333333);
        fgColor = Colors.white;
        break;
    }

    return Padding(
      padding: const EdgeInsets.all(4),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          padding: EdgeInsets.zero,
          elevation: 0,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w400,
              color: fgColor,
            ),
          ),
        ),
      ),
    );
  }
}
