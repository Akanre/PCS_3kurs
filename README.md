Программирование корпоративных систем

Отчет по практической работе №9

Калтахчян Арен ЭФБО-06-23

Скриншот Dashboard: Database - Notes:

<img width="1919" height="1004" alt="image" src="https://github.com/user-attachments/assets/5113bd75-ba27-48fc-94f6-80c795c1ed85" />

Policies и RLS:

<img width="1919" height="988" alt="image" src="https://github.com/user-attachments/assets/486a78fe-9dd7-4bf1-8cce-9b8abe6bece4" />

Скриншот экрана входа и экрана с пустым списком:

<img width="1919" height="1000" alt="image" src="https://github.com/user-attachments/assets/6ddda040-dfec-472b-9f79-4797583aa43d" />

<img width="1919" height="1003" alt="image" src="https://github.com/user-attachments/assets/44f058b7-6a55-4d2e-820b-b16fcb9b49b0" />

Скриншот после редактироавния и удаления:

<img width="1919" height="1004" alt="image" src="https://github.com/user-attachments/assets/6ca912b3-ff91-4d02-9b83-43b222fb63b4" />

<img width="1919" height="471" alt="image" src="https://github.com/user-attachments/assets/4c807cdb-9f66-408c-96d9-9bf733c7b325" />

<img width="1919" height="366" alt="image" src="https://github.com/user-attachments/assets/9b4a8d3e-4ec0-49ea-8aa3-1f6b1cca74db" />


Шаги подключения:

Создал проект на supabase.com

Получил URL и ключ из настроек API

Создал таблицу notes с полями: id, user_id, title, content, created_at, updated_at

Включил RLS (защиту строк) и настроил политики доступа

const supabaseUrl = 'https://qfwnodkkolwncpbttcgu.supabase.co';

const supabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFmd25vZGtrb2x3bmNwYnR0Y2d1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE2Mzg5ODYsImV4cCI6MjA3NzIxNDk4Nn0.xg7QFioYewu6-kAmJCDYT6hR63FFXkEGGv4YbgSmBfE';


В pubspec.yaml добавил:

supabase_flutter: ^2.0.0


Инициализация в main.dart:

await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);


Таблица notes:

user_id - ID владельца

title, content - текст заметки

created_at, updated_at - даты


Политики RLS:

Чтение только своих записей

Добавление от своего имени

Изменение/удаление только своих заметок


Что нужно улучшить для продакшена:


1. Доступ только для вошедших пользователей

Сейчас: могут работать все

Нужно: разрешить только тем, кто вошел в систему


2. Строгая проверка данных

Сейчас: принимаем любой текст

Нужно: проверять длину, запрещать вредоносный код


3. Защита ключей

Сейчас: ключи в коде

Нужно: хранить в защищенных переменных окружения
