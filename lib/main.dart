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
        final val = double.tryParse(_display) ?? 0;
        _display = _formatNumber(val / 100);
      } else if (label == '÷' || label == '×' || label == '−' || label == '+') {
        _firstOperand = double.tryParse(_display) ?? 0;
        _operator = label;
        _waitingForSecondOperand = true;
      } else if (label == '=') {
        if (_operator.isNotEmpty && !_waitingForSecondOperand) {
          final second = double.tryParse(_display) ?? 0;
          double result = 0;
          bool error = false;

          switch (_operator) {
            case '+':
              result = _firstOperand + second;
              break;
            case '−':
              result = _firstOperand - second;
              break;
            case '×':
              result = _firstOperand * second;
              break;
            case '÷':
              if (second == 0) {
                error = true;
              } else {
                result = _firstOperand / second;
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
          _waitingForSecondOperand = false;
        }
      } else if (label == '.') {
        if (_waitingForSecondOperand) {
          _display = '0.';
          _waitingForSecondOperand = false;
        } else if (!_display.contains('.')) {
          _display = '$_display.';
        }
      } else {
        // digit
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
      // Integer result – show without decimal point if possible
      final intVal = value.toInt();
      return intVal.toString();
    }
    // Remove trailing zeros
    String s = value.toString();
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
        body: Column(
          children: [
            // Display area
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                color: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
    final List<List<String>> rows = [
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
              final isWide = label == '0';
              return Expanded(
                flex: isWide ? 2 : 1,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _onButtonPressed(label),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _getButtonColor(label),
                        foregroundColor: _getButtonTextColor(label),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      child: Text(
                        label,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }

  Color _getButtonColor(String label) {
    if (label == 'C' || label == '±' || label == '%') {
      return Colors.grey.shade600;
    } else if (label == '÷' || label == '×' || label == '−' || label == '+' || label == '=') {
      return Colors.orange;
    } else {
      return Colors.grey.shade800;
    }
  }

  Color _getButtonTextColor(String label) {
    return Colors.white;
  }
}
