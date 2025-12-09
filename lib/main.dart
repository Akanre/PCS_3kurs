import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'models/note.dart';
import 'edit_note_page.dart';

void main() {
  // Настройка зоны для перехвата асинхронных ошибок
  runZonedGuarded(
    () {
      // Настройка обработчика ошибок Flutter
      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details);

        // Логируем ошибку
        _logError(details.exception.toString(), details.stack);

        if (kDebugMode) {
          print(
            '════════════════════════════════════════════════════════════════════',
          );
          print('FLUTTER ERROR: ${details.exception}');
          print(
            '════════════════════════════════════════════════════════════════════',
          );
        }
      };

      // Кастомный виджет для отображения ошибок
      ErrorWidget.builder = (FlutterErrorDetails details) {
        return _buildErrorScreen(details);
      };

      // Запускаем приложение
      runApp(const SimpleNotesApp());
    },
    (error, stackTrace) {
      // Перехват асинхронных ошибок вне Flutter
      _logError(error.toString(), stackTrace);

      if (kDebugMode) {
        print(
          '════════════════════════════════════════════════════════════════════',
        );
        print('ASYNC ERROR: $error');
        print('Stack trace: $stackTrace');
        print(
          '════════════════════════════════════════════════════════════════════',
        );
      }
    },
  );
}

void _logError(String error, StackTrace? stackTrace) {
  // TODO: Интеграция с Sentry/Crashlytics
  if (kDebugMode) {
    print('[ERROR LOGGED]: $error');
    if (stackTrace != null) {
      print('Stack trace: $stackTrace');
    }
  }
}

Widget _buildErrorScreen(FlutterErrorDetails details) {
  return Material(
    color: Colors.white,
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sentiment_dissatisfied, color: Colors.orange, size: 80),
            const SizedBox(height: 20),
            Text(
              'Что-то пошло не так',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Мы уже работаем над исправлением',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                // В реальном приложении можно перезапустить
                // Пока просто скрываем ошибку
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Обновить'),
            ),
          ],
        ),
      ),
    ),
  );
}

class SimpleNotesApp extends StatelessWidget {
  const SimpleNotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Simple Notes',
      theme: ThemeData(useMaterial3: true),
      home: NotesPage(),
    );
  }
}

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final List<Note> _notes = [
    Note(id: '1', title: 'Пример', body: 'Это пример заметки'),
  ];

  final TextEditingController _searchController = TextEditingController();
  List<Note> _filteredNotes = [];
  final Map<String, List<Note>> _searchCache = {};
  bool _isFiltering = false;

  @override
  void initState() {
    super.initState();
    _filteredNotes = _notes;
    _searchController.addListener(_optimizedFilterNotes);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchCache.clear();
    super.dispose();
  }

  void _generateTestNotes() {
    try {
      setState(() {
        for (int i = 0; i < 1000; i++) {
          _notes.add(
            Note(
              id: 'test_${DateTime.now().millisecondsSinceEpoch}_$i',
              title: 'Тестовая заметка №$i',
              body:
                  'Это тестовое содержимое заметки номер $i. '
                  'Текст для проверки производительности при скроллинге.',
            ),
          );
        }
        _optimizedFilterNotes();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Сгенерировано 1000 тестовых заметок')),
        );
      });
    } catch (e, stackTrace) {
      _logError('Ошибка при генерации тестовых заметок: $e', stackTrace);
      _showErrorSnackbar('Не удалось сгенерировать тестовые данные');
    }
  }

  void _optimizedFilterNotes() {
    if (_isFiltering) return;
    _isFiltering = true;

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        try {
          final query = _searchController.text.toLowerCase();

          if (_searchCache.containsKey(query)) {
            setState(() {
              _filteredNotes = _searchCache[query]!;
            });
            _isFiltering = false;
            return;
          }

          List<Note> filtered;
          if (query.isEmpty) {
            filtered = _notes;
          } else {
            filtered = _notes
                .where((note) => note.title.toLowerCase().contains(query))
                .toList();
          }

          _searchCache[query] = filtered;
          if (_searchCache.length > 10) {
            _searchCache.remove(_searchCache.keys.first);
          }

          setState(() {
            _filteredNotes = filtered;
          });
        } catch (e, stackTrace) {
          _logError('Ошибка при фильтрации заметок: $e', stackTrace);
        } finally {
          _isFiltering = false;
        }
      }
    });
  }

  Future<void> _addNote() async {
    try {
      final newNote = await Navigator.push<Note>(
        context,
        MaterialPageRoute(builder: (_) => const EditNotePage()),
      );
      if (newNote != null) {
        setState(() {
          _notes.add(newNote);
          _optimizedFilterNotes();
        });
      }
    } catch (e, stackTrace) {
      _logError('Ошибка при создании заметки: $e', stackTrace);
      _showErrorSnackbar('Не удалось создать заметку');
    }
  }

  Future<void> _edit(Note note) async {
    try {
      final updated = await Navigator.push<Note>(
        context,
        MaterialPageRoute(builder: (_) => EditNotePage(existing: note)),
      );
      if (updated != null) {
        setState(() {
          final i = _notes.indexWhere((n) => n.id == updated.id);
          if (i != -1) _notes[i] = updated;
          _optimizedFilterNotes();
        });
      }
    } catch (e, stackTrace) {
      _logError('Ошибка при редактировании заметки: $e', stackTrace);
      _showErrorSnackbar('Не удалось сохранить изменения');
    }
  }

  void _delete(Note note) {
    try {
      setState(() {
        _notes.removeWhere((n) => n.id == note.id);
        _searchCache.clear();
        _optimizedFilterNotes();
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Заметка удалена')));
    } catch (e, stackTrace) {
      _logError('Ошибка при удалении заметки: $e', stackTrace);
      _showErrorSnackbar('Не удалось удалить заметку');
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildNoteItem(Note note) {
    return Dismissible(
      key: Key('note_${note.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => _delete(note),
      child: ListTile(
        title: Text(
          note.title.isEmpty ? '(без названия)' : note.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(note.body, maxLines: 1, overflow: TextOverflow.ellipsis),
        onTap: () => _edit(note),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () => _delete(note),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Поиск заметок...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            hintStyle: TextStyle(color: Colors.black),
          ),
          style: const TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.data_array),
            onPressed: _generateTestNotes,
            tooltip: 'Сгенерировать 1000 тестовых заметок',
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.small(
            heroTag: 'generate_test',
            onPressed: _generateTestNotes,
            child: const Icon(Icons.add_chart),
            tooltip: 'Генерация тестовых данных',
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'add_note',
            onPressed: _addNote,
            child: const Icon(Icons.add),
          ),
        ],
      ),
      body: _filteredNotes.isEmpty
          ? const Center(child: Text('Пока нет заметок. Нажмите +'))
          : ListView.builder(
              itemCount: _filteredNotes.length,
              itemBuilder: (context, i) => _buildNoteItem(_filteredNotes[i]),
              itemExtent: 72.0,
            ),
    );
  }
}
