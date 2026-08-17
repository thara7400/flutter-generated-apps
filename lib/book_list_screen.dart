import 'package:flutter/material.dart';
import 'book_detail_screen.dart';
import 'db.dart';

class BookListScreen extends StatefulWidget {
  const BookListScreen({super.key});

  @override
  State<BookListScreen> createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  List<Book> _books = [];

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    final books = await AppDatabase.instance.getAllBooks();
    if (mounted) setState(() => _books = books);
  }

  Future<void> _showAddDialog() async {
    final controller = TextEditingController();

    String? result;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('本を追加'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: '本のタイトルを入力'),
          textInputAction: TextInputAction.done,
          onSubmitted: (v) {
            if (v.trim().isNotEmpty) {
              result = v.trim();
              Navigator.pop(ctx);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              final v = controller.text.trim();
              if (v.isNotEmpty) {
                result = v;
                Navigator.pop(ctx);
              }
            },
            child: const Text('追加'),
          ),
        ],
      ),
    );

    if (result != null) {
      await AppDatabase.instance.insertBook(result!);
      await _loadBooks();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('よんだ本ノート'),
      ),
      body: _books.isEmpty
          ? const Center(
              child: Text(
                '本がまだありません\n右下の＋から追加してください',
                textAlign: TextAlign.center,
              ),
            )
          : ListView.separated(
              itemCount: _books.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final book = _books[index];
                return ListTile(
                  title: Text(book.title),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BookDetailScreen(book: book),
                      ),
                    );
                    await _loadBooks();
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
