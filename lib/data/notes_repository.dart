import 'package:dio/dio.dart';
import '../models/note.dart';
import 'api_client.dart';

class NotesRepository {
  final ApiClient _client;

  NotesRepository(this._client);

  Future<List<Note>> list(
      {int page = 1, int limit = 20, String search = ''}) async {
    final queryParameters = {
      'page': page,
      'limit': limit,
      if (search.isNotEmpty) 'title': search,
    };

    final resp = await _client.dio.get(
      '/notes',
      queryParameters: queryParameters,
    );

    final data = resp.data as List<dynamic>;
    return data.map((e) => Note.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Note> get(String id) async {
    final resp = await _client.dio.get('/notes/$id');
    return Note.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<Note> create(String title, String body) async {
    final resp = await _client.dio.post('/notes', data: {
      'title': title,
      'body': body,
      'createdAt': DateTime.now().toIso8601String(),
    });
    return Note.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<Note> update(String id, String title, String body) async {
    final resp = await _client.dio.put('/notes/$id', data: {
      'title': title,
      'body': body,
    });
    return Note.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<void> delete(String id) async {
    await _client.dio.delete('/notes/$id');
  }
}
