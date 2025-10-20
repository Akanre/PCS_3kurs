import 'package:flutter/material.dart';

class MyBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const MyBottomNav({Key? key, required this.currentIndex, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color activeColor = Colors.blue;
    Color inactive = Colors.grey.shade400;

    return BottomNavigationBar(
      backgroundColor: Colors.white,
      currentIndex: currentIndex,
      onTap: onTap,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.store,
              color: currentIndex == 0 ? activeColor : inactive),
          label: 'Shop',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite,
              color: currentIndex == 1 ? Colors.red : inactive),
          label: 'Favourites',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart,
              color: currentIndex == 2 ? Colors.green : inactive),
          label: 'Cart',
        ),
      ],
      selectedItemColor: activeColor,
      unselectedItemColor: inactive,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
    );
  }
}
