import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '簡単電卓',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  /// 入力中の式（表示用。演算子は＋−×÷）
  String _expression = '';

  /// 現在の計算結果または表示数値
  String _result = '0';

  /// = を押した直後かどうか
  bool _justEvaluated = false;

  static const List<String> _ops = ['+', '−', '×', '÷'];

  // ── ボタン入力ハンドラ ────────────────────────────────────────

  void _onPressed(String label) {
    setState(() {
      switch (label) {
        case 'AC':
          _expression = '';
          _result = '0';
          _justEvaluated = false;

        case '=':
          if (_expression.isNotEmpty) {
            _result = _tryEval(_expression) ?? 'エラー';
            _justEvaluated = true;
          }

        case '+':
        case '−':
        case '×':
        case '÷':
          _handleOp(label);

        case '.':
          _handleDot();

        case '+/−':
          _handleToggleSign();

        case '%':
          _handlePercent();

        default:
          // 数字
          if (_justEvaluated) {
            _expression = label;
            _justEvaluated = false;
          } else {
            _expression += label;
          }
          _refreshResult();
      }
    });
  }

  void _handleOp(String op) {
    if (_justEvaluated) {
      _expression = _result + op;
      _justEvaluated = false;
    } else if (_expression.isNotEmpty) {
      final last = _expression[_expression.length - 1];
      if (_ops.contains(last)) {
        _expression = _expression.substring(0, _expression.length - 1) + op;
      } else {
        _expression += op;
      }
    }
    _refreshResult();
  }

  void _handleDot() {
    if (_justEvaluated) {
      _expression = '0.';
      _result = '0';
      _justEvaluated = false;
      return;
    }
    if (_expression.isEmpty) {
      _expression = '0.';
      return;
    }
    final lastOpIdx = _lastOpIndex();
    final cur = _expression.substring(lastOpIdx + 1);
    if (cur.contains('.')) return;
    _expression += cur.isEmpty ? '0.' : '.';
  }

  void _handleToggleSign() {
    if (_expression.isEmpty) return;
    if (_justEvaluated) {
      final val = double.tryParse(_result);
      if (val == null) return;
      _expression = _fmt(-val);
      _result = _expression;
      _justEvaluated = false;
      return;
    }
    final lastOpIdx = _lastOpIndex();
    final prefix = _expression.substring(0, lastOpIdx + 1);
    final cur = _expression.substring(lastOpIdx + 1);
    if (cur.isEmpty) return;
    _expression = cur.startsWith('−')
        ? prefix + cur.substring(1)
        : '$prefix−$cur';
    _refreshResult();
  }

  void _handlePercent() {
    if (_expression.isEmpty) return;
    if (_justEvaluated) {
      final val = double.tryParse(_result);
      if (val == null) return;
      _expression = _fmt(val / 100);
      _result = _expression;
      _justEvaluated = false;
      return;
    }
    final lastOpIdx = _lastOpIndex();
    final prefix = _expression.substring(0, lastOpIdx + 1);
    final cur = _expression.substring(lastOpIdx + 1);
    if (cur.isEmpty) return;
    final val = double.tryParse(cur.replaceAll('−', '-'));
    if (val == null) return;
    _expression = prefix + _fmt(val / 100);
    _refreshResult();
  }

  // ── ユーティリティ ────────────────────────────────────────────

  int _lastOpIndex() {
    for (int i = _expression.length - 1; i >= 0; i--) {
      if (_ops.contains(_expression[i])) return i;
    }
    return -1;
  }

  void _refreshResult() {
    final r = _tryEval(_expression);
    if (r != null) _result = r;
  }

  String? _tryEval(String expression) {
    try {
      final e = expression
          .replaceAll('×', '*')
          .replaceAll('÷', '/')
          .replaceAll('−', '-');
      final parser = GrammarParser();
      final parsed = parser.parse(e);
      final cm = ContextModel();
      final result = RealEvaluator(cm).evaluate(parsed).toDouble();
      if (result.isNaN || result.isInfinite) return null;
      return _fmt(result);
    } catch (_) {
      return null;
    }
  }

  String _fmt(double val) {
    if (val % 1 == 0 && val.abs() < 1e15) return val.toInt().toString();
    // 小数点以下の末尾ゼロを除去
    String s = val.toStringAsFixed(10);
    s = s.replaceAll(RegExp(r'0+$'), '');
    s = s.replaceAll(RegExp(r'\.$'), '');
    return s;
  }

  // ── UI ───────────────────────────────────────────────────────

  static const Color _bg = Color(0xFF1C1C1E);
  static const Color _numBg = Color(0xFF333333);
  static const Color _opBg = Color(0xFFFF9500);
  static const Color _funcBg = Color(0xFFA5A5A5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── ディスプレイ ──
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (_expression.isNotEmpty)
                      Text(
                        _expression,
                        style: const TextStyle(
                          color: Color(0xFFAAAAAA),
                          fontSize: 30,
                        ),
                        textAlign: TextAlign.right,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        _result,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 72,
                          fontWeight: FontWeight.w200,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // ── ボタングリッド ──
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                child: Column(
                  children: [
                    _buildRow([
                      _BtnDef('AC',  _funcBg, Colors.black),
                      _BtnDef('+/−', _funcBg, Colors.black),
                      _BtnDef('%',   _funcBg, Colors.black),
                      _BtnDef('÷',   _opBg,   Colors.white),
                    ]),
                    _buildRow([
                      _BtnDef('7', _numBg, Colors.white),
                      _BtnDef('8', _numBg, Colors.white),
                      _BtnDef('9', _numBg, Colors.white),
                      _BtnDef('×', _opBg,  Colors.white),
                    ]),
                    _buildRow([
                      _BtnDef('4', _numBg, Colors.white),
                      _BtnDef('5', _numBg, Colors.white),
                      _BtnDef('6', _numBg, Colors.white),
                      _BtnDef('−', _opBg,  Colors.white),
                    ]),
                    _buildRow([
                      _BtnDef('1', _numBg, Colors.white),
                      _BtnDef('2', _numBg, Colors.white),
                      _BtnDef('3', _numBg, Colors.white),
                      _BtnDef('+', _opBg,  Colors.white),
                    ]),
                    _buildRow([
                      _BtnDef('0', _numBg, Colors.white, flex: 2),
                      _BtnDef('.', _numBg, Colors.white),
                      _BtnDef('=', _opBg,  Colors.white),
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(List<_BtnDef> defs) {
    return Expanded(
      child: Row(
        children: defs.map((d) {
          final isWide = d.flex > 1;
          final shape = isWide
              ? const StadiumBorder()
              : const CircleBorder() as ShapeBorder;
          return Expanded(
            flex: d.flex,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Material(
                color: d.bg,
                shape: shape,
                child: InkWell(
                  customBorder: shape,
                  onTap: () => _onPressed(d.label),
                  child: Align(
                    alignment:
                        isWide ? Alignment.centerLeft : Alignment.center,
                    child: Padding(
                      padding:
                          EdgeInsets.only(left: isWide ? 28.0 : 0.0),
                      child: Text(
                        d.label,
                        style: TextStyle(
                          color: d.fg,
                          fontSize: 28,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _BtnDef {
  final String label;
  final Color bg;
  final Color fg;
  final int flex;
  const _BtnDef(this.label, this.bg, this.fg, {this.flex = 1});
}
