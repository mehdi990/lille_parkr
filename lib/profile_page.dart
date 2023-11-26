import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'DataManager.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  DataManager dataManager = DataManager();
  List<dynamic> parkingData = [];
  List<Map<String, String>> favoriteDestinations = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    parkingData = await dataManager.fetchParkingData();
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      favoriteDestinations = prefs.getStringList('favorite_destinations')?.map((destinationData) {
        final destinationMap = jsonDecode(destinationData);
        return Map<String, String>.from(destinationMap);
      }).toList() ?? [];
    });
  }
  // Fonction pour supprimer un parking favori
  void removeFavoriteParking(Map<String, dynamic> parking) async {
    final prefs = await SharedPreferences.getInstance();
    // Récupérer la liste des parkings favoris depuis les préférences partagées
    List<String>? favoriteParkings = prefs.getStringList('favorite_parkings');

    if (favoriteParkings != null) {
      // Convertir chaque élément JSON en Map<String, dynamic>
      List<Map<String, dynamic>> favoriteParkingList = favoriteParkings
          .map((favoriteParking) => jsonDecode(favoriteParking))
          .cast<Map<String, dynamic>>()
          .toList();

      // Trouver l'index du parking à supprimer
      int indexToRemove =
      favoriteParkingList.indexWhere((p) => p['libelle'] == parking['libelle']);

      // Si trouvé, supprimer le parking de la liste
      if (indexToRemove != -1) {
        favoriteParkingList.removeAt(indexToRemove);

        // Mettre à jour les préférences partagées avec la nouvelle liste
        prefs.setStringList(
          'favorite_parkings',
          favoriteParkingList.map((p) => jsonEncode(p)).toList(),
        );

        // Recharger la liste des favoris pour mettre à jour l'interface
        loadFavorites();
      }
    }
  }

  // Méthode pour ouvrir la recherche d'adresse
  void _openSearch() {
    showSearch(context: context, delegate: _DataSearch());
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Page'),
      ),
      body: Column(
        children: [
          Text('Vos parkings favoris :'),
          ListView.builder(
            itemCount: parkingData.length,
            itemBuilder: (context, index) {
              final parking = parkingData[index];
              return FutureBuilder<bool>(
                future: dataManager.isParkingFavorite(parking),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Erreur de chargement des données');
                  }

                  final isFavorite = snapshot.data ?? false;

                  if (isFavorite) {
                    return ListTile(
                      title: Text(parking['libelle']),
                      subtitle: Text(parking['adresse']),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () async {
                          await dataManager.removeFavoriteParking(parking);
                          fetchData(); // Refresh data to update favorites status
                        },
                      ),
                    );
                  } else {
                    return Container(); // Empty container for non-favorite items
                  }
                },
              );
            },
          ),
          Text('Vos destinations préférées :'),
          ListView.builder(
            itemCount: favoriteDestinations.length,
            itemBuilder: (context, index) {
              final destination = favoriteDestinations[index];
              return ListTile(
                title: Text(destination['name'] ?? ''),
                subtitle: Text(destination['address'] ?? ''),
              );
            },
          ),
        ],
      ),
    );
  }
}