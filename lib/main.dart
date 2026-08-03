import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Generator',
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: const QrGeneratorScreen(),
    );
  }
}

class QrGeneratorScreen extends StatefulWidget {
  const QrGeneratorScreen({super.key});

  @override
  State<QrGeneratorScreen> createState() => _QrGeneratorScreenState();
}

class _QrGeneratorScreenState extends State<QrGeneratorScreen> {
  final TextEditingController _controller = TextEditingController();
  String _qrData = '';

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _qrData = _controller.text;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('QR コード生成'),
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: 'テキストを入力',
                  hintText: 'URL やテキストを入力してください',
                  border: const OutlineInputBorder(),
                  suffixIcon: _qrData.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close),
                          tooltip: 'クリア',
                          onPressed: _clear,
                        )
                      : null,
                ),
                maxLines: 3,
                minLines: 1,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _qrData.isNotEmpty ? _clear : null,
                icon: const Icon(Icons.delete_outline),
                label: const Text('クリア'),
              ),
              const SizedBox(height: 32),
              if (_qrData.isEmpty)
                Container(
                  height: 240,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(color: colorScheme.outlineVariant),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'テキストを入力すると\nQR コードが表示されます',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colorScheme.outline),
                  ),
                )
              else
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.shadow.withAlpha(40),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: QrImageView(
                      data: _qrData,
                      version: QrVersions.auto,
                      size: 240,
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: Colors.black,
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: Colors.black,
                      ),
                      errorCorrectionLevel: QrErrorCorrectLevel.M,
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
