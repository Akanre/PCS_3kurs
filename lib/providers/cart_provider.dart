import 'package:flutter/material.dart';
import '../models/product.dart';

class CartItem {
  final Product product;
  int quantity;
  CartItem({required this.product, this.quantity = 1});
}

class CartProvider extends ChangeNotifier {
  final Map<int, CartItem> _items = {};

  void addToCart(Product product) {
    if (_items.containsKey(product.id)) {
      _items[product.id]!.quantity += 1;
    } else {
      _items[product.id] = CartItem(product: product, quantity: 1);
    }
    notifyListeners();
  }

  void removeFromCart(int productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void changeQuantity(int productId, int delta) {
    if (!_items.containsKey(productId)) return;
    _items[productId]!.quantity += delta;
    if (_items[productId]!.quantity <= 0) {
      _items.remove(productId);
    }
    notifyListeners();
  }

  int get totalItems {
    int s = 0;
    _items.forEach((_, item) => s += item.quantity);
    return s;
  }

  double get totalPrice {
    double sum = 0;
    _items.forEach((_, item) {
      sum += item.product.price * item.quantity;
    });
    return sum;
  }

  List<CartItem> get items => _items.values.toList();

  bool contains(int productId) => _items.containsKey(productId);

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
