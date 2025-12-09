import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_notes/main.dart';

void main() {
  testWidgets('NotesPage renders correctly with title and search field', (
    WidgetTester tester,
  ) async {
    // Запускаем приложение
    await tester.pumpWidget(const SimpleNotesApp());

    // Проверяем, что поле поиска отображается
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Поиск заметок...'), findsOneWidget);

    // Проверяем, что кнопка добавления отображается
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });

  testWidgets('Tapping FloatingActionButton opens edit note dialog', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SimpleNotesApp());

    // Находим и нажимаем кнопку добавления
    final fab = find.byType(FloatingActionButton);
    await tester.tap(fab);
    await tester.pumpAndSettle(); // Ждем анимацию перехода

    // Проверяем, что открылась страница редактирования
    expect(find.text('Новая заметка'), findsOneWidget);
    expect(find.text('Заголовок'), findsOneWidget);
    expect(find.text('Текст'), findsOneWidget);
    expect(find.text('Сохранить'), findsOneWidget);
  });

  testWidgets('Adding a new note through the form', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SimpleNotesApp());

    // Нажимаем FAB для создания новой заметки
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Вводим заголовок
    final titleField = find.widgetWithText(TextFormField, 'Заголовок');
    await tester.enterText(titleField, 'Тестовая заметка');

    // Вводим текст
    final bodyField = find.widgetWithText(TextFormField, 'Текст');
    await tester.enterText(bodyField, 'Это текст тестовой заметки');

    // Сохраняем заметку
    final saveButton = find.text('Сохранить');
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    // Проверяем, что вернулись на главный экран
    expect(find.text('Поиск заметок...'), findsOneWidget);
  });
}
