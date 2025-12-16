import 'package:flutter/material.dart';
import 'home_tab.dart';
import 'favorites_tab.dart';
import 'profile_tab.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  bool _showSearchField = false; // Показывать ли поле поиска
  TextEditingController _searchController = TextEditingController();

  // Глобальный ключ для поиска
  final GlobalKey<HomeTabState> _homeTabKey = GlobalKey<HomeTabState>();

  List<Widget> get _tabs => [
    HomeTab(key: _homeTabKey),
    const FavoritesTab(),
    const ProfileTab(),
  ];

  final List<String> _titles = ['Моя коллекция', 'Избранное', 'Профиль'];

  // МЕТОД ДЛЯ ПОИСКА
  void _performSearch(String query) {
    print('🔍 Поиск: "$query"');

    // Передаем запрос в HomeTab
    if (_homeTabKey.currentState != null) {
      _homeTabKey.currentState!.searchCars(query);
    } else {
      print('⚠️ Ключ HomeTab не доступен');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _showSearchField && _selectedIndex == 0
            ? _buildSearchField() // Поле поиска
            : Text(_titles[_selectedIndex]), // Обычный заголовок
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
        ),
        actions: _buildAppBarActions(),
      ),
      body: IndexedStack(index: _selectedIndex, children: _tabs),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // ПОЛЕ ПОИСКА В AppBar
  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      autofocus: true,
      style: const TextStyle(color: Colors.white),
      cursorColor: Colors.white,
      decoration: InputDecoration(
        hintText: 'Поиск по названию...',
        hintStyle: const TextStyle(color: Colors.white70),
        border: InputBorder.none,
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear, color: Colors.white),
          onPressed: () {
            _searchController.clear();
            _performSearch('');
          },
        ),
      ),
      onChanged: _performSearch,
    );
  }

  // КНОПКИ В AppBar
  List<Widget>? _buildAppBarActions() {
    if (_selectedIndex != 0) return null; // Только на главной

    if (_showSearchField) {
      // Когда поиск открыт - только кнопка закрытия
      return [
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            setState(() {
              _showSearchField = false;
              _searchController.clear();
              _performSearch(''); // Сбрасываем поиск
            });
          },
        ),
      ];
    }
  }

  // НИЖНЯЯ НАВИГАЦИЯ
  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            // При переключении вкладки скрываем поиск
            if (_showSearchField) {
              setState(() {
                _showSearchField = false;
                _searchController.clear();
                _performSearch('');
              });
            }
            setState(() => _selectedIndex = index);
          },
          backgroundColor: Colors.white,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Colors.grey[600],
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Главная',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border),
              activeIcon: Icon(Icons.favorite),
              label: 'Избранное',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Профиль',
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
