Программироавние корпоративных систем

Отчет по практической работе №12

Калтахчян Арен ЭФБО-06-23

Скриншот главного экрана при запуске:

<img width="576" height="1280" alt="image" src="https://github.com/user-attachments/assets/191fbe87-cb75-40b9-9407-35a6ef03cebf" />

Скриншот камеры в действии:

<img width="576" height="1280" alt="image" src="https://github.com/user-attachments/assets/02524426-6dcf-4e34-b9f6-8aa1a93805a7" />

<img width="576" height="1280" alt="image" src="https://github.com/user-attachments/assets/8cacf1d9-e34a-40ed-bba2-7015d9f26771" />

Скриншот отображения выбранного фото:

<img width="576" height="1280" alt="image" src="https://github.com/user-attachments/assets/ac259620-d843-4964-95c3-8a86382b6ea6" />


Краткое описание шагов реализации

Создание проекта - инициализация Flutter-приложения camera_app


Установка зависимостей - добавление в pubspec.yaml пакетов:


image_picker - для работы с камерой и галереей

permission_handler - для управления разрешениями

path_provider - для работы с файловой системой


Настройка разрешений - добавление в AndroidManifest.xml и Info.plist соответствующих прав доступа к камере и хранилищу


Реализация логики приложения:


Создание интерфейса с кнопками управления

Реализация методов для съемки фото и выбора из галереи

Добавление функции сохранения изображений в локальное хранилище

Ключевые фрагменты кода:

Работа с камерой и галереей: 

<img width="743" height="239" alt="image" src="https://github.com/user-attachments/assets/08100145-0756-4dd5-a784-243bfd50d2be" />

Сохранение изображения:

<img width="754" height="341" alt="image" src="https://github.com/user-attachments/assets/7a026762-78da-4e85-a47d-314418d0897c" />



