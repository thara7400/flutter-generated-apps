import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MainApp());
}

class BookEntry {
  final String title;
  final String review;

  const BookEntry({required this.title, required this.review});

  Map<String, dynamic> toJson() => {'title': title, 'review': review};

  factory BookEntry.fromJson(Map<String, dynamic> json) => BookEntry(
        title: json['title'] as String,
        review: json['review'] as String,
      );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'よんだ本ノート',
      theme: ThemeData(
        colorSchemeSeed: Colors.teal,
        useMaterial3: true,
      ),
      home: const BookNoteScreen(),
    );
  }
}

class BookNoteScreen extends StatefulWidget {
  const BookNoteScreen({super.key});

  @override
  State<BookNoteScreen> createState() => _BookNoteScreenState();
}

class _BookNoteScreenState extends State<BookNoteScreen> {
  final _titleController = TextEditingController();
  final _reviewController = TextEditingController();
  final List<BookEntry> _books = [];
  static const _storageKey = 'book_entries';

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _loadBooks() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null) return;
    final list = jsonDecode(raw) as List<dynamic>;
    setState(() {
      _books.addAll(
        list.map((e) => BookEntry.fromJson(e as Map<String, dynamic>)),
      );
    });
  }

  Future<void> _saveBooks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode(_books.map((b) => b.toJson()).toList()),
    );
  }

  void _addBook() {
    final title = _titleController.text.trim();
    final review = _reviewController.text.trim();
    if (title.isEmpty) return;
    setState(() {
      _books.insert(0, BookEntry(title: title, review: review));
    });
    _saveBooks();
    _titleController.clear();
    _reviewController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('よんだ本ノート'),
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: '本のタイトル',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.book),
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _reviewController,
                    decoration: const InputDecoration(
                      labelText: '感想',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.edit_note),
                    ),
                    maxLines: 3,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _addBook(),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _addBook,
                    icon: const Icon(Icons.add),
                    label: const Text('追加する'),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: _books.isEmpty
                ? Center(
                    child: Text(
                      'まだ本が登録されていません',
                      style: TextStyle(color: colorScheme.outline),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    itemCount: _books.length,
                    itemBuilder: (context, index) {
                      final book = _books[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.menu_book, size: 18),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      book.title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                              if (book.review.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(
                                  book.review,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ],
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
