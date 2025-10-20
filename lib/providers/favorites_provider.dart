import 'package:flutter/material.dart';

class FavoritesProvider extends ChangeNotifier {
  final Set<int> _favIds = {};

  bool isFavorite(int productId) => _favIds.contains(productId);

  void toggleFavorite(int productId) {
    if (_favIds.contains(productId)) {
      _favIds.remove(productId);
    } else {
      _favIds.add(productId);
    }
    notifyListeners();
  }

  List<int> get allFavorites => _favIds.toList();
}
