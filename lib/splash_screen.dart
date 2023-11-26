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

    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/splash.png',
          width: 200, //  la largeur
          height: 200, //  la hauteur
        ),
      ),
    );
  }
}
