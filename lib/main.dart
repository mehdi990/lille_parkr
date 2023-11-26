import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'map.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Votre application',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(), //  écran de démarrage comme écran d'accueil initial
    );
  }
}
