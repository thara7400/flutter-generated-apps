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

  // Factor: multiply source value by this to convert to meters
  // 1 m = 100 cm   → 1 cm = 0.01 m
  // 1 m = 0.001 km → 1 km = 1000 m
  // 1 m = 39.3701 inch → 1 inch = 1/39.3701 m
  // 1 m = 3.28084 feet → 1 feet = 1/3.28084 m
  final Map<String, double> _toMetersFactor = {
    'm': 1.0,
    'cm': 1 / 100,
    'km': 1 / 0.001,
    'inch': 1 / 39.3701,
    'feet': 1 / 3.28084,
  };

  String _sourceUnit = 'm';
  String _targetUnit = 'cm';
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _resultController = TextEditingController();

  void _convert() {
    final String inputText = _inputController.text;

    if (inputText.isEmpty) {
      _resultController.text = '';
      return;
    }

    final double? inputValue = double.tryParse(inputText);
    if (inputValue == null) {
      _resultController.text = '';
      return;
    }

    // Convert to meters first, then to the target unit
    final double inMeters = inputValue * _toMetersFactor[_sourceUnit]!;
    final double result = inMeters / _toMetersFactor[_targetUnit]!;

    _resultController.text = result.toStringAsFixed(4);
  }

  @override
  void dispose() {
    _inputController.dispose();
    _resultController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '変換くん',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('変換くん'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Source row ──────────────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'From',
                        hintText: 'Enter value',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) => _convert(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  DropdownButton<String>(
                    value: _sourceUnit,
                    items: _units
                        .map((unit) => DropdownMenuItem(
                              value: unit,
                              child: Text(
                                unit,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _sourceUnit = value);
                        _convert();
                      }
                    },
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // ── Target row ──────────────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _resultController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'To',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  DropdownButton<String>(
                    value: _targetUnit,
                    items: _units
                        .map((unit) => DropdownMenuItem(
                              value: unit,
                              child: Text(
                                unit,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _targetUnit = value);
                        _convert();
                      }
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
