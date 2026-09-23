import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MainApp());
}

// ---------- データモデル ----------

class Task {
  final String id;
  final String name;
  final bool isDone;

  const Task({required this.id, required this.name, this.isDone = false});

  Task copyWith({bool? isDone}) =>
      Task(id: id, name: name, isDone: isDone ?? this.isDone);

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'isDone': isDone};

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'] as String,
        name: json['name'] as String,
        isDone: (json['isDone'] as bool?) ?? false,
      );
}

// ---------- アプリルート ----------

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'シンプルタスクくん',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: const TodoScreen(),
    );
  }
}

// ---------- メイン画面 ----------

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  static const _prefsKey = 'tasks_v1';

  final List<Task> _tasks = [];
  final TextEditingController _controller = TextEditingController();
  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // --- 永続化 ---

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    _prefs = prefs;
    final raw = prefs.getString(_prefsKey);
    if (raw != null) {
      final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      if (mounted) {
        setState(() => _tasks.addAll(list.map(Task.fromJson)));
      }
    }
  }

  Future<void> _saveTasks() async {
    await _prefs?.setString(
      _prefsKey,
      jsonEncode(_tasks.map((t) => t.toJson()).toList()),
    );
  }

  // --- タスク操作 ---

  void _addTask() {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    setState(() {
      _tasks.add(Task(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: name,
      ));
    });
    _controller.clear();
    _saveTasks();
  }

  void _toggleTask(int index) {
    setState(() {
      _tasks[index] = _tasks[index].copyWith(isDone: !_tasks[index].isDone);
    });
    _saveTasks();
  }

  void _deleteTask(int index) {
    setState(() => _tasks.removeAt(index));
    _saveTasks();
  }

  // --- UI ---

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final completedCount = _tasks.where((t) => t.isDone).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('シンプルタスクくん'),
        centerTitle: true,
        bottom: _tasks.isEmpty
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(24),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    '$completedCount / ${_tasks.length} 完了',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
      ),
      body: Column(
        children: [
          // 入力エリア
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'タスク名を入力…',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    ),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _addTask(),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: _addTask,
                  child: const Text('追加'),
                ),
              ],
            ),
          ),

          // タスク一覧
          Expanded(
            child: _tasks.isEmpty
                ? Center(
                    child: Text(
                      'タスクがありません\n上の欄から追加してください',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: _tasks.length,
                    itemBuilder: (context, index) {
                      final task = _tasks[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: CheckboxListTile(
                          controlAffinity: ListTileControlAffinity.leading,
                          value: task.isDone,
                          onChanged: (_) => _toggleTask(index),
                          title: Text(
                            task.name,
                            style: TextStyle(
                              decoration: task.isDone
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                              color: task.isDone
                                  ? theme.colorScheme.onSurfaceVariant
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                          secondary: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            tooltip: '削除',
                            onPressed: () => _deleteTask(index),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
