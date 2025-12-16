import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'supabase_config.dart';
import 'models.dart';

class EditCarPage extends StatefulWidget {
  final ToyCar car;

  const EditCarPage({super.key, required this.car});

  @override
  State<EditCarPage> createState() => _EditCarPageState();
}

class _EditCarPageState extends State<EditCarPage> {
  File? _image;
  final _modelNameController = TextEditingController();
  final _commentController = TextEditingController();
  final _picker = ImagePicker();
  bool _isLoading = false;
  bool _isDeleting = false;
  String? _errorMessage;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _modelNameController.text = widget.car.modelName;
    _commentController.text = widget.car.comment ?? '';
    _isFavorite = widget.car.isFavorite;
  }

  Future<File?> _compressImage(File originalImage) async {
    try {
      final bytes = await originalImage.readAsBytes();
      final decodedImage = img.decodeImage(bytes);
      if (decodedImage == null) return originalImage;

      final compressedImage = img.copyResize(
        decodedImage,
        width: 1200,
        maintainAspect: true,
      );

      final compressedBytes = img.encodeJpg(compressedImage, quality: 85);

      final tempDir = await getTemporaryDirectory();
      final compressedFile = File(
        '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      await compressedFile.writeAsBytes(compressedBytes);
      return compressedFile;
    } catch (e) {
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
    if (_image == null) return null;

    try {
      final compressedFile = await _compressImage(_image!);

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${widget.car.userId}/car_$timestamp.jpg';

      await SupabaseConfig.client.storage
          .from('car-images')
          .upload(fileName, compressedFile!);

      final imageUrl = SupabaseConfig.client.storage
          .from('car-images')
          .getPublicUrl(fileName);

      return imageUrl;
    } catch (e) {
      print('Ошибка загрузки фото: $e');
      return null;
    }
  }

  Future<void> _updateCar() async {
    if (_modelNameController.text.isEmpty) {
      setState(() => _errorMessage = 'Введите название модели');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      String? imageUrl = widget.car.imageUrl;

      // Если выбрано новое фото - загружаем его
      if (_image != null) {
        final newImageUrl = await _uploadImage();
        if (newImageUrl != null) {
          imageUrl = newImageUrl;
        }
      }

      // Обновляем данные в БД
      await SupabaseConfig.client
          .from('toy_cars')
          .update({
            'model_name': _modelNameController.text.trim(),
            'comment': _commentController.text.trim().isEmpty
                ? null
                : _commentController.text.trim(),
            'image_url': imageUrl,
            'is_favorite': _isFavorite,
          })
          .eq('id', widget.car.id);

      print('Машинка обновлена!');

      // Возвращаемся с успехом
      Navigator.pop(context, true);
    } catch (e) {
      print('Ошибка обновления: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Ошибка обновления: $e';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка обновления: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteCar() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить машинку?'),
        content: const Text('Это действие нельзя отменить.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isDeleting = true);

    try {
      // Удаляем из БД
      await SupabaseConfig.client
          .from('toy_cars')
          .delete()
          .eq('id', widget.car.id);

      print('Машинка удалена!');

      // Возвращаемся с успехом (для обновления списка)
      Navigator.pop(context, true);
    } catch (e) {
      print('Ошибка удаления: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка удаления: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isDeleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Редактировать машинку'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            )
          else
            IconButton(icon: const Icon(Icons.save), onPressed: _updateCar),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ФОТО
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.camera),
                        title: const Text('Сделать новое фото'),
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
                      if (_image != null)
                        ListTile(
                          leading: const Icon(Icons.delete, color: Colors.red),
                          title: const Text(
                            'Удалить новое фото',
                            style: TextStyle(color: Colors.red),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            setState(() => _image = null);
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
                child: _image != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(_image!, fit: BoxFit.cover),
                      )
                    : widget.car.imageUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          widget.car.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.broken_image, size: 50),
                                  SizedBox(height: 10),
                                  Text('Ошибка загрузки фото'),
                                ],
                              ),
                            );
                          },
                        ),
                      )
                    : const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo,
                              size: 50,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 10),
                            Text('Нажмите чтобы изменить фото'),
                          ],
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 20),

            // НАЗВАНИЕ МОДЕЛИ
            TextField(
              controller: _modelNameController,
              decoration: const InputDecoration(
                labelText: 'Название модели *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.directions_car),
              ),
            ),

            const SizedBox(height: 20),

            // КОММЕНТАРИЙ
            TextField(
              controller: _commentController,
              decoration: const InputDecoration(
                labelText: 'Комментарий',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 3,
            ),

            const SizedBox(height: 20),

            // ИЗБРАННОЕ
            SwitchListTile(
              title: const Text('В избранном'),
              value: _isFavorite,
              onChanged: (value) => setState(() => _isFavorite = value),
              secondary: const Icon(Icons.star),
            ),

            const SizedBox(height: 30),

            // КНОПКА СОХРАНЕНИЯ
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updateCar,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Сохранить изменения'),
              ),
            ),

            const SizedBox(height: 20),

            // КНОПКА УДАЛЕНИЯ
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isDeleting ? null : _deleteCar,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: _isDeleting
                    ? const CircularProgressIndicator()
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.delete, size: 20),
                          SizedBox(width: 8),
                          Text('Удалить машинку'),
                        ],
                      ),
              ),
            ),

            // ОШИБКИ
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
