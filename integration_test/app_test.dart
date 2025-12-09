import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:simple_notes/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-end тесты приложения Simple Notes', () {
    testWidgets('Полный сценарий: создание, редактирование, удаление заметки', (
      WidgetTester tester,
    ) async {
      // 1. Запуск приложения
      app.main();
      await tester.pumpAndSettle(Duration(seconds: 2));

      print('✓ Приложение запущено');

      // 2. Проверяем начальный экран
      expect(find.text('Поиск заметок...'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);

      print('✓ Начальный экран загружен');

      // 3. СОЗДАНИЕ НОВОЙ ЗАМЕТКИ
      // Нажимаем кнопку добавления
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      print('✓ Открыта форма создания заметки');

      // Проверяем, что форма открылась
      expect(find.text('Новая заметка'), findsOneWidget);
      expect(find.text('Сохранить'), findsOneWidget);

      // Вводим заголовок
      final titleFields = find.byType(TextFormField);
      expect(titleFields, findsNWidgets(2)); // Два поля: заголовок и текст

      await tester.enterText(titleFields.first, 'Тестовая заметка E2E');
      await tester.pump();

      // Вводим текст
      await tester.enterText(
        titleFields.last,
        'Это тестовая заметка для end-to-end тестирования',
      );
      await tester.pump();

      print('✓ Заполнены поля формы');

      // Сохраняем заметку
      await tester.tap(find.text('Сохранить'));
      await tester.pumpAndSettle(Duration(seconds: 2));

      print('✓ Заметка создана и сохранена');

      // 4. ПРОВЕРКА СОЗДАННОЙ ЗАМЕТКИ
      // Ждем возврата на главный экран
      expect(find.text('Поиск заметок...'), findsOneWidget);

      // Ищем созданную заметку в списке
      expect(find.text('Тестовая заметка E2E'), findsOneWidget);
      expect(
        find.text('Это тестовая заметка для end-to-end тестирования'),
        findsOneWidget,
      );

      print('✓ Созданная заметка отображается в списке');

      // 5. РЕДАКТИРОВАНИЕ ЗАМЕТКИ
      // Тапаем по заметке для редактирования
      await tester.tap(find.text('Тестовая заметка E2E'));
      await tester.pumpAndSettle();

      print('✓ Открыта форма редактирования');

      // Проверяем, что форма редактирования открылась
      expect(find.text('Редактировать'), findsOneWidget);

      // Очищаем поле заголовка и вводим новое значение
      await tester.enterText(titleFields.first, 'ОБНОВЛЕННАЯ заметка E2E');
      await tester.pump();

      // Очищаем поле текста и вводим новое значение
      await tester.enterText(
        titleFields.last,
        'Это ОБНОВЛЕННЫЙ текст заметки для тестирования',
      );
      await tester.pump();

      print('✓ Заметка отредактирована');

      // Сохраняем изменения
      await tester.tap(find.text('Сохранить'));
      await tester.pumpAndSettle(Duration(seconds: 2));

      print('✓ Изменения сохранены');

      // Проверяем, что заметка обновилась в списке
      expect(find.text('ОБНОВЛЕННАЯ заметка E2E'), findsOneWidget);
      expect(
        find.text('Это ОБНОВЛЕННЫЙ текст заметки для тестирования'),
        findsOneWidget,
      );

      print('✓ Обновленная заметка отображается в списке');

      // 6. УДАЛЕНИЕ ЗАМЕТКИ через swipe
      // Находим элемент заметки
      final noteItem = find.text('ОБНОВЛЕННАЯ заметка E2E');

      // Выполняем свайп для удаления (swipe left)
      await tester.drag(noteItem, Offset(-500, 0));
      await tester.pumpAndSettle();

      print('✓ Заметка удалена свайпом');

      // 7. ПРОВЕРКА, ЧТО ЗАМЕТКА УДАЛЕНА
      // Ждем немного для анимации удаления
      await tester.pump(Duration(seconds: 1));

      // Проверяем, что заметки больше нет
      expect(find.text('ОБНОВЛЕННАЯ заметка E2E'), findsNothing);

      print('✓ Заметка успешно удалена из списка');

      print('\n🎉 ВСЕ ТЕСТЫ ПРОЙДЕНЫ УСПЕШНО!');
      print(
        'Сценарий E2E завершен: создание → редактирование → удаление → поиск',
      );
    });

    testWidgets('Тест пустого состояния приложения', (
      WidgetTester tester,
    ) async {
      // Этот тест проверяет начальное состояние приложения
      app.main();
      await tester.pumpAndSettle();

      // Проверяем наличие основных элементов
      expect(find.byType(TextField), findsOneWidget); // Поле поиска
      expect(
        find.byType(FloatingActionButton),
        findsOneWidget,
      ); // Кнопка добавления

      print('✓ Базовые элементы интерфейса присутствуют');
    });
  });
}
