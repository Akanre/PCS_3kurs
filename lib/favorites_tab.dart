import 'package:flutter/material.dart';
import 'supabase_config.dart';
import 'models.dart';
import 'edit_car_page.dart';

class FavoritesTab extends StatefulWidget {
  const FavoritesTab({super.key});

  @override
  State<FavoritesTab> createState() => _FavoritesTabState();
}

class _FavoritesTabState extends State<FavoritesTab> {
  List<ToyCar> _favoriteCars = [];
  bool _isLoading = true;
  final GlobalKey _refreshKey = GlobalKey(); // ← ДОБАВЬТЕ ЭТУ СТРОКУ

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  // Обновляем при каждом показе страницы
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final isCurrentTab = ModalRoute.of(context)?.isCurrent ?? false;
    if (isCurrentTab && !_isLoading) {
      print('🔄 Избранное: таб активен, обновляем данные');
      _loadFavorites();
    }
  }

  Future<void> _loadFavorites() async {
    try {
      final userId = SupabaseConfig.client.auth.currentUser?.id;
      if (userId == null) return;

      print('🔄 Избранное: загружаем избранное пользователя $userId');

      final response = await SupabaseConfig.client
          .from('toy_cars')
          .select()
          .eq('user_id', userId)
          .eq('is_favorite', true)
          .order('created_at', ascending: false);

      if (response != null) {
        print('⭐ Избранное: загружено ${response.length} машинок');
        setState(() {
          _favoriteCars = response
              .map((json) => ToyCar.fromJson(json))
              .toList();
        });
      } else {
        print('⚠️ Избранное: нет избранных машинок');
        setState(() {
          _favoriteCars = [];
        });
      }
    } catch (e) {
      print('❌ Избранное: ошибка загрузки: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _navigateToEditCar(ToyCar car) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditCarPage(car: car)),
    );

    if (result == true) {
      _loadFavorites();
    }
  }

  Future<void> _refreshFavorites() async {
    setState(() => _isLoading = true);
    await _loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _refreshKey, // ← ИСПОЛЬЗУЕМ ЗДЕСЬ
      appBar: AppBar(
        title: const Text('Избранное'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshFavorites,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _favoriteCars.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.star_border, size: 80, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'Нет избранных машинок',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              )
            : GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.8,
                ),
                itemCount: _favoriteCars.length,
                itemBuilder: (context, index) {
                  final car = _favoriteCars[index];
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
                                        child: Icon(Icons.image, size: 50),
                                      ),
                                    ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      car.comment!,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
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
    );
  }
}
