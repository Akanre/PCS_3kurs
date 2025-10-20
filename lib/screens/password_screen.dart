import 'package:flutter/material.dart';

class PasswordScreen extends StatelessWidget {
  const PasswordScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Password')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              TextField(
                  obscureText: true,
                  controller: passwordController,
                  decoration:
                      const InputDecoration(hintText: 'Enter password')),
              const SizedBox(height: 16),
              ElevatedButton(
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, '/shop'),
                  child: const Text('Submit')),
            ],
          ),
        ),
      ),
    );
  }
}
