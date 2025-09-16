import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: Text("Практика 3"), centerTitle: true),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Привет!",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 25),
              ElevatedButton(onPressed: () {}, child: Text("Нажми меня")),
              SizedBox(height: 30),
              Container(width: 250, height: 150, color: Colors.orange),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Icon(
                    Icons.book,
                    color: const Color.fromARGB(255, 159, 80, 52),
                  ),
                  Icon(Icons.link, color: Colors.blue),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
