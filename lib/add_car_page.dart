import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'supabase_config.dart';
import 'models.dart';

class AddCarPage extends StatefulWidget {
  const AddCarPage({super.key});

  @override
  State<AddCarPage> createState() => _AddCarPageState();
}

class _AddCarPageState extends State<AddCarPage> {
  File? _image;
  final _modelNameController = TextEditingController();
  final _commentController = TextEditingController();
  final _picker = ImagePicker();
  bool _isLoading = false;
  String? _errorMessage;

  // МЕТОД ДЛЯ СЖАТИЯ ИЗОБРАЖЕНИЯ
  Future<File?> _compressImage(File originalImage) async {
    try {
      print('Сжимаем изображение...');

      // Читаем исходный файл
      final bytes = await originalImage.readAsBytes();

      // Декодируем изображение
      final decodedImage = img.decodeImage(bytes);
      if (decodedImage == null) {
        print('Не удалось декодировать изображение');
        return originalImage;
      }

      // Сжимаем: уменьшаем ширину до 1200px
      final compressedImage = img.copyResize(
        decodedImage,
        width: 1200,
        maintainAspect: true,
      );

      // Сохраняем с качеством 85%
      final compressedBytes = img.encodeJpg(compressedImage, quality: 85);

      // Сохраняем во временный файл
      final tempDir = await getTemporaryDirectory();
      final compressedFile = File(
        '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      await compressedFile.writeAsBytes(compressedBytes);

      return compressedFile;
    } catch (e) {
      print('Ошибка сжатия: $e');
      return originalImage;
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Ошибка выбора фото: $e';
      });
    }
  }

  Future<String?> _uploadImage() async {
    if (_image == null) {
      setState(() => _errorMessage = 'Выберите фото машинки');
      return null;
    }

    try {
      final userId = SupabaseConfig.client.auth.currentUser?.id;
      if (userId == null) {
        setState(() => _errorMessage = 'Пользователь не авторизован');
        return null;
      }

      // СЖИМАЕМ ИЗОБРАЖЕНИЕ ПЕРЕД ЗАГРУЗКОЙ
      final compressedFile = await _compressImage(_image!);

      // Создаем имя файла
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '$userId/car_$timestamp.jpg';

      // Загружаем в Supabase Storage
      await SupabaseConfig.client.storage
          .from('car-images')
          .upload(fileName, compressedFile!);

      // Получаем публичный URL
      final imageUrl = SupabaseConfig.client.storage
          .from('car-images')
          .getPublicUrl(fileName);

      print('Фото загружено: $imageUrl');
      return imageUrl;
    } catch (e) {
      print('Ошибка загрузки фото: $e');
      setState(() => _errorMessage = 'Ошибка загрузки фото: $e');
      return null;
    }
  }

  Future<void> _saveCar() async {
    if (_modelNameController.text.isEmpty) {
      setState(() => _errorMessage = 'Введите название модели');
      return;
    }

    if (_image == null) {
      setState(() => _errorMessage = 'Выберите фото машинки');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1. Загружаем фото
      final imageUrl = await _uploadImage();
      if (imageUrl == null) {
        setState(() => _isLoading = false);
        return;
      }

      // 2. Получаем ID пользователя
      final userId = SupabaseConfig.client.auth.currentUser?.id;
      if (userId == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Пользователь не авторизован';
        });
        return;
      }

      // 3. Сохраняем в базу данных
      await SupabaseConfig.client.from('toy_cars').insert({
        'user_id': userId,
        'image_url': imageUrl,
        'model_name': _modelNameController.text.trim(),
        'comment': _commentController.text.trim().isEmpty
            ? null
            : _commentController.text.trim(),
        'is_favorite': false,
      });

      print('Машинка сохранена в БД');

      // 4. Возвращаемся на главную
      Navigator.pop(context, true);
    } catch (e) {
      print('Ошибка сохранения машинки: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Ошибка сохранения: $e';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка сохранения: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Добавить машинку'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            )
          else
            IconButton(icon: const Icon(Icons.save), onPressed: _saveCar),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Выбор фото
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.camera),
                        title: const Text('Сделать фото'),
                        onTap: () {
                          Navigator.pop(context);
                          _pickImage(ImageSource.camera);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.photo),
                        title: const Text('Выбрать из галереи'),
                        onTap: () {
                          Navigator.pop(context);
                          _pickImage(ImageSource.gallery);
                        },
                      ),
                    ],
                  ),
                );
              },
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey[400]!),
                ),
                child: _image == null
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo,
                              size: 50,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 10),
                            Text('Нажмите чтобы добавить фото'),
                          ],
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(_image!, fit: BoxFit.cover),
                      ),
              ),
            ),

            const SizedBox(height: 20),

            // Поле для названия модели
            TextField(
              controller: _modelNameController,
              decoration: const InputDecoration(
                labelText: 'Название модели *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.directions_car),
              ),
            ),

            const SizedBox(height: 20),

            // Поле для комментария
            TextField(
              controller: _commentController,
              decoration: const InputDecoration(
                labelText: 'Комментарий (необязательно)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 3,
            ),

            const SizedBox(height: 20),

            // Кнопка сохранения
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveCar,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Сохранить машинку'),
              ),
            ),

            // Отображение ошибок
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _modelNameController.dispose();
    _commentController.dispose();
    super.dispose();
  }
}
