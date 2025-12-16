import 'package:flutter/material.dart';
import 'supabase_config.dart';
import 'models.dart';

class FavoritesTab extends StatefulWidget {
  const FavoritesTab({super.key});

  @override
  State<FavoritesTab> createState() => _FavoritesTabState();
}

class _FavoritesTabState extends State<FavoritesTab> {
  List<ToyCar> _favoriteCars = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);

    try {
      final userId = SupabaseConfig.client.auth.currentUser?.id;
      if (userId == null) return;

      final response = await SupabaseConfig.client
          .from('toy_cars')
          .select()
          .eq('user_id', userId)
          .eq('is_favorite', true);

      if (response != null && response.isNotEmpty) {
        setState(() {
          _favoriteCars = response
              .map((json) => ToyCar.fromJson(json))
              .toList();
        });
      }
    } catch (e) {
      print('Ошибка загрузки: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _favoriteCars.isEmpty
        ? const Center(child: Text('Нет избранных машинок'))
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
              return Card(
                child: Column(
                  children: [
                    Expanded(
                      child: car.imageUrl.isNotEmpty
                          ? Image.network(
                              car.imageUrl,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              color: Colors.grey[300],
                              child: const Icon(Icons.image, size: 50),
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
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
                          if (car.comment != null && car.comment!.isNotEmpty)
                            Text(
                              car.comment!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
  }
}
