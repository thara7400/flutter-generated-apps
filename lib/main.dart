import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

// ---------- isolate 内で実行する純粋関数 ----------
Uint8List? _convertToLineArt(Map<String, dynamic> params) {
  final bytes = params['bytes'] as Uint8List;
  final strength = params['strength'] as double;

  final src = img.decodeImage(bytes);
  if (src == null) return null;

  // 大きな画像はリサイズして処理を高速化
  img.Image working;
  const int maxDim = 900;
  if (src.width > maxDim || src.height > maxDim) {
    final double scale =
        src.width >= src.height ? maxDim / src.width : maxDim / src.height;
    final int newW = (src.width * scale).round();
    final int newH = (src.height * scale).round();
    working = img.copyResize(src, width: newW, height: newH);
  } else {
    working = src;
  }

  // グレースケール → Sobel エッジ検出 → 反転（黒線・白地）
  final gray = img.grayscale(working);
  final edges = img.sobel(gray, amount: strength);
  final result = img.invert(edges);

  return Uint8List.fromList(img.encodePng(result));
}
// -----------------------------------------------

void main() => runApp(const MainApp());

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '簡単 せんが',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Uint8List? _srcBytes;
  Uint8List? _lineArtBytes;
  bool _isProcessing = false;
  bool _pendingProcess = false;
  double _strength = 1.5;
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  // ── 画像ピッカー ──
  Future<void> _pickImage() async {
    final xfile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (xfile == null) return;

    final bytes = await xfile.readAsBytes();
    if (!mounted) return;

    setState(() {
      _srcBytes = bytes;
      _lineArtBytes = null;
    });
    _startProcess();
  }

  // ── スライダー変更（デバウンス付き）──
  void _onStrengthChanged(double v) {
    setState(() => _strength = v);
    _debounce?.cancel();
    _debounce =
        Timer(const Duration(milliseconds: 350), _startProcess);
  }

  // ── 処理キック ──
  void _startProcess() {
    if (_srcBytes == null) return;
    if (_isProcessing) {
      _pendingProcess = true;
      return;
    }
    _runProcess();
  }

  Future<void> _runProcess() async {
    if (_srcBytes == null || !mounted) return;
    setState(() {
      _isProcessing = true;
      _pendingProcess = false;
    });

    final bytes = _srcBytes!;
    final strength = _strength;

    try {
      final result = await compute<Map<String, dynamic>, Uint8List?>(
        _convertToLineArt,
        {'bytes': bytes, 'strength': strength},
      );
      if (!mounted) return;
      setState(() {
        _lineArtBytes = result;
        _isProcessing = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
    }

    if (_pendingProcess && mounted) {
      _runProcess();
    }
  }

  // ── ビルド ──
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text('簡単 せんが'),
        centerTitle: true,
        backgroundColor: cs.primaryContainer,
        foregroundColor: cs.onPrimaryContainer,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 画像プレビュー
            Expanded(child: _buildPreview(theme)),

            // 進行バー
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 200),
              crossFadeState: _isProcessing
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              firstChild: const LinearProgressIndicator(),
              secondChild: const SizedBox(height: 4),
            ),

            // 操作パネル
            _buildPanel(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview(ThemeData theme) {
    final cs = theme.colorScheme;

    if (_lineArtBytes != null) {
      return InteractiveViewer(
        child: Center(
          child: Image.memory(
            _lineArtBytes!,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.medium,
          ),
        ),
      );
    }

    if (_isProcessing) {
      return const Center(child: CircularProgressIndicator());
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.draw_outlined, size: 72, color: cs.primary),
          const SizedBox(height: 16),
          Text(
            '画像を選んで線画に変換できます',
            style:
                theme.textTheme.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildPanel(ThemeData theme) {
    final cs = theme.colorScheme;
    final bool hasImage = _srcBytes != null;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        border: Border(top: BorderSide(color: cs.outlineVariant)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ラベル行
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('線の強さ',
                  style: theme.textTheme.labelMedium
                      ?.copyWith(color: cs.onSurfaceVariant)),
              Text(
                _strength.toStringAsFixed(1),
                style: theme.textTheme.labelLarge
                    ?.copyWith(color: cs.primary, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          // スライダー
          Row(
            children: [
              Icon(Icons.remove_circle_outline,
                  size: 20, color: cs.onSurfaceVariant),
              Expanded(
                child: Slider(
                  min: 0.2,
                  max: 5.0,
                  value: _strength,
                  divisions: 48,
                  label: _strength.toStringAsFixed(1),
                  onChanged: hasImage ? _onStrengthChanged : null,
                ),
              ),
              Icon(Icons.add_circle_outline,
                  size: 20, color: cs.onSurfaceVariant),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('細い', style: theme.textTheme.labelSmall),
              Text('太い', style: theme.textTheme.labelSmall),
            ],
          ),
          const SizedBox(height: 14),
          // 画像選択ボタン（全幅）
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _isProcessing ? null : _pickImage,
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('画像を選択する'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
