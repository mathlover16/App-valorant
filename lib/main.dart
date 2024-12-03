import 'package:app_random/dashboard.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Valorant App',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.green,
        useMaterial3: true,
      ),
      home: Dashboard(),
      debugShowCheckedModeBanner: false,
    );
  }
}