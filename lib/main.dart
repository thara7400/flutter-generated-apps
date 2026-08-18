import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(const KakeiboApp());
}

// ─── Model ───────────────────────────────────────────────────────────────────

class Expense {
  final String id;
  final DateTime date;
  final String category;
  final int amount;

  Expense({
    required this.id,
    required this.date,
    required this.category,
    required this.amount,
  });
}

// ─── Constants ───────────────────────────────────────────────────────────────

const _categories = ['食費', '交通費', '娯楽', '日用品', '医療', '衣類', 'その他'];

const _categoryColors = [
  Color(0xFF1565C0),
  Color(0xFF2E7D32),
  Color(0xFFC62828),
  Color(0xFFE65100),
  Color(0xFF6A1B9A),
  Color(0xFF00838F),
  Color(0xFF4E342E),
];

// ─── App ─────────────────────────────────────────────────────────────────────

class KakeiboApp extends StatelessWidget {
  const KakeiboApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '家計簿',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.teal,
        useMaterial3: true,
      ),
      home: const KakeiboScreen(),
    );
  }
}

// ─── Screen ──────────────────────────────────────────────────────────────────

class KakeiboScreen extends StatefulWidget {
  const KakeiboScreen({super.key});

  @override
  State<KakeiboScreen> createState() => _KakeiboScreenState();
}

class _KakeiboScreenState extends State<KakeiboScreen> {
  final List<Expense> _expenses = [];
  int _idCounter = 0;

  // ── Derived state ──────────────────────────────────────────────────────────

  int get _total => _expenses.fold(0, (s, e) => s + e.amount);

  Map<String, int> get _categoryTotals {
    final map = <String, int>{};
    for (final e in _expenses) {
      map[e.category] = (map[e.category] ?? 0) + e.amount;
    }
    return map;
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  void _deleteExpense(String id) {
    setState(() => _expenses.removeWhere((e) => e.id == id));
  }

  Future<void> _showAddDialog() async {
    DateTime selectedDate = DateTime.now();
    String selectedCategory = _categories.first;
    final amountController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final dateLabel =
              '${selectedDate.year}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.day.toString().padLeft(2, '0')}';

          return AlertDialog(
            title: const Text('支出を追加'),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Date picker ────────────────────────────────────────────
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setDialogState(() => selectedDate = picked);
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: '日付',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today, size: 20),
                      ),
                      child: Text(dateLabel),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Category dropdown ──────────────────────────────────────
                  DropdownButtonFormField<String>(
                    initialValue: selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'カテゴリ',
                      border: OutlineInputBorder(),
                    ),
                    items: _categories
                        .map((c) =>
                            DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) {
                        setDialogState(() => selectedCategory = v);
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // ── Amount ─────────────────────────────────────────────────
                  TextFormField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '金額',
                      border: OutlineInputBorder(),
                      suffixText: '円',
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return '金額を入力してください';
                      final n = int.tryParse(v);
                      if (n == null || n <= 0) return '正の整数を入力してください';
                      return null;
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('キャンセル'),
              ),
              FilledButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    setState(() {
                      _expenses.add(Expense(
                        id: '${++_idCounter}',
                        date: selectedDate,
                        category: selectedCategory,
                        amount: int.parse(amountController.text),
                      ));
                    });
                    Navigator.of(ctx).pop();
                  }
                },
                child: const Text('追加'),
              ),
            ],
          );
        },
      ),
    );

    amountController.dispose();
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final sortedExpenses = List<Expense>.from(_expenses)
      ..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      appBar: AppBar(
        title: const Text('家計簿'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        icon: const Icon(Icons.add),
        label: const Text('支出を追加'),
      ),
      body: Column(
        children: [
          // ── Total banner ───────────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            color: cs.primaryContainer,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '合計支出',
                  style: TextStyle(
                    color: cs.onPrimaryContainer,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '¥${_formatAmount(_total)}',
                  style: TextStyle(
                    color: cs.onPrimaryContainer,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // ── Chart or empty state ───────────────────────────────────────────
          if (_expenses.isEmpty)
            const Expanded(
              child: _EmptyState(),
            )
          else
            Expanded(
              child: Column(
                children: [
                  // Pie chart + legend
                  SizedBox(
                    height: 210,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: PieChart(
                              PieChartData(
                                sections: _buildSections(_categoryTotals),
                                sectionsSpace: 2,
                                centerSpaceRadius: 36,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: _Legend(
                              categoryTotals: _categoryTotals,
                              total: _total,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 1),

                  // Expense list
                  Expanded(
                    child: ListView.separated(
                      itemCount: sortedExpenses.length,
                      separatorBuilder: (_, _) =>
                          const Divider(height: 1, indent: 72),
                      itemBuilder: (ctx, i) {
                        final e = sortedExpenses[i];
                        return _ExpenseTile(
                          expense: e,
                          onDelete: () => _deleteExpense(e.id),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildSections(Map<String, int> totals) {
    final grand = totals.values.fold(0, (a, b) => a + b);
    if (grand == 0) return [];

    return totals.entries.map((entry) {
      final idx = _categories.indexOf(entry.key) % _categoryColors.length;
      final pct = entry.value / grand * 100;
      return PieChartSectionData(
        value: entry.value.toDouble(),
        color: _categoryColors[idx < 0 ? 0 : idx],
        radius: 72,
        title: pct >= 5 ? '${pct.toStringAsFixed(1)}%' : '',
        titleStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }
}

// ─── Helper Widgets ───────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.pie_chart_outline, size: 72, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            '支出がまだありません',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '右下の「支出を追加」から登録してください',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.categoryTotals, required this.total});

  final Map<String, int> categoryTotals;
  final int total;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: categoryTotals.entries.map((entry) {
            final idx =
                _categories.indexOf(entry.key) % _categoryColors.length;
            final color = _categoryColors[idx < 0 ? 0 : idx];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 11,
                    height: 11,
                    decoration:
                        BoxDecoration(color: color, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.key,
                          style: const TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '¥${_formatAmount(entry.value)}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _ExpenseTile extends StatelessWidget {
  const _ExpenseTile({required this.expense, required this.onDelete});

  final Expense expense;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final idx =
        _categories.indexOf(expense.category) % _categoryColors.length;
    final color = _categoryColors[idx < 0 ? 0 : idx];
    final dateStr =
        '${expense.date.year}/${expense.date.month.toString().padLeft(2, '0')}/${expense.date.day.toString().padLeft(2, '0')}';

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color,
        foregroundColor: Colors.white,
        child: Text(
          expense.category[0],
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
      ),
      title: Text(expense.category),
      subtitle: Text(dateStr, style: const TextStyle(fontSize: 12)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '¥${_formatAmount(expense.amount)}',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            tooltip: '削除',
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

// ─── Util ─────────────────────────────────────────────────────────────────────

String _formatAmount(int amount) {
  return amount
      .toString()
      .replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+$)'),
        (m) => '${m[1]},',
      );
}
