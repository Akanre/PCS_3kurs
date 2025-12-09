Программирование корпоративных систем

Отчет по практической работе №14

Калтахчян Арен ЭФБО-06-23

Flutter analyze:

<img width="631" height="90" alt="image" src="https://github.com/user-attachments/assets/afdc8f12-a84e-4fb8-ac87-ef9155d1497e" />


Flutter test:

<img width="709" height="154" alt="image" src="https://github.com/user-attachments/assets/c5a401fc-3037-48dc-a8d2-cb2191cb9022" />

Widget test:

<img width="870" height="68" alt="image" src="https://github.com/user-attachments/assets/7d580c76-710e-4f15-9e16-4b10dec4b291" />

Integration_test:

<img width="1150" height="987" alt="image" src="https://github.com/user-attachments/assets/ddc928ce-794d-402f-88a1-1d4cdc6a76e6" />

<img width="1140" height="600" alt="image" src="https://github.com/user-attachments/assets/85a13332-9e70-4566-aa8b-e9fd5a02aa0c" />

Performance overlay:

<img width="934" height="339" alt="image" src="https://github.com/user-attachments/assets/675427c6-902e-495c-add5-431fcdf3e863" />

<img width="936" height="727" alt="image" src="https://github.com/user-attachments/assets/5717b46a-ac0c-4a44-8af3-7e0fde2db932" />

Оптимизация:

Оптимизация 1: Стабильные Key для элементов списка

Было: ValueKey(note.id)

Стало: Key('note_${note.id}')

Эффект: Flutter точнее определяет, какие элементы изменились, уменьшает лишние перерисовки


Оптимизация 2: itemExtent для ListView.builder

Было: ListView.builder(...) без указания высоты

Стало: ListView.builder(..., itemExtent: 72.0)

Эффект: Фиксированная высота элементов улучшает производительность скроллинга, Flutter заранее знает размеры


Оптимизация 3: Кэширование результатов поиска

Было: Фильтрация при каждом изменении текста поиска

Стало: Кэширование результатов + debounce 100ms

Эффект: Ускорение поиска при повторных запросах, уменьшение нагрузки на UI поток


Оптимизация 4: Const-виджеты для неизменяемых поддеревьев

Было: Icon(Icons.add)

Стало: const Icon(Icons.add)

Эффект: Flutter не перерисовывает эти виджеты при обновлении состояния, экономит ресурсы


Оптимизация 5: Выделение логики элемента в отдельный метод

Было: Весь код элемента списка внутри itemBuilder (67 строк)

Стало: _buildNoteItem() метод (25 строк) + вызов в builder

Эффект: Улучшение читаемости, Flutter лучше оптимизирует отдельные методы построения

Проверка после оптимизации:

<img width="926" height="280" alt="image" src="https://github.com/user-attachments/assets/00dca52d-5a57-40d8-9366-0f6b47d6d15c" />

Анализ размера:

До:

<img width="1152" height="440" alt="image" src="https://github.com/user-attachments/assets/03d94ec7-e909-473b-a9ba-ca6310b642d5" />

После:

<img width="1148" height="501" alt="image" src="https://github.com/user-attachments/assets/e29ba769-8b0b-440c-8a72-81fef547ace5" />

Обработка ошибки:

<img width="1892" height="1059" alt="image" src="https://github.com/user-attachments/assets/80a131fd-509b-4fd1-95d6-f10c45695b1f" />

<img width="958" height="80" alt="image" src="https://github.com/user-attachments/assets/253ae479-14db-4342-b466-f0928989c060" />













