import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';
import '../models/product.dart';
import '../data/products.dart';
import '../widgets/product_card.dart';
import '../widgets/bottom_nav.dart';

class FavouritesScreen extends StatefulWidget {
  const FavouritesScreen({Key? key}) : super(key: key);

  @override
  State<FavouritesScreen> createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen> {
  int bottomIndex = 1;

  void _onBottomTap(int idx) {
    if (idx == 0) Navigator.pushReplacementNamed(context, '/shop');
    if (idx == 2) Navigator.pushReplacementNamed(context, '/cart');
  }

  @override
  Widget build(BuildContext context) {
    final favProv = context.watch<FavoritesProvider>();
    final favIds = favProv.allFavorites;

    final favProducts = products.where((p) => favIds.contains(p.id)).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Favourites',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: favProducts.isEmpty
          ? const Center(child: Text('No favourites yet'))
          : GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 0.65,
              ),
              itemCount: favProducts.length,
              itemBuilder: (_, i) => Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ProductCard(product: favProducts[i]),
              ),
            ),
      bottomNavigationBar:
          MyBottomNav(currentIndex: bottomIndex, onTap: _onBottomTap),
    );
  }
}
