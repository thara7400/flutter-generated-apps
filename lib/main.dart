import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const _kDefaultSeed = 'ATTACK42';

/// シード文字列から正整数ハッシュを生成
int _hash(String s) {
  var h = 0;
  for (final c in s.runes) {
    h = (h * 31 + c) & 0x7FFFFFFF;
  }
  return h;
}

/// GoogleFonts.getFont のラッパー（フォントが見つからない場合は標準スタイルへフォールバック）
TextStyle _font(
  String family, {
  double? fontSize,
  FontWeight? fontWeight,
  Color? color,
  FontStyle? fontStyle,
  double? letterSpacing,
  double? height,
}) {
  try {
    return GoogleFonts.getFont(
      family,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      height: height,
    );
  } on Exception {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      height: height,
    );
  }
}

// ─── カードデータ定義 (12 エントリ) ──────────────────────────────────────────

const _kTitles = [
  'クリエイター',
  'ビジョナリー',
  'イノベーター',
  'ストラテジスト',
  'アーキテクト',
  'キュレーター',
  'エクスプローラー',
  'チェンジメイカー',
  'ドリーマー',
  'エバンジェリスト',
  'ビルダー',
  'パイオニア',
];

const _kTaglines = [
  '世界を変えるのは、いつだって一人から。',
  '限界は、自分が決めるものではない。',
  '才能は才能に嫉妬しない。',
  '挑戦しない後悔より、挑戦した失敗を。',
  '夢見る者だけが、夢を叶える。',
  'すべての偉大なことは、小さな一歩から始まる。',
  '可能性は、常に現実より大きい。',
  '未来は今、ここで作られる。',
  '動き続ける者に、チャンスは訪れる。',
  '本物の強さは、諦めないことにある。',
  '情熱こそが、最高の才能だ。',
  '今日の挑戦が、明日の自信になる。',
];

const _kIcons = [
  Icons.star_rounded,
  Icons.flash_on_rounded,
  Icons.rocket_launch_rounded,
  Icons.diamond_rounded,
  Icons.local_fire_department_rounded,
  Icons.auto_awesome_rounded,
  Icons.emoji_events_rounded,
  Icons.psychology_rounded,
  Icons.trending_up_rounded,
  Icons.light_mode_rounded,
  Icons.bolt_rounded,
  Icons.wb_sunny_rounded,
];

/// (グラデーション開始色, 終了色, 暗背景フラグ)
const _kPalettes = [
  (Color(0xFF6A11CB), Color(0xFF2575FC), true),
  (Color(0xFF0F2027), Color(0xFF2C5364), true),
  (Color(0xFFf953c6), Color(0xFFb91d73), true),
  (Color(0xFF11998e), Color(0xFF38ef7d), false),
  (Color(0xFFFC5C7D), Color(0xFF6A82FB), true),
  (Color(0xFFf7971e), Color(0xFFffd200), false),
  (Color(0xFF1a1a2e), Color(0xFF16213e), true),
  (Color(0xFF3a1c71), Color(0xFFd76d77), true),
  (Color(0xFF005C97), Color(0xFF363795), true),
  (Color(0xFF56ab2f), Color(0xFFa8e063), false),
  (Color(0xFFc94b4b), Color(0xFF4b134f), true),
  (Color(0xFF2b5876), Color(0xFF4e4376), true),
];

const _kFonts = [
  'Playfair Display',
  'Montserrat',
  'Raleway',
  'Oswald',
  'Poppins',
  'Nunito',
  'Quicksand',
  'Dancing Script',
  'Lobster',
  'Pacifico',
  'Lato',
  'Merriweather',
];

// ─── App ────────────────────────────────────────────────────────────────────

void main() => runApp(const _App());

class _App extends StatelessWidget {
  const _App();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'アタックメイク',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
      ),
      home: const InputPage(),
    );
  }
}

// ─── 入力画面 ─────────────────────────────────────────────────────────────────

class InputPage extends StatefulWidget {
  const InputPage({super.key});

  @override
  State<InputPage> createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  final _nameCtrl = TextEditingController();
  final _seedCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _seedCtrl.dispose();
    super.dispose();
  }

  void _generate() {
    final name =
        _nameCtrl.text.trim().isEmpty ? '名無し' : _nameCtrl.text.trim();
    final seed =
        _seedCtrl.text.trim().isEmpty ? _kDefaultSeed : _seedCtrl.text.trim();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CardPage(name: name, seed: seed),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'アタックメイク',
          style: _font('Poppins', fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            Icon(Icons.style_rounded, size: 64, color: cs.primary),
            const SizedBox(height: 10),
            Text(
              'あなただけの名刺を作ろう',
              textAlign: TextAlign.center,
              style: _font('Poppins', fontSize: 15, color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 36),
            // 名前入力
            TextField(
              controller: _nameCtrl,
              decoration: InputDecoration(
                labelText: '名前',
                hintText: '例: 山田 太郎',
                prefixIcon: const Icon(Icons.person_outline_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 20),
            // シード値入力
            TextField(
              controller: _seedCtrl,
              decoration: InputDecoration(
                labelText: 'シード値',
                hintText: '未入力のとき: $_kDefaultSeed',
                prefixIcon: const Icon(Icons.tag_rounded),
                helperText: '入力値でフォント・配色・肩書きが変わります',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _generate(),
            ),
            const SizedBox(height: 40),
            // 生成ボタン
            FilledButton.icon(
              onPressed: _generate,
              icon: const Icon(Icons.auto_awesome_rounded),
              label: const Text(
                '名刺を生成！',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── 名刺表示画面 ────────────────────────────────────────────────────────────

class CardPage extends StatelessWidget {
  final String name;
  final String seed;

  const CardPage({super.key, required this.name, required this.seed});

  @override
  Widget build(BuildContext context) {
    final i = _hash(seed) % _kTitles.length;
    final palette = _kPalettes[i];
    final isDark = palette.$3;

    final tc = isDark ? Colors.white : Colors.black87;
    final sc = isDark ? Colors.white70 : Colors.black54;
    final fontFamily = _kFonts[i];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [palette.$1, palette.$2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 戻るボタン
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: Icon(Icons.arrow_back_ios_new_rounded, color: tc),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              // カード本体
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    child: Column(
                      children: [
                        // アバター円
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: tc.withValues(alpha: 0.15),
                            border: Border.all(
                              color: tc.withValues(alpha: 0.4),
                              width: 2,
                            ),
                          ),
                          child: Icon(_kIcons[i], size: 50, color: tc),
                        ),
                        const SizedBox(height: 28),
                        // 名前
                        Text(
                          name,
                          textAlign: TextAlign.center,
                          style: _font(
                            fontFamily,
                            fontSize: 38,
                            fontWeight: FontWeight.bold,
                            color: tc,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // 肩書き
                        Text(
                          _kTitles[i],
                          textAlign: TextAlign.center,
                          style: _font(
                            fontFamily,
                            fontSize: 15,
                            fontWeight: FontWeight.w300,
                            color: sc,
                            letterSpacing: 3,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Divider(
                          color: tc.withValues(alpha: 0.3),
                          thickness: 1,
                        ),
                        const SizedBox(height: 20),
                        // 格言
                        Text(
                          _kTaglines[i],
                          textAlign: TextAlign.center,
                          style: _font(
                            fontFamily,
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: sc,
                            height: 1.8,
                          ),
                        ),
                        const SizedBox(height: 36),
                        // シード値バッジ
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: tc.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: tc.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.tag_rounded, size: 13, color: sc),
                              const SizedBox(width: 6),
                              Text(
                                'SEED : $seed',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: sc,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
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
