import 'package:flutter/material.dart';
import 'supabase_config.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _usernameController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  // 🔧 ИСПРАВЛЕННЫЙ метод регистрации
  Future<void> _register() async {
    // Валидация
    if (_emailController.text.isEmpty) {
      setState(() => _errorMessage = 'Введите email');
      return;
    }

    if (_usernameController.text.isEmpty) {
      setState(() => _errorMessage = 'Введите имя пользователя');
      return;
    }

    if (_passwordController.text.isEmpty) {
      setState(() => _errorMessage = 'Введите пароль');
      return;
    }

    if (_passwordController.text.length < 6) {
      setState(() => _errorMessage = 'Пароль должен быть не менее 6 символов');
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _errorMessage = 'Пароли не совпадают');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('=== НАЧИНАЕМ РЕГИСТРАЦИЮ ===');

      // 1. РЕГИСТРАЦИЯ в Supabase Auth
      final authResponse = await SupabaseConfig.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      print('Auth результат:');
      print('- User ID: ${authResponse.user?.id}');
      print('- Email: ${authResponse.user?.email}');
      print('- Session: ${authResponse.session}');

      if (authResponse.user == null) {
        throw Exception('Не удалось создать пользователя');
      }

      // 2. СОЗДАНИЕ ПРОФИЛЯ в таблице profiles
      print('\nСоздаём профиль в таблице profiles...');

      final profileData = {
        'id': authResponse.user!.id,
        'email': _emailController.text.trim(),
        'username': _usernameController.text.trim(),
      };

      print('Данные профиля: $profileData');

      // Используем upsert вместо insert
      final profileResponse = await SupabaseConfig.client
          .from('profiles')
          .upsert(profileData);

      print('Профиль создан: $profileResponse');

      // 3. ПРОВЕРКА: читаем созданный профиль
      final checkProfile = await SupabaseConfig.client
          .from('profiles')
          .select()
          .eq('id', authResponse.user!.id)
          .single()
          .timeout(const Duration(seconds: 5));

      print('Проверка профиля: $checkProfile');

      // 4. УСПЕШНАЯ РЕГИСТРАЦИЯ
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Регистрация успешна!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

      // Возвращаемся на страницу входа
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      print('\n❌ ОШИБКА РЕГИСТРАЦИИ:');
      print('Тип: ${e.runtimeType}');
      print('Сообщение: ${e.toString()}');

      String errorMessage = 'Ошибка регистрации';

      if (e.toString().contains('duplicate key')) {
        errorMessage = 'Пользователь с таким email уже существует';
      } else if (e.toString().contains('profiles_pkey')) {
        errorMessage = 'Профиль уже существует для этого пользователя';
      } else if (e.toString().contains('violates row-level security')) {
        errorMessage = 'Ошибка прав доступа к таблице profiles';
      } else if (e.toString().contains('Network is unreachable')) {
        errorMessage = 'Проблема с интернет-соединением';
      }

      setState(() => _errorMessage = '$errorMessage\n${e.toString()}');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ $errorMessage'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Регистрация')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 20),

            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Имя пользователя *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Пароль * (минимум 6 символов)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),

            const SizedBox(height: 20),

            TextField(
              controller: _confirmPasswordController,
              decoration: const InputDecoration(
                labelText: 'Подтвердите пароль *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock_outline),
              ),
              obscureText: true,
            ),

            const SizedBox(height: 30),

            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _register,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue[700],
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Зарегистрироваться',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),

            const SizedBox(height: 20),

            TextButton(
              onPressed: _isLoading ? null : () => Navigator.pop(context),
              child: const Text('Уже есть аккаунт? Войти'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }
}
