import 'package:flutter/material.dart';
import 'models/note.dart';
import 'edit_note_page.dart';

void main() => runApp(const SimpleNotesApp());

class SimpleNotesApp extends StatelessWidget {
  const SimpleNotesApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Simple Notes',
      theme: ThemeData(useMaterial3: true),
      home: const NotesPage(),
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

  @override
  void initState() {
    super.initState();
    _filteredNotes = _notes;
    _searchController.addListener(_filterNotes);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _addNote() async {
    final newNote = await Navigator.push<Note>(
      context,
      MaterialPageRoute(builder: (_) => EditNotePage()),
    );
    if (newNote != null) {
      setState(() {
        _notes.add(newNote);
        _filterNotes();
      });
    }
  }

  Future<void> _edit(Note note) async {
    final updated = await Navigator.push<Note>(
      context,
      MaterialPageRoute(builder: (_) => EditNotePage(existing: note)),
    );
    if (updated != null) {
      setState(() {
        final i = _notes.indexWhere((n) => n.id == updated.id);
        if (i != -1) _notes[i] = updated;
        _filterNotes();
      });
    }
  }

  void _delete(Note note) {
    setState(() {
      _notes.removeWhere((n) => n.id == note.id);
      _filterNotes();
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Заметка удалена')));
  }

  void _filterNotes() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredNotes = _notes;
      } else {
        _filteredNotes = _notes
            .where((note) => note.title.toLowerCase().contains(query))
            .toList();
      }
    });
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNote,
        child: const Icon(Icons.add),
      ),
      body: _filteredNotes.isEmpty
          ? const Center(child: Text('Пока нет заметок. Нажмите +'))
          : ListView.builder(
              itemCount: _filteredNotes.length,
              itemBuilder: (context, i) {
                final note = _filteredNotes[i];
                return Dismissible(
                  key: ValueKey(note.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: 20),
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) {
                    _notes.removeWhere((n) => n.id == note.id);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Заметка удалена')),
                    );
                  },
                  child: ListTile(
                    title: Text(
                      note.title.isEmpty ? '(без названия)' : note.title,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      note.body,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => _edit(note),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _delete(note),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
