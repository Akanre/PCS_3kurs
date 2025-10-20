import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text('Login',
                  style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Good to see you back! ♥'),
              const SizedBox(height: 24),
              TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                      hintText: 'Email',
                      filled: true,
                      fillColor: Color(0xFFF5F5F5),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                          borderSide: BorderSide.none))),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/password'),
                    child: const Text('LogIn')),
              ),
              const SizedBox(height: 8),
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel')),
            ],
          ),
        ),
      ),
    );
  }
}
