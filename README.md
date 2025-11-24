Программирование корпоратиных систем

Отчет по практической работе №11

Калтахчян Арен ЭФБО-06-23

Скрин экрана списка:


<img width="1917" height="1011" alt="Снимок экрана 2025-11-25 004314" src="https://github.com/user-attachments/assets/49b78b8d-0cff-4bce-b0ca-0a3342ac1134" />


Скрин диалога создания и результата:


<img width="1918" height="1012" alt="image" src="https://github.com/user-attachments/assets/9a2e8e62-e20a-4c4a-b2b5-d3fb2420fabe" />


<img width="1919" height="1002" alt="image" src="https://github.com/user-attachments/assets/40322bc7-2d0b-4988-9133-6fc15eb4a98b" />

Использовал вариант В API

URL: https://mockapi.io/projects/6924ca6682b59600d7215c4d

Эндпоинты:


GET /notes - список заметок с пагинацией


POST /notes - создание заметки


GET /notes/:id - получение конкретной заметки


PUT /notes/:id - обновление заметки


DELETE /notes/:id - удаление заметки


Модель:


<img width="954" height="439" alt="image" src="https://github.com/user-attachments/assets/f524194c-b81e-4537-b6d8-b6a274bf68e4" />

Репозиторий:


<img width="932" height="497" alt="image" src="https://github.com/user-attachments/assets/133c02fe-a5e4-4209-aa3b-ea19c1803d64" />


Пагинация:



<img width="621" height="297" alt="image" src="https://github.com/user-attachments/assets/9a759023-cf63-4bbf-bd97-d410f23fba5b" />


Реализован бесконечный скролл с автоматической подгрузкой. При достижении конца списка запрашивается следующая страница через параметры page и limit. В UI отображается индикатор загрузки.


Обработка ошибок:



<img width="691" height="566" alt="image" src="https://github.com/user-attachments/assets/a224be6a-05d2-4006-96aa-73f0cbfb5748" />


Настроены таймауты 10 секунд. При сетевых ошибках выполняются ретраи с экспоненциальной задержкой 0.5s → 1s → 2s. Ошибки показываются через цветные Snackbar.


Поиск:



<img width="721" height="202" alt="image" src="https://github.com/user-attachments/assets/0dd70a48-5dab-48a8-88e1-c0deaeb6c7a4" />




