import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: MyWidget());
  }
}

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  int counter = 0;

  void increment() {
    setState(() {
      counter++;
    });
  }

  void incrementByTen() {
    setState(() {
      counter += 10;
    });
  }

  void clear() {
    setState(() {
      counter = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Практика 4"), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Значение счётчика: $counter"),
            const SizedBox(height: 20),

            Container(
              color: Colors.green[100],
              padding: const EdgeInsets.all(10),
              child: GestureDetector(
                onTap: increment,
                onLongPress: incrementByTen,
                child: Container(
                  padding: const EdgeInsets.all(15),
                  color: Colors.green,
                  child: const Text(
                    "Увеличить",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Container(
              color: Colors.red[100],
              padding: const EdgeInsets.all(10),
              child: GestureDetector(
                onTap: clear,
                child: Container(
                  padding: const EdgeInsets.all(15),
                  color: Colors.red,
                  child: const Text(
                    "Сбросить",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
