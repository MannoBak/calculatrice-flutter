import 'package:flutter/material.dart';
import 'pages/calc_page.dart';

void main() {
  runApp(const MyApp());
}

// La classe principale de l'application Flutter
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calculatrice',
      theme: ThemeData.dark(useMaterial3: true),
      home: const CalculatorPage(),
    );
  }
}
