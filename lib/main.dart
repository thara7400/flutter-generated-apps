import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class TodoItem {
  final String id;
  String title;
  DateTime? deadline;
  bool isDone;

  TodoItem({
    required this.id,
    required this.title,
    this.deadline,
    this.isDone = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'deadline': deadline?.toIso8601String(),
        'isDone': isDone,
      };

  factory TodoItem.fromJson(Map<String, dynamic> json) => TodoItem(
        id: json['id'] as String,
        title: json['title'] as String,
        deadline: json['deadline'] != null
            ? DateTime.parse(json['deadline'] as String)
            : null,
        isDone: json['isDone'] as bool,
      );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'シンプル to do',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const TodoListScreen(),
    );
  }
}

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  List<TodoItem> _todos = [];
  static const _prefsKey = 'todos';

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_prefsKey);
    if (jsonString != null) {
      final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;
      setState(() {
        _todos = jsonList
            .map((e) => TodoItem.fromJson(e as Map<String, dynamic>))
            .toList();
      });
    }
  }

  Future<void> _saveTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(_todos.map((e) => e.toJson()).toList());
    await prefs.setString(_prefsKey, jsonString);
  }

  void _toggleDone(TodoItem todo) {
    setState(() {
      todo.isDone = !todo.isDone;
    });
    _saveTodos();
  }

  void _deleteTodo(TodoItem todo) {
    setState(() {
      _todos.remove(todo);
    });
    _saveTodos();
  }

  Future<void> _showAddDialog() async {
    final titleController = TextEditingController();
    DateTime? selectedDate;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('やることを追加'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'やること',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      selectedDate == null
                          ? '締め切り未設定'
                          : '締め切り: ${DateFormat('yyyy/MM/dd').format(selectedDate!)}',
                      style: TextStyle(
                        color: selectedDate == null
                            ? Theme.of(ctx).colorScheme.outline
                            : null,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.calendar_today, size: 18),
                    label: const Text('日付を選ぶ'),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setDialogState(() => selectedDate = picked);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('キャンセル'),
            ),
            FilledButton(
              onPressed: () {
                final title = titleController.text.trim();
                if (title.isEmpty) return;
                setState(() {
                  _todos.add(TodoItem(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: title,
                    deadline: selectedDate,
                  ));
                });
                _saveTodos();
                Navigator.of(ctx).pop();
              },
              child: const Text('追加'),
            ),
          ],
        ),
      ),
    );
  }

  bool _isOverdue(TodoItem todo) {
    if (todo.deadline == null || todo.isDone) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final deadlineDay = DateTime(
      todo.deadline!.year,
      todo.deadline!.month,
      todo.deadline!.day,
    );
    return deadlineDay.isBefore(today);
  }

  @override
  Widget build(BuildContext context) {
    final pending = _todos.where((t) => !t.isDone).toList();
    final done = _todos.where((t) => t.isDone).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('シンプル to do'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _todos.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'やることを追加してみましょう！',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                if (pending.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    child: Text(
                      '未完了 (${pending.length})',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ),
                  ...pending.map((todo) => _TodoTile(
                        todo: todo,
                        isOverdue: _isOverdue(todo),
                        onToggle: () => _toggleDone(todo),
                        onDelete: () => _deleteTodo(todo),
                      )),
                ],
                if (done.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                    child: Text(
                      '完了 (${done.length})',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                    ),
                  ),
                  ...done.map((todo) => _TodoTile(
                        todo: todo,
                        isOverdue: false,
                        onToggle: () => _toggleDone(todo),
                        onDelete: () => _deleteTodo(todo),
                      )),
                ],
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        icon: const Icon(Icons.add),
        label: const Text('追加'),
      ),
    );
  }
}

class _TodoTile extends StatelessWidget {
  const _TodoTile({
    required this.todo,
    required this.isOverdue,
    required this.onToggle,
    required this.onDelete,
  });

  final TodoItem todo;
  final bool isOverdue;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textColor = todo.isDone ? colorScheme.outline : null;

    String? deadlineLabel;
    Color? deadlineColor;
    if (todo.deadline != null) {
      deadlineLabel = '締め切り: ${DateFormat('yyyy/MM/dd').format(todo.deadline!)}';
      if (isOverdue) {
        deadlineLabel = '⚠ $deadlineLabel（期限切れ）';
        deadlineColor = colorScheme.error;
      } else if (todo.isDone) {
        deadlineColor = colorScheme.outline;
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      color: todo.isDone ? colorScheme.surfaceContainerLowest : null,
      child: ListTile(
        leading: Checkbox(
          value: todo.isDone,
          onChanged: (_) => onToggle(),
        ),
        title: Text(
          todo.title,
          style: TextStyle(
            color: textColor,
            decoration: todo.isDone ? TextDecoration.lineThrough : null,
            decorationColor: textColor,
          ),
        ),
        subtitle: deadlineLabel != null
            ? Text(
                deadlineLabel,
                style: TextStyle(
                  color: deadlineColor,
                  fontWeight: isOverdue ? FontWeight.bold : null,
                ),
              )
            : null,
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: onDelete,
          tooltip: '削除',
          color: colorScheme.outline,
        ),
      ),
    );
  }
}
