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
  bool _hasOperator = false;
  bool _justEvaluated = false;
  bool _isError = false;

  void _onButtonPressed(String label) {
    setState(() {
      if (_isError && label != 'C') return;

      if (label == 'C') {
        _display = '0';
        _firstOperand = 0;
        _secondOperand = 0;
        _operator = '';
        _hasOperator = false;
        _justEvaluated = false;
        _isError = false;
      } else if (label == '±') {
        if (_display != '0' && _display != 'Error') {
          if (_display.startsWith('-')) {
            _display = _display.substring(1);
          } else {
            _display = '-$_display';
          }
        }
      } else if (label == '%') {
        double val = double.tryParse(_display) ?? 0;
        _display = _formatResult(val / 100);
        _justEvaluated = true;
      } else if (label == '÷' || label == '×' || label == '−' || label == '+') {
        _firstOperand = double.tryParse(_display) ?? 0;
        _operator = label;
        _hasOperator = true;
        _justEvaluated = false;
        _display = '0';
      } else if (label == '=') {
        if (_hasOperator) {
          _secondOperand = double.tryParse(_display) ?? 0;
          double result = 0;
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
                _hasOperator = false;
                _justEvaluated = true;
                return;
              }
              result = _firstOperand / _secondOperand;
              break;
          }
          _display = _formatResult(result);
          _hasOperator = false;
          _justEvaluated = true;
        }
      } else if (label == '.') {
        if (_justEvaluated) {
          _display = '0.';
          _justEvaluated = false;
        } else if (!_display.contains('.')) {
          _display = '$_display.';
        }
      } else {
        // digit
        if (_display == '0' || _justEvaluated) {
          _display = label;
          _justEvaluated = false;
        } else {
          if (_display.length < 12) {
            _display = '$_display$label';
          }
        }
      }
    });
  }

  String _formatResult(double value) {
    if (value == value.truncateToDouble()) {
      String intStr = value.toInt().toString();
      return intStr;
    } else {
      String result = value.toString();
      if (result.length > 12) {
        result = value.toStringAsFixed(8);
        // trim trailing zeros
        result = result.replaceAll(RegExp(r'0+$'), '');
        result = result.replaceAll(RegExp(r'\.$'), '');
      }
      return result;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '簡単 電卓 アプリ',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.purple,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('簡単 電卓 アプリ'),
          backgroundColor: Colors.purple,
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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                alignment: Alignment.centerRight,
                child: Text(
                  _display,
                  style: TextStyle(
                    fontSize: _display.length > 10 ? 36 : 56,
                    color: _isError ? Colors.red[300] : Colors.white,
                    fontWeight: FontWeight.w300,
                  ),
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            // Button grid
            Expanded(
              flex: 5,
              child: Container(
                color: Colors.grey[900],
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    _buildButtonRow(['C', '±', '%', '÷'],
                        [_funcColor, _funcColor, _funcColor, _opColor]),
                    _buildButtonRow(['7', '8', '9', '×'],
                        [_numColor, _numColor, _numColor, _opColor]),
                    _buildButtonRow(['4', '5', '6', '−'],
                        [_numColor, _numColor, _numColor, _opColor]),
                    _buildButtonRow(['1', '2', '3', '+'],
                        [_numColor, _numColor, _numColor, _opColor]),
                    _buildLastRow(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const Color _numColor = Color(0xFF333333);
  static const Color _opColor = Color(0xFF9C27B0);
  static const Color _funcColor = Color(0xFF555555);
  static const Color _eqColor = Color(0xFF7B1FA2);

  Widget _buildButtonRow(List<String> labels, List<Color> colors) {
    return Expanded(
      child: Row(
        children: List.generate(labels.length, (i) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: _calcButton(labels[i], colors[i]),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildLastRow() {
    return Expanded(
      child: Row(
        children: [
          // 0 takes 2 columns
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: _calcButton('0', _numColor, wideLabel: true),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: _calcButton('.', _numColor),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: _calcButton('=', _eqColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _calcButton(String label, Color bgColor, {bool wideLabel = false}) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: ElevatedButton(
        onPressed: () => _onButtonPressed(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.zero,
          elevation: 2,
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
