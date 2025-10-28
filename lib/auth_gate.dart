import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'notes_page.dart';

final supabase = Supabase.instance.client;

class AuthGate extends StatefulWidget {
  @override
  _AuthGateState createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _signIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Please fill all fields');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('Attempting sign in with: $email');

      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      print('✅ Sign in successful! User: ${response.user?.email}');
    } on AuthException catch (e) {
      print('Auth error: ${e.message}');
      setState(() => _errorMessage = 'Error: ${e.message}');
    } catch (e) {
      print('Unexpected error: $e');
      setState(() => _errorMessage = 'Unexpected error occurred');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Please fill all fields');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('Attempting sign up with: $email');

      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        // ✅ Добавляем данные для обхода подтверждения email
        data: {'email_confirmed_at': DateTime.now().toIso8601String()},
      );

      print('Sign up response: ${response.user}');
      print('Session: ${response.session}');

      if (response.user != null) {
        print('✅ User created successfully!');
        // После регистрации автоматически входим
        await _signIn();
      }
    } on AuthException catch (e) {
      print('Auth error: ${e.message}');
      setState(() => _errorMessage = 'Registration error: ${e.message}');
    } catch (e) {
      print('Unexpected error: $e');
      setState(() => _errorMessage = 'Unexpected error occurred');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.session != null) {
          return NotesPage();
        }

        return Scaffold(
          appBar: AppBar(title: Text('Auth')),
          body: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password (min 6 characters)',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 20),

                if (_errorMessage != null)
                  Text(_errorMessage!, style: TextStyle(color: Colors.red)),

                SizedBox(height: 20),

                if (_isLoading)
                  CircularProgressIndicator()
                else
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _signIn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          child: Text(
                            'Sign In',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _signUp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                          child: Text(
                            'Sign Up',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
