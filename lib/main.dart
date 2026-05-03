import 'package:flutter/material.dart';

void main() {
  runApp(const UnitConverterApp());
}

class UnitConverterApp extends StatefulWidget {
  const UnitConverterApp({super.key});

  @override
  State<UnitConverterApp> createState() => _UnitConverterAppState();
}

class _UnitConverterAppState extends State<UnitConverterApp> {
  final List<String> _units = ['m', 'cm', 'km', 'inch', 'feet'];

  String _sourceUnit = 'm';
  String _targetUnit = 'cm';

  final TextEditingController _sourceController = TextEditingController();
  final TextEditingController _resultController = TextEditingController();

  /// Multiply by this factor to convert a value in [unit] to meters.
  static const Map<String, double> _toMeters = {
    'm': 1.0,
    'cm': 0.01,
    'km': 1000.0,
    'inch': 0.0254,
    'feet': 0.3048,
  };

  /// Multiply by this factor to convert a value in meters to [unit].
  static const Map<String, double> _fromMeters = {
    'm': 1.0,
    'cm': 100.0,
    'km': 0.001,
    'inch': 39.3701,
    'feet': 3.28084,
  };

  void _convert() {
    final String raw = _sourceController.text.trim();
    if (raw.isEmpty) {
      _resultController.text = '';
      return;
    }
    final double? value = double.tryParse(raw);
    if (value == null) {
      _resultController.text = '';
      return;
    }
    final double meters = value * _toMeters[_sourceUnit]!;
    final double result = meters * _fromMeters[_targetUnit]!;
    _resultController.text = result.toStringAsFixed(4);
  }

  @override
  void dispose() {
    _sourceController.dispose();
    _resultController.dispose();
    super.dispose();
  }

  Widget _buildUnitDropdown({
    required String value,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButton<String>(
      value: value,
      items: _units
          .map(
            (unit) => DropdownMenuItem<String>(
              value: unit,
              child: Text(unit),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'シュヴァリエ クレド',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.red,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('シュヴァリエ クレド'),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Source row ──────────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _sourceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        signed: true,
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Source value',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) => _convert(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  _buildUnitDropdown(
                    value: _sourceUnit,
                    onChanged: (selected) {
                      if (selected == null) return;
                      setState(() => _sourceUnit = selected);
                      _convert();
                    },
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // ── Result row ───────────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _resultController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Result',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  _buildUnitDropdown(
                    value: _targetUnit,
                    onChanged: (selected) {
                      if (selected == null) return;
                      setState(() => _targetUnit = selected);
                      _convert();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
