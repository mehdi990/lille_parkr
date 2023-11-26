import 'package:flutter/material.dart';
import 'splash_screen.dart'; // Assurez-vous que vous importez correctement votre écran de démarrage
import 'map.dart'; // Assurez-vous que vous importez correctement votre écran de carte

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
      home: SplashScreen(), // Définissez votre écran de démarrage comme écran d'accueil initial
    );
  }
}
