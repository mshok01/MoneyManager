import 'package:flutter/material.dart';
import 'screens/intro_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MoneyManagerApp());
}

class MoneyManagerApp extends StatelessWidget {
  const MoneyManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Money Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const IntroScreen(),
      routes: {'/home': (context) => const HomeScreen()},
    );
  }
}
