import 'package:flutter_test/flutter_test.dart';
import 'package:simple_notes/models/note.dart';

void main() {
  // Группа тестов для модели Note
  group('Note Model Tests', () {
    test('Note should handle empty title gracefully', () {
      // Создаем заметку с пустым заголовком
      final note = Note(id: '1', title: '', body: 'Текст заметки');

      // Проверяем, что заголовок пустой
      expect(note.title, isEmpty);

      // Проверяем, что тело не пустое
      expect(note.body, isNotEmpty);

      // Проверяем копирование с пустым заголовком
      final copied = note.copyWith(title: '');
      expect(copied.title, isEmpty);
    });

    test('Note should handle extremely long values', () {
      // Создаем очень длинный заголовок и текст
      final longTitle = 'A' * 1000; // 1000 символов
      final longBody = 'B' * 10000; // 10000 символов

      final note = Note(id: 'long_note', title: longTitle, body: longBody);

      // Проверяем, что значения сохранились
      expect(note.title, hasLength(1000));
      expect(note.body, hasLength(10000));

      // Проверяем, что заголовок начинается и заканчивается правильно
      expect(note.title.startsWith('A'), isTrue);
      expect(note.title.endsWith('A'), isTrue);

      // Проверяем копирование с длинными значениями
      final copied = note.copyWith(title: 'C' * 500);
      expect(copied.title, hasLength(500));
    });

    test('Note should handle edge cases with IDs', () {
      // Тест с минимальным ID
      final note1 = Note(
        id: '0', // Минимальное значение
        title: 'Заметка 1',
        body: 'Текст',
      );
      expect(note1.id, '0');

      // Тест с очень длинным ID
      final longId = 'id_' * 100; // Очень длинный ID
      final note2 = Note(id: longId, title: 'Заметка 2', body: 'Текст');
      expect(note2.id, hasLength(greaterThan(10)));

      // Тест с ID из спецсимволов (исправлено - убрали ¡)
      final specialId = '!#%&/()=?';
      final note3 = Note(id: specialId, title: 'Заметка 3', body: 'Текст');
      expect(note3.id, specialId);

      // Тест на то, что копирование не меняет ID
      final copied = note3.copyWith(title: 'Новый заголовок');
      expect(copied.id, equals(note3.id));
      expect(copied.title, isNot(equals(note3.title)));
    });
  });
}
