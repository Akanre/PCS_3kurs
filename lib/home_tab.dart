import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'supabase_config.dart';
import 'models.dart';
import 'add_car_page.dart';
import 'edit_car_page.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  HomeTabState createState() => HomeTabState();
}

class HomeTabState extends State<HomeTab> {
  List<ToyCar> _cars = [];
  List<ToyCar> _filteredCars = [];
  bool _isLoading = true;
  TextEditingController _searchController = TextEditingController();

  // ПУБЛИЧНЫЙ МЕТОД для поиска из MainPage
  void searchCars(String query) {
    print('🔍 Поиск из MainPage: "$query"');
    _searchController.text = query;
    _searchCars(query);
  }

  @override
  void initState() {
    super.initState();
    _loadCars();
  }

  Future<void> _loadCars() async {
    setState(() => _isLoading = true);

    try {
      final userId = SupabaseConfig.client.auth.currentUser?.id;
      if (userId == null) return;

      final response = await SupabaseConfig.client
          .from('toy_cars')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      if (response != null && response.isNotEmpty) {
        setState(() {
          _cars = response.map((json) => ToyCar.fromJson(json)).toList();
          _filteredCars = List.from(_cars);
        });
      }
    } catch (e) {
      print('Ошибка загрузки: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ПРИВАТНЫЙ метод для поиска
  void _searchCars(String query) {
    if (query.isEmpty) {
      setState(() => _filteredCars = List.from(_cars));
    } else {
      setState(() {
        _filteredCars = _cars
            .where(
              (car) =>
                  car.modelName.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      });
    }
  }

  Future<void> _toggleFavorite(int carId, bool currentStatus) async {
    try {
      await SupabaseConfig.client
          .from('toy_cars')
          .update({'is_favorite': !currentStatus})
          .eq('id', carId);

      setState(() {
        final index = _cars.indexWhere((car) => car.id == carId);
        if (index != -1) {
          _cars[index] = _cars[index].copyWith(isFavorite: !currentStatus);
          _filteredCars = List.from(_cars);
        }
      });
    } catch (e) {
      print('Ошибка обновления: $e');
    }
  }

  void _navigateToEditCar(ToyCar car) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditCarPage(car: car)),
    );

    if (result == true) {
      _loadCars();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            // ПОЛЕ ПОИСКА ВНУТРИ ТАБА (можно оставить или удалить)
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Поиск по названию модели...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _searchCars('');
                          },
                        )
                      : null,
                ),
                onChanged: _searchCars,
              ),
            ),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredCars.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.directions_car,
                            size: 80,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchController.text.isEmpty
                                ? 'Нет машинок в коллекции'
                                : 'Ничего не найдено по "$_searchController.text"',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                          if (_searchController.text.isNotEmpty)
                            TextButton(
                              onPressed: () {
                                _searchController.clear();
                                _searchCars('');
                              },
                              child: const Text('Очистить поиск'),
                            ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.8,
                          ),
                      itemCount: _filteredCars.length,
                      itemBuilder: (context, index) {
                        final car = _filteredCars[index];
                        return GestureDetector(
                          onTap: () => _navigateToEditCar(car),
                          child: Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(12),
                                    ),
                                    child: car.imageUrl.isNotEmpty
                                        ? Image.network(
                                            car.imageUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                                  return Container(
                                                    color: Colors.grey[200],
                                                    child: const Center(
                                                      child: Icon(
                                                        Icons.error,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  );
                                                },
                                          )
                                        : Container(
                                            color: Colors.grey[200],
                                            child: const Center(
                                              child: Icon(
                                                Icons.directions_car,
                                                size: 50,
                                              ),
                                            ),
                                          ),
                                  ),
                                ),

                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        car.modelName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (car.comment != null &&
                                          car.comment!.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 4,
                                          ),
                                          child: Text(
                                            car.comment!,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),

                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: IconButton(
                                          icon: Icon(
                                            car.isFavorite
                                                ? Icons.star
                                                : Icons.star_border,
                                            color: car.isFavorite
                                                ? Colors.amber
                                                : Colors.grey,
                                          ),
                                          onPressed: () => _toggleFavorite(
                                            car.id,
                                            car.isFavorite,
                                          ),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),

        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddCarPage()),
              );
              if (result == true) {
                _loadCars();
              }
            },
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
