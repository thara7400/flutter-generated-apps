import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '間違い発見',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const CompareScreen(),
    );
  }
}

class CompareScreen extends StatefulWidget {
  const CompareScreen({super.key});

  @override
  State<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  XFile? _leftImage;
  XFile? _rightImage;
  final ImagePicker _picker = ImagePicker();

  final TransformationController _leftCtrl = TransformationController();
  final TransformationController _rightCtrl = TransformationController();
  bool _syncMode = true;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _leftCtrl.addListener(_onLeftChanged);
    _rightCtrl.addListener(_onRightChanged);
  }

  void _onLeftChanged() {
    if (_syncMode && !_isUpdating) {
      _isUpdating = true;
      _rightCtrl.value = _leftCtrl.value;
      _isUpdating = false;
    }
  }

  void _onRightChanged() {
    if (_syncMode && !_isUpdating) {
      _isUpdating = true;
      _leftCtrl.value = _rightCtrl.value;
      _isUpdating = false;
    }
  }

  @override
  void dispose() {
    _leftCtrl.removeListener(_onLeftChanged);
    _rightCtrl.removeListener(_onRightChanged);
    _leftCtrl.dispose();
    _rightCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(bool isLeft) async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() {
        if (isLeft) {
          _leftImage = file;
        } else {
          _rightImage = file;
        }
      });
    }
  }

  void _resetZoom() {
    _leftCtrl.value = Matrix4.identity();
    _rightCtrl.value = Matrix4.identity();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.primaryContainer,
        foregroundColor: cs.onPrimaryContainer,
        title: const Text('間違い発見'),
        centerTitle: false,
        actions: [
          Tooltip(
            message: _syncMode ? '同期中（タップで解除）' : '個別操作中（タップで同期）',
            child: IconButton(
              icon: Icon(_syncMode ? Icons.link : Icons.link_off),
              onPressed: () => setState(() => _syncMode = !_syncMode),
            ),
          ),
          Tooltip(
            message: 'ズームをリセット',
            child: IconButton(
              icon: const Icon(Icons.zoom_out_map),
              onPressed: _resetZoom,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 同期状態バナー
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            color: _syncMode
                ? cs.primaryContainer.withValues(alpha: 0.6)
                : cs.tertiaryContainer.withValues(alpha: 0.6),
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _syncMode ? Icons.link : Icons.link_off,
                  size: 14,
                  color: _syncMode ? cs.onPrimaryContainer : cs.onTertiaryContainer,
                ),
                const SizedBox(width: 6),
                Text(
                  _syncMode ? '同期ズーム・スクロール ON' : '個別ズーム・スクロール',
                  style: TextStyle(
                    fontSize: 12,
                    color: _syncMode
                        ? cs.onPrimaryContainer
                        : cs.onTertiaryContainer,
                  ),
                ),
              ],
            ),
          ),
          // 画像エリア
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _ImagePanel(
                  label: '左',
                  image: _leftImage,
                  controller: _leftCtrl,
                  onPick: () => _pickImage(true),
                )),
                VerticalDivider(width: 3, color: cs.outlineVariant, thickness: 3),
                Expanded(child: _ImagePanel(
                  label: '右',
                  image: _rightImage,
                  controller: _rightCtrl,
                  onPick: () => _pickImage(false),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ImagePanel extends StatelessWidget {
  const _ImagePanel({
    required this.label,
    required this.image,
    required this.controller,
    required this.onPick,
  });

  final String label;
  final XFile? image;
  final TransformationController controller;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        // パネルヘッダー
        Container(
          color: cs.surfaceContainerHighest,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Row(
            children: [
              Text(
                '$label の画像',
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              FilledButton.tonalIcon(
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                  minimumSize: const Size(0, 32),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                icon: const Icon(Icons.photo_library_outlined, size: 16),
                label: const Text('選択', style: TextStyle(fontSize: 13)),
                onPressed: onPick,
              ),
            ],
          ),
        ),
        // 画像またはプレースホルダー
        Expanded(
          child: image == null
              ? _Placeholder(onTap: onPick)
              : ClipRect(
                  child: InteractiveViewer(
                    transformationController: controller,
                    minScale: 0.3,
                    maxScale: 10.0,
                    child: Image.file(
                      File(image!.path),
                      fit: BoxFit.contain,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (_, _, _) => const Center(
                        child: Icon(Icons.broken_image_outlined, size: 48),
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: cs.surfaceContainerLowest,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.add_photo_alternate_outlined,
                size: 56,
                color: cs.primary.withValues(alpha: 0.45),
              ),
              const SizedBox(height: 10),
              Text(
                'タップして選択',
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
