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
  final List<String> _units = ["m", "cm", "km", "inch", "feet"];

  /// How many meters equals 1 of this unit.
  final Map<String, double> _toMeters = {
    "m": 1.0,
    "cm": 0.01,
    "km": 1000.0,
    "inch": 0.0254013,   // 1 inch = 1/39.3701 m
    "feet": 0.3048,      // 1 foot = 1/3.28084 m
  };

  String _sourceUnit = "m";
  String _targetUnit = "cm";

  final TextEditingController _sourceController = TextEditingController();
  final TextEditingController _targetController = TextEditingController();

  /// Converts the current source value and writes the result to the target field.
  void _convert() {
    final String input = _sourceController.text.trim();

    if (input.isEmpty) {
      _targetController.text = "";
      return;
    }

    final double? value = double.tryParse(input);
    if (value == null) {
      _targetController.text = "";
      return;
    }

    // Step 1: convert source value → meters.
    final double inMeters = value * _toMeters[_sourceUnit]!;

    // Step 2: convert meters → target unit.
    final double result = inMeters / _toMeters[_targetUnit]!;

    _targetController.text = result.toStringAsFixed(4);
  }

  @override
  void dispose() {
    _sourceController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '単位チェンジ',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.red),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('単位チェンジ'),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),

              // ── Source row ──────────────────────────────────────────────
              Text(
                'From',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _sourceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Source value',
                        border: OutlineInputBorder(),
                        hintText: 'e.g. 100',
                      ),
                      onChanged: (_) => _convert(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  DropdownButton<String>(
                    value: _sourceUnit,
                    items: _units
                        .map(
                          (unit) => DropdownMenuItem(
                            value: unit,
                            child: Text(
                              unit,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _sourceUnit = value;
                        });
                        _convert();
                      }
                    },
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // ── Divider with arrow ───────────────────────────────────────
              Row(
                children: const [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Icon(Icons.arrow_downward, color: Colors.red),
                  ),
                  Expanded(child: Divider()),
                ],
              ),

              const SizedBox(height: 32),

              // ── Target row ──────────────────────────────────────────────
              Text(
                'To',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _targetController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Result',
                        border: OutlineInputBorder(),
                        hintText: '—',
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  DropdownButton<String>(
                    value: _targetUnit,
                    items: _units
                        .map(
                          (unit) => DropdownMenuItem(
                            value: unit,
                            child: Text(
                              unit,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _targetUnit = value;
                        });
                        _convert();
                      }
                    },
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // ── Conversion reference card ────────────────────────────────
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Conversion reference',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text('1 m  =  100 cm'),
                      const Text('1 m  =  0.001 km'),
                      const Text('1 m  =  39.3701 inch'),
                      const Text('1 m  =  3.28084 feet'),
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
