import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '誕生日占い',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6A0DAD),
        ),
        useMaterial3: true,
      ),
      home: const BirthdayFortunePage(),
    );
  }
}

// ─────────────────────────────────────────────
// 入力画面
// ─────────────────────────────────────────────
class BirthdayFortunePage extends StatefulWidget {
  const BirthdayFortunePage({super.key});

  @override
  State<BirthdayFortunePage> createState() => _BirthdayFortunePageState();
}

class _BirthdayFortunePageState extends State<BirthdayFortunePage> {
  DateTime? _selectedDate;
  FortuneResult? _result;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initial = _selectedDate ?? DateTime(1990, 1, 1);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isAfter(now) ? now : initial,
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: '誕生日を選んでください',
      confirmText: '決定',
      cancelText: 'キャンセル',
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _result = null;
      });
    }
  }

  void _fortune() {
    if (_selectedDate == null) return;
    setState(() {
      _result = FortuneCalculator.calculate(_selectedDate!);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text('✨ 誕生日占い ✨'),
        centerTitle: true,
        backgroundColor: cs.surfaceContainerHighest,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            // ── 入力カード ──────────────────────────
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      'あなたの誕生日は？',
                      style: theme.textTheme.titleLarge
                          ?.copyWith(color: cs.onSurface),
                    ),
                    const SizedBox(height: 20),
                    InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: double.maxFinite,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 18),
                        decoration: BoxDecoration(
                          border: Border.all(color: cs.primary, width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.cake_outlined, color: cs.primary),
                            const SizedBox(width: 12),
                            Text(
                              _selectedDate == null
                                  ? 'タップして選択'
                                  : DateFormat('yyyy年 M月 d日')
                                      .format(_selectedDate!),
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: _selectedDate == null
                                    ? cs.onSurfaceVariant
                                    : cs.primary,
                                fontWeight: _selectedDate == null
                                    ? FontWeight.normal
                                    : FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: _selectedDate != null ? _fortune : null,
                      icon: const Icon(Icons.auto_awesome),
                      label: const Text(
                        '占う',
                        style: TextStyle(fontSize: 18),
                      ),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(200, 52),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── 結果カード ──────────────────────────
            if (_result != null) ...[
              const SizedBox(height: 28),
              _ResultCard(result: _result!),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 結果表示ウィジェット
// ─────────────────────────────────────────────
class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result});
  final FortuneResult result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card(
      color: cs.primaryContainer,
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // 星座シンボル
            Text(
              result.zodiacEmoji,
              style: const TextStyle(fontSize: 72),
            ),
            const SizedBox(height: 8),
            Text(
              result.zodiacName,
              style: theme.textTheme.headlineLarge?.copyWith(
                color: cs.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              result.zodiacDateRange,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: cs.onPrimaryContainer),
            ),

            const Divider(height: 32),

            // 総合運
            Text(
              '総合運',
              style: theme.textTheme.titleMedium
                  ?.copyWith(color: cs.onPrimaryContainer),
            ),
            const SizedBox(height: 6),
            _Stars(score: result.overallScore),

            const SizedBox(height: 20),

            // 各運勢バー
            _FortuneBar(label: '💕 恋愛運', score: result.loveScore),
            const SizedBox(height: 10),
            _FortuneBar(label: '💼 仕事運', score: result.workScore),
            const SizedBox(height: 10),
            _FortuneBar(label: '💰 金　運', score: result.moneyScore),
            const SizedBox(height: 10),
            _FortuneBar(label: '🌿 健康運', score: result.healthScore),

            const Divider(height: 32),

            // ラッキー情報
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _LuckyChip(label: 'ラッキーカラー', value: result.luckyColor),
                _LuckyChip(
                    label: 'ラッキーナンバー',
                    value: result.luckyNumber.toString()),
                _LuckyChip(label: 'ラッキーアイテム', value: result.luckyItem),
              ],
            ),

            const Divider(height: 32),

            // 占いメッセージ
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.onPrimaryContainer.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                result.message,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: cs.onPrimaryContainer,
                  height: 1.8,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stars extends StatelessWidget {
  const _Stars({required this.score});
  final int score;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        return Icon(
          i < score ? Icons.star_rounded : Icons.star_outline_rounded,
          color: Colors.amber,
          size: 36,
        );
      }),
    );
  }
}

class _FortuneBar extends StatelessWidget {
  const _FortuneBar({required this.label, required this.score});
  final String label;
  final int score;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final barColor = score >= 4
        ? Colors.amber.shade600
        : score >= 3
            ? cs.primary
            : cs.tertiary;

    return Row(
      children: [
        SizedBox(
          width: 106,
          child: Text(
            label,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: cs.onPrimaryContainer),
          ),
        ),
        Expanded(
          child: LinearProgressIndicator(
            value: score / 5.0,
            minHeight: 10,
            borderRadius: BorderRadius.circular(5),
            color: barColor,
            backgroundColor: cs.onPrimaryContainer.withValues(alpha: 0.12),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$score / 5',
          style: theme.textTheme.bodySmall
              ?.copyWith(color: cs.onPrimaryContainer),
        ),
      ],
    );
  }
}

class _LuckyChip extends StatelessWidget {
  const _LuckyChip({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall
              ?.copyWith(color: cs.onPrimaryContainer),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: cs.onPrimaryContainer,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// 占い結果データ
// ─────────────────────────────────────────────
class FortuneResult {
  const FortuneResult({
    required this.zodiacName,
    required this.zodiacEmoji,
    required this.zodiacDateRange,
    required this.overallScore,
    required this.loveScore,
    required this.workScore,
    required this.moneyScore,
    required this.healthScore,
    required this.luckyColor,
    required this.luckyNumber,
    required this.luckyItem,
    required this.message,
  });

  final String zodiacName;
  final String zodiacEmoji;
  final String zodiacDateRange;
  final int overallScore;
  final int loveScore;
  final int workScore;
  final int moneyScore;
  final int healthScore;
  final String luckyColor;
  final int luckyNumber;
  final String luckyItem;
  final String message;
}

// ─────────────────────────────────────────────
// 占い計算ロジック（純 Dart）
// ─────────────────────────────────────────────
class _ZodiacInfo {
  const _ZodiacInfo({
    required this.name,
    required this.emoji,
    required this.dateRange,
    required this.startMonth,
    required this.startDay,
    required this.endMonth,
    required this.endDay,
  });
  final String name;
  final String emoji;
  final String dateRange;
  final int startMonth;
  final int startDay;
  final int endMonth;
  final int endDay;
}

class FortuneCalculator {
  static const _zodiacs = [
    _ZodiacInfo(
        name: 'やぎ座',
        emoji: '♑',
        dateRange: '12/22〜1/19',
        startMonth: 12,
        startDay: 22,
        endMonth: 1,
        endDay: 19),
    _ZodiacInfo(
        name: 'みずがめ座',
        emoji: '♒',
        dateRange: '1/20〜2/18',
        startMonth: 1,
        startDay: 20,
        endMonth: 2,
        endDay: 18),
    _ZodiacInfo(
        name: 'うお座',
        emoji: '♓',
        dateRange: '2/19〜3/20',
        startMonth: 2,
        startDay: 19,
        endMonth: 3,
        endDay: 20),
    _ZodiacInfo(
        name: 'おひつじ座',
        emoji: '♈',
        dateRange: '3/21〜4/19',
        startMonth: 3,
        startDay: 21,
        endMonth: 4,
        endDay: 19),
    _ZodiacInfo(
        name: 'おうし座',
        emoji: '♉',
        dateRange: '4/20〜5/20',
        startMonth: 4,
        startDay: 20,
        endMonth: 5,
        endDay: 20),
    _ZodiacInfo(
        name: 'ふたご座',
        emoji: '♊',
        dateRange: '5/21〜6/21',
        startMonth: 5,
        startDay: 21,
        endMonth: 6,
        endDay: 21),
    _ZodiacInfo(
        name: 'かに座',
        emoji: '♋',
        dateRange: '6/22〜7/22',
        startMonth: 6,
        startDay: 22,
        endMonth: 7,
        endDay: 22),
    _ZodiacInfo(
        name: 'しし座',
        emoji: '♌',
        dateRange: '7/23〜8/22',
        startMonth: 7,
        startDay: 23,
        endMonth: 8,
        endDay: 22),
    _ZodiacInfo(
        name: 'おとめ座',
        emoji: '♍',
        dateRange: '8/23〜9/22',
        startMonth: 8,
        startDay: 23,
        endMonth: 9,
        endDay: 22),
    _ZodiacInfo(
        name: 'てんびん座',
        emoji: '♎',
        dateRange: '9/23〜10/23',
        startMonth: 9,
        startDay: 23,
        endMonth: 10,
        endDay: 23),
    _ZodiacInfo(
        name: 'さそり座',
        emoji: '♏',
        dateRange: '10/24〜11/22',
        startMonth: 10,
        startDay: 24,
        endMonth: 11,
        endDay: 22),
    _ZodiacInfo(
        name: 'いて座',
        emoji: '♐',
        dateRange: '11/23〜12/21',
        startMonth: 11,
        startDay: 23,
        endMonth: 12,
        endDay: 21),
  ];

  static const _colors = [
    'ゴールド', 'シルバー', 'ローズ', 'ラベンダー',
    'サファイア', 'エメラルド', 'コーラル', 'アイボリー',
    'パープル', 'ティール', 'バーガンディ', 'スカイブルー',
  ];

  static const _items = [
    'クリスタル', '四つ葉のクローバー', 'ムーンストーン', '赤い糸',
    '手帳', '音楽', '観葉植物', '星形グッズ',
    'キャンドル', 'お茶', '絵本', '太陽の写真',
  ];

  static const _messages = [
    '今のあなたは輝いています。直感を信じて行動すれば、望む結果が手に入るでしょう。大切な人との時間を大切にしてください。',
    '新しい出会いや発見があなたを待っています。積極的に動けば、思いがけない幸運が舞い込んでくる予感があります。',
    '穏やかな流れの中にある時期。無理をせず自分のペースで進むことが吉。小さな喜びを積み重ねましょう。',
    '創造力が高まるとき。アイデアを形にするチャンスです。周囲のサポートを素直に受け入れることで道が開けます。',
    '感謝の気持ちが運気を引き寄せます。日々の小さな幸せに目を向けることで、心が豊かになっていくでしょう。',
    'チャレンジの時期です。少し勇気を出して一歩踏み出せば、新しい世界が広がります。失敗を恐れずに。',
    '人間関係が鍵となる時。素直な気持ちを伝えれば、相手も心を開いてくれます。信頼関係を大切に育てましょう。',
    '内なる声に耳を傾けてください。あなたの心が正しい方向を指し示しています。自分を信じることが最大の力です。',
    '努力が実を結ぶ時期が来ています。コツコツ積み上げてきたことが花開くでしょう。焦らずじっくりと進んで。',
    '変化を恐れないで。新しいサイクルの始まりを告げています。柔軟に対応することで運気が一気に上昇します。',
    '周囲からの評価が高まる時。自信を持って意見を発信しましょう。あなたの言葉は人の心に届いています。',
    '休息と充電の時間も必要です。心と体のバランスを整えることで、次のステップへの準備が整います。',
  ];

  static int _zodiacIndex(int month, int day) {
    for (int i = 0; i < _zodiacs.length; i++) {
      final z = _zodiacs[i];
      final sm = z.startMonth;
      final sd = z.startDay;
      final em = z.endMonth;
      final ed = z.endDay;

      if (sm > em) {
        // 年をまたぐ星座（やぎ座: 12/22〜1/19）
        if ((month == sm && day >= sd) || (month == em && day <= ed)) {
          return i;
        }
      } else {
        // 通常
        final afterStart = (month == sm && day >= sd) || (month > sm);
        final beforeEnd = (month == em && day <= ed) || (month < em);
        if (afterStart && beforeEnd) return i;
      }
    }
    return 0; // フォールバック
  }

  /// 誕生日の数値をもとにシードを生成（決定論的）
  static int _seed(DateTime date) {
    return date.year * 10000 + date.month * 100 + date.day;
  }

  static int _score(int seed, int offset) {
    return ((seed ~/ (1 + offset * 7)) % 5) + 1;
  }

  static FortuneResult calculate(DateTime birthday) {
    final zIdx = _zodiacIndex(birthday.month, birthday.day);
    final zodiac = _zodiacs[zIdx];
    final seed = _seed(birthday);

    final overall = _score(seed, 0);
    final love = _score(seed, 1);
    final work = _score(seed, 2);
    final money = _score(seed, 3);
    final health = _score(seed, 4);

    final colorIdx = (seed + zIdx * 3) % _colors.length;
    final itemIdx = (seed ~/ 13 + zIdx * 5) % _items.length;
    final msgIdx = (seed ~/ 7 + zIdx * 2) % _messages.length;
    final luckyNum = (seed % 9) + 1;

    return FortuneResult(
      zodiacName: zodiac.name,
      zodiacEmoji: zodiac.emoji,
      zodiacDateRange: zodiac.dateRange,
      overallScore: overall,
      loveScore: love,
      workScore: work,
      moneyScore: money,
      healthScore: health,
      luckyColor: _colors[colorIdx],
      luckyNumber: luckyNum,
      luckyItem: _items[itemIdx],
      message: _messages[msgIdx],
    );
  }
}
