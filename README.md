Программироание корпортаивных систем

Калтахчян Арен ЭФБО-06-23

Отчет по Практической работе №10

Скриншот первого запуска:

<img width="446" height="946" alt="image" src="https://github.com/user-attachments/assets/3d3f1eed-83a8-47dd-8a74-3afabf6f1d1d" />

Скриншот после добавления заметки:

<img width="457" height="959" alt="image" src="https://github.com/user-attachments/assets/0ff5a216-24cd-4bb8-a633-4375111019e4" />

Скриншот окна редактирования и итоговой записи:

<img width="450" height="951" alt="image" src="https://github.com/user-attachments/assets/cb52a7d9-a1d3-4d07-890d-f6e6fe5e3df4" />

<img width="449" height="957" alt="image" src="https://github.com/user-attachments/assets/fe4a0b0a-2431-440d-9d0c-d6d782726517" />

Скриншот после удаления:

<img width="448" height="958" alt="image" src="https://github.com/user-attachments/assets/19fd6ed4-f5c7-4cfa-83eb-97960c3c5929" />

<img width="453" height="956" alt="image" src="https://github.com/user-attachments/assets/a872ed72-9bb9-4ac9-9d2c-db11782f0ab2" />

Расположение файла DB:

Файл базы данных app.db хранится в директории документов приложения, путь к которой зависит от платформы


Доступ к DB:

static Future<Database> _open() async {

  final docs = await getApplicationDocumentsDirectory();
  
  final dbPath = p.join(docs.path, _dbName);
  
  return await openDatabase(dbPath, version: _dbVersion, onCreate: _onCreate);
  
}


Таблица notes:

CREATE TABLE notes(

  id INTEGER PRIMARY KEY AUTOINCREMENT,
  
  title TEXT NOT NULL,
  
  body TEXT NOT NULL,
  
  created_at INTEGER NOT NULL,
  
  updated_at INTEGER NOT NULL
  
);


Индексы:

CREATE INDEX idx_notes_created_at ON notes(created_at DESC);


CRUD операции:

Создание - INSERT

<img width="537" height="269" alt="image" src="https://github.com/user-attachments/assets/4ac82362-17a7-427b-be0d-638a5d315bdb" />

Чтение - SELECT

<img width="779" height="164" alt="image" src="https://github.com/user-attachments/assets/56757862-b2d0-465b-86e3-00a2f0de5ffc" />

Обновление - UPDATE

<img width="568" height="332" alt="image" src="https://github.com/user-attachments/assets/937b07a6-442c-4d99-997f-80627ff83fac" />

Поиск заметок:

<img width="696" height="329" alt="image" src="https://github.com/user-attachments/assets/0cba8be9-8d43-49ae-aaa4-318ef2191142" />









