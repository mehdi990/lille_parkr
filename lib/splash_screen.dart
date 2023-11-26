import 'package:flutter/material.dart';
import 'map.dart';
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Ajoutez votre logique d'écran de démarrage ici
    // Par exemple, une temporisation simulée avec un Future.delayed
    Future.delayed(Duration(seconds: 6), () {
      // Naviguez vers l'écran de la carte après la temporisation
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MapScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Affichez votre logo ici
    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/splash.png', // Assurez-vous de remplacer 'votre_logo.png' par le chemin réel de votre image
          width: 200, // Ajustez la largeur selon vos besoins
          height: 200, // Ajustez la hauteur selon vos besoins
        ),
      ),
    );
  }
}
