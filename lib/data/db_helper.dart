import 'dart:async';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/note.dart';

class DBHelper {
  static const _dbName = 'app.db';
  static const _dbVersion = 1;
  static Database? _db;
  static bool _isInitializing = false;
  static Completer<Database>? _completer;

  static const notesTable = 'notes';

  static Future<Database> _open() async {
    if (_db != null) return _db!;

    // Если уже инициализируемся, ждем завершения
    if (_completer != null) return _completer!.future;

    _completer = Completer<Database>();

    try {
      final docs = await getApplicationDocumentsDirectory();
      final dbPath = p.join(docs.path, _dbName);

      _db = await openDatabase(
        dbPath,
        version: _dbVersion,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE $notesTable(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              title TEXT NOT NULL,
              body TEXT NOT NULL,
              created_at INTEGER NOT NULL,
              updated_at INTEGER NOT NULL
            );
          ''');
          await db.execute(
            'CREATE INDEX idx_notes_created_at ON $notesTable(created_at DESC);',
          );
        },
        onUpgrade: (db, oldV, newV) async {
          // Пример миграции:
          // if (oldV < 2) { await db.execute('ALTER TABLE $notesTable ADD COLUMN ...'); }
        },
      );

      _completer!.complete(_db);
      return _db!;
    } catch (e) {
      _completer!.completeError(e);
      rethrow;
    }
  }

  // CREATE
  static Future<int> insertNote(Note note) async {
    final db = await _open();
    return db.insert(
      notesTable,
      note.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  // READ all (сортировка по created_at DESC)
  static Future<List<Note>> fetchNotes() async {
    final db = await _open();
    final rows = await db.query(notesTable, orderBy: 'created_at DESC');
    return rows.map((m) => Note.fromMap(m)).toList();
  }

  // SEARCH notes by title
  static Future<List<Note>> searchNotes(String query) async {
    final db = await _open();
    final rows = await db.query(
      notesTable,
      where: 'title LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'created_at DESC',
    );
    return rows.map((m) => Note.fromMap(m)).toList();
  }

  // UPDATE
  static Future<int> updateNote(Note note) async {
    final db = await _open();
    return db.update(
      notesTable,
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  // DELETE
  static Future<int> deleteNote(int id) async {
    final db = await _open();
    return db.delete(notesTable, where: 'id = ?', whereArgs: [id]);
  }
}
