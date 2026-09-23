import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, brightness: Brightness.dark),
      home: const MirrorBallScreen(),
    );
  }
}

// ─── Screen ────────────────────────────────────────────────────────────────

class MirrorBallScreen extends StatefulWidget {
  const MirrorBallScreen({super.key});

  @override
  State<MirrorBallScreen> createState() => _MirrorBallScreenState();
}

class _MirrorBallScreenState extends State<MirrorBallScreen>
    with TickerProviderStateMixin {
  late final AnimationController _ballCtrl;
  late final AnimationController _sparkleCtrl;
  late final AnimationController _beamCtrl;

  @override
  void initState() {
    super.initState();
    _ballCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    _sparkleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _beamCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _ballCtrl.dispose();
    _sparkleCtrl.dispose();
    _beamCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final ballSize = size.width * 0.62;

    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedBuilder(
        animation: Listenable.merge([_ballCtrl, _sparkleCtrl, _beamCtrl]),
        builder: (context, _) {
          return Stack(
            children: [
              // Dark background
              Container(
                width: size.width,
                height: size.height,
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.0,
                    colors: [Color(0xFF1A0035), Colors.black],
                  ),
                ),
              ),

              // Light beams
              CustomPaint(
                size: size,
                painter: BeamPainter(progress: _beamCtrl.value),
              ),

              // Floating sparkles
              CustomPaint(
                size: size,
                painter: SparklePainter(progress: _sparkleCtrl.value),
              ),

              // Mirror ball
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Tiles
                    CustomPaint(
                      size: Size(ballSize, ballSize),
                      painter: MirrorBallPainter(
                        rotation: _ballCtrl.value,
                      ),
                    ),
                    // Shimmer sweep
                    ClipOval(
                      child: SizedBox(
                        width: ballSize,
                        height: ballSize,
                        child: Shimmer(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0x00FFFFFF),
                              Color(0x44FFFFFF),
                              Color(0x00FFFFFF),
                            ],
                            stops: [0.0, 0.5, 1.0],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          period: const Duration(milliseconds: 1400),
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Specular glare
                    Positioned(
                      top: ballSize * 0.1,
                      left: ballSize * 0.22,
                      child: Container(
                        width: ballSize * 0.18,
                        height: ballSize * 0.12,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [Color(0x99FFFFFF), Color(0x00FFFFFF)],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Title
              Positioned(
                top: 52,
                left: 0,
                right: 0,
                child: Center(
                  child: Shimmer(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF888888),
                        Color(0xFFFFFFFF),
                        Color(0xFF888888),
                      ],
                      stops: [0.0, 0.5, 1.0],
                    ),
                    period: const Duration(milliseconds: 2200),
                    child: const Text(
                      'MIRROR BALL',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 7,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─── MirrorBallPainter ─────────────────────────────────────────────────────

class MirrorBallPainter extends CustomPainter {
  final double rotation;

  const MirrorBallPainter({required this.rotation});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    canvas.save();
    canvas.clipPath(
      Path()..addOval(Rect.fromCircle(center: center, radius: radius)),
    );

    // Base sphere
    final basePaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.4),
        radius: 1.0,
        colors: const [Color(0xFF3A3A5A), Color(0xFF08080F)],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, basePaint);

    const tilesX = 18;
    const tilesY = 18;
    final tileW = size.width / tilesX;
    final tileH = size.height / tilesY;
    final rng = Random(42);

    // Rotating light source
    final angle = rotation * 2 * pi;
    final lx = cos(angle) * 0.65;
    final ly = sin(angle * 0.75) * 0.4 - 0.2;

    for (int row = 0; row < tilesY; row++) {
      for (int col = 0; col < tilesX; col++) {
        final tileCenter = Offset(
          col * tileW + tileW / 2,
          row * tileH + tileH / 2,
        );
        final ndcX = (tileCenter.dx - center.dx) / radius;
        final ndcY = (tileCenter.dy - center.dy) / radius;
        final dist2 = ndcX * ndcX + ndcY * ndcY;

        if (dist2 > 0.93) continue;

        final nz = sqrt(max(0.0, 1.0 - dist2));
        final phase = rng.nextDouble();

        final diffuse = max(0.0, ndcX * lx + ndcY * ly + nz * 0.7);
        final shimmerVal = sin((rotation * 6 + phase) * pi * 2) * 0.5 + 0.5;

        final hue = (col * 22.0 + row * 14.0 + rotation * 200) % 360.0;
        final brightness = (diffuse * 0.6 + shimmerVal * 0.4).clamp(0.0, 1.0);
        final saturation = ((1.0 - brightness * 0.5) * 0.85).clamp(0.0, 1.0);

        final paint = Paint()
          ..color = HSVColor.fromAHSV(1.0, hue, saturation, brightness)
              .toColor()
          ..style = PaintingStyle.fill;

        const gap = 1.2;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              col * tileW + gap,
              row * tileH + gap,
              tileW - gap * 2,
              tileH - gap * 2,
            ),
            const Radius.circular(1.5),
          ),
          paint,
        );
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(MirrorBallPainter old) => old.rotation != rotation;
}

// ─── BeamPainter ───────────────────────────────────────────────────────────

class BeamPainter extends CustomPainter {
  final double progress;

  const BeamPainter({required this.progress});

  // (alpha=0x1F ≈ 12%)
  static const _beams = [
    (color: Color(0x1F6600FF), phase: 0.00),
    (color: Color(0x1FFF0066), phase: 0.33),
    (color: Color(0x1F00CCFF), phase: 0.66),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final origin = Offset(size.width / 2, size.height * 0.4);
    const halfSpread = pi / 11;
    final length = size.height * 1.6;

    for (final b in _beams) {
      final a = (progress + b.phase) * 2 * pi;
      final path = Path()
        ..moveTo(origin.dx, origin.dy)
        ..lineTo(
          origin.dx + cos(a - halfSpread) * length,
          origin.dy + sin(a - halfSpread) * length,
        )
        ..lineTo(
          origin.dx + cos(a + halfSpread) * length,
          origin.dy + sin(a + halfSpread) * length,
        )
        ..close();
      canvas.drawPath(path, Paint()..color = b.color);
    }
  }

  @override
  bool shouldRepaint(BeamPainter old) => old.progress != progress;
}

// ─── SparklePainter ────────────────────────────────────────────────────────

class _SparkleData {
  final double x, y, phase, size, hue;
  const _SparkleData(this.x, this.y, this.phase, this.size, this.hue);
}

class SparklePainter extends CustomPainter {
  final double progress;

  SparklePainter({required this.progress});

  static final List<_SparkleData> _sparkles = List.generate(55, (i) {
    final r = Random(i * 137 + 7);
    return _SparkleData(
      r.nextDouble(),
      r.nextDouble(),
      r.nextDouble(),
      r.nextDouble() * 2.4 + 0.8,
      r.nextDouble() * 360,
    );
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in _sparkles) {
      final val = sin((progress + s.phase) * pi * 2);
      if (val <= 0) continue;

      final opacity = val.clamp(0.0, 1.0);
      final pos = Offset(s.x * size.width, s.y * size.height);

      // Glow dot
      canvas.drawCircle(
        pos,
        s.size * opacity,
        Paint()
          ..color = HSVColor.fromAHSV(opacity, s.hue, 0.3, 1.0).toColor()
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0),
      );

      // Star cross at peak brightness
      if (val > 0.65) {
        final t = ((val - 0.65) / 0.35).clamp(0.0, 1.0);
        final alpha = (t * 255).round().clamp(0, 255);
        final arm = s.size * 5.5;
        canvas.drawLine(
          pos.translate(-arm, 0),
          pos.translate(arm, 0),
          Paint()
            ..color = Color.fromARGB(alpha, 255, 255, 255)
            ..strokeWidth = 1.0,
        );
        canvas.drawLine(
          pos.translate(0, -arm),
          pos.translate(0, arm),
          Paint()
            ..color = Color.fromARGB(alpha, 255, 255, 255)
            ..strokeWidth = 1.0,
        );
      }
    }
  }

  @override
  bool shouldRepaint(SparklePainter old) => old.progress != progress;
}
