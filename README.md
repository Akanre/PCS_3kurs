Программирование корпоративных систем

Отчет по практической работе №8

Калтахчян Арен ЭФБО-06-23


1. Создание и привязка Firebase-проекта
Способ создания: Firebase CLI (flutterfire configure)

Процесс:

Выполнена команда flutterfire configure в терминале

Создан новый проект с уникальным ID

Автоматически сгенерирован файл firebase_options.dart

Настроены приложения для Android/Web


2. Используемые пакеты и инициализация
Пакеты в pubspec.yaml:

<img width="489" height="150" alt="image" src="https://github.com/user-attachments/assets/602d25cf-7271-4168-8dd0-c4bef7465cf0" />


  Инициализация в main.dart:
  
  <img width="931" height="151" alt="image" src="https://github.com/user-attachments/assets/616e5168-695c-448c-818d-901a7f4fd0b9" />

3. Структура данных в Firestore

<img width="1362" height="507" alt="image" src="https://github.com/user-attachments/assets/549cde05-ecf7-497c-a688-dcdaf0a49aad" />

4. Правила безопасности Firestore

<img width="923" height="260" alt="image" src="https://github.com/user-attachments/assets/40e2315b-9e6f-4716-bbdc-885487e8ab02" />


Почему недостаточно для продакшена:

1)Полный доступ для всех - любой может читать/писать данные

2)Нет проверки аутентификации - доступ без авторизации

3)Нет владения данными - пользователи могут изменять чужие заметки

4)Отсутствует валидация - нет проверки структуры данных

Скриншот настроенного проекта Firebase:

<img width="1918" height="1014" alt="image" src="https://github.com/user-attachments/assets/2245b3f0-8e1e-49cd-b7b3-af0ddbfaa514" />

Скриншот запущенного приложения:

<img width="1916" height="1115" alt="image" src="https://github.com/user-attachments/assets/88cb7578-05c2-4f2e-a741-202665774e4c" />

Скриншот после добаления заметки:

<img width="1918" height="1117" alt="image" src="https://github.com/user-attachments/assets/372925f4-7032-4e88-bc06-c90fcd7f148d" />

<img width="1917" height="1009" alt="image" src="https://github.com/user-attachments/assets/c1faf340-3e11-4375-a046-2029c005a909" />

Скриншот после редактирования:

<img width="1919" height="1117" alt="image" src="https://github.com/user-attachments/assets/ec1d5987-ea12-460e-ba3d-856b2af8221e" />

<img width="1918" height="1005" alt="image" src="https://github.com/user-attachments/assets/36ece97a-ff81-4a02-b17c-83b12f51e5a6" />

Скриншот после удаления:

<img width="1916" height="1115" alt="image" src="https://github.com/user-attachments/assets/af57c1a7-9a34-4892-85dc-847dd40d2880" />




