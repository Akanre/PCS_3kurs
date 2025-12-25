import 'package:flutter/material.dart';
import 'supabase_config.dart';
import 'models.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  UserProfile? _profile;
  int _carCount = 0;
  int _favoriteCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Обновляем данные при каждом показе страницы
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Проверяем, что таб активен
    final isCurrentTab = ModalRoute.of(context)?.isCurrent ?? false;
    if (isCurrentTab && !_isLoading) {
      print('🔄 Профиль: таб активен, обновляем данные');
      _loadData();
    }
  }

  Future<void> _loadData() async {
    try {
      final userId = SupabaseConfig.client.auth.currentUser?.id;
      final userEmail = SupabaseConfig.client.auth.currentUser?.email;

      if (userId == null) {
        print('❌ Профиль: пользователь не авторизован');
        return;
      }

      print('🔄 Профиль: загружаем данные для пользователя $userId');

      // 1. Загружаем профиль
      try {
        final profileResponse = await SupabaseConfig.client
            .from('profiles')
            .select()
            .eq('id', userId)
            .maybeSingle();

        if (profileResponse != null) {
          print('✅ Профиль: данные профиля загружены');
          _profile = UserProfile.fromJson(profileResponse);
        } else {
          print('⚠️ Профиль: профиль не найден, создаем временный');
          _profile = UserProfile(
            id: userId,
            email: userEmail ?? 'Не указан',
            username: userEmail?.split('@').first ?? 'Пользователь',
          );
        }
      } catch (e) {
        print('❌ Профиль: ошибка загрузки профиля: $e');
        _profile = UserProfile(
          id: userId,
          email: userEmail ?? 'Не указан',
          username: 'Пользователь',
        );
      }

      // 2. Считаем ВСЕ машинки
      try {
        final allCarsResponse = await SupabaseConfig.client
            .from('toy_cars')
            .select('id')
            .eq('user_id', userId);

        _carCount = allCarsResponse?.length ?? 0;
        print('📊 Профиль: всего машинок: $_carCount');
      } catch (e) {
        print('❌ Профиль: ошибка подсчета машинок: $e');
        _carCount = 0;
      }

      // 3. Считаем ИЗБРАННЫЕ машинки
      try {
        final favoriteCarsResponse = await SupabaseConfig.client
            .from('toy_cars')
            .select('id')
            .eq('user_id', userId)
            .eq('is_favorite', true);

        _favoriteCount = favoriteCarsResponse?.length ?? 0;
        print('⭐ Профиль: избранных машинок: $_favoriteCount');
      } catch (e) {
        print('❌ Профиль: ошибка подсчета избранного: $e');
        _favoriteCount = 0;
      }
    } catch (e) {
      print('❌ Профиль: общая ошибка загрузки: $e');

      final currentUser = SupabaseConfig.client.auth.currentUser;
      if (currentUser != null) {
        _profile = UserProfile(
          id: currentUser.id,
          email: currentUser.email ?? 'Не указан',
          username: currentUser.email?.split('@').first ?? 'Пользователь',
        );
      }

      _carCount = 0;
      _favoriteCount = 0;
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _logout() async {
    try {
      await SupabaseConfig.client.auth.signOut();
    } catch (e) {
      print('Ошибка выхода: $e');
    }
  }

  Future<void> _refreshData() async {
    print('🔄 Профиль: ручное обновление');
    setState(() => _isLoading = true);
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: _isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Загрузка профиля...'),
                  ],
                ),
              )
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ПРИВЕТСТВИЕ
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Здравствуйте,',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Text(
                                    _profile?.username ?? 'Пользователь',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ИНФОРМАЦИЯ О ПОЛЬЗОВАТЕЛЕ
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Информация о профиле',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // EMAIL
                              _buildInfoRow(
                                icon: Icons.email,
                                label: 'Email',
                                value: _profile?.email ?? 'Не указан',
                              ),

                              const SizedBox(height: 12),

                              // ИМЯ ПОЛЬЗОВАТЕЛЯ
                              _buildInfoRow(
                                icon: Icons.person,
                                label: 'Имя пользователя',
                                value: _profile?.username ?? 'Не указано',
                              ),

                              const SizedBox(height: 20),

                              // СТАТИСТИКА
                              const Text(
                                'Статистика коллекции',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  _buildStatCard(
                                    title: 'Всего машинок',
                                    count: _carCount,
                                    color: Colors.blue,
                                    icon: Icons.directions_car,
                                  ),
                                  _buildStatCard(
                                    title: 'В избранном',
                                    count: _favoriteCount,
                                    color: Colors.amber,
                                    icon: Icons.star,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // КНОПКА ОБНОВЛЕНИЯ
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _refreshData,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: Colors.blue[100],
                            foregroundColor: Colors.blue[800],
                          ),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Обновить статистику'),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // КНОПКА ВЫХОДА
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _logout,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          icon: const Icon(Icons.logout),
                          label: const Text('Выйти из аккаунта'),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  // ВИДЖЕТ ДЛЯ СТРОКИ ИНФОРМАЦИИ
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ВИДЖЕТ ДЛЯ СТАТИСТИКИ
  Widget _buildStatCard({
    required String title,
    required int count,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 24, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
