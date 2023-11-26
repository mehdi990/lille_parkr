import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geocoding/geocoding.dart';

class DataManager {
  List<dynamic> parkingData = [];
  Map<String, dynamic>? currentRecommendedParking;

  // Méthode pour récupérer les données des parkings depuis l'API
  Future<List<dynamic>> fetchParkingData() async {
    final response = await http.get(
      Uri.parse(
          'https://opendata.lillemetropole.fr/api/explore/v2.1/catalog/datasets/disponibilite-parkings/records?limit=20'),
    );

    if (response.statusCode == 200) {
      parkingData = jsonDecode(response.body)['results'];
      return parkingData;
    } else {
      print('Échec de la récupération des données');
      return [];
    }
  }

  // Méthode pour vérifier si un parking est déjà enregistré en tant que favori
  Future<bool> isParkingFavorite(Map<String, dynamic> parking) async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteParkings = prefs.getStringList('favorite_parkings') ?? [];

    final parkingDetails = {
      'name': parking['libelle'],
      'address': parking['adresse'],
    };

    final parkingDetailsJson = jsonEncode(parkingDetails);

    return favoriteParkings.contains(parkingDetailsJson);
  }

  // Méthode pour ajouter ou supprimer un parking de la liste des favoris
  Future<void> toggleFavoriteParking(Map<String, dynamic> parking) async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteParkings = prefs.getStringList('favorite_parkings') ?? [];

    final parkingDetails = {
      'name': parking['libelle'],
      'address': parking['adresse'],
    };

    final parkingDetailsJson = jsonEncode(parkingDetails);

    if (favoriteParkings.contains(parkingDetailsJson)) {
      favoriteParkings.remove(parkingDetailsJson);
    } else {
      favoriteParkings.add(parkingDetailsJson);
    }

    prefs.setStringList('favorite_parkings', favoriteParkings);
  }

  // Méthode pour recommander un parking en fonction de l'adresse de destination
  Future<Map<String, dynamic>?> recommendParking(String destinationAddress) async {
    try {
      List<Location> locations = await locationFromAddress(destinationAddress);

      if (locations.isNotEmpty) {
        double destLat = locations.first.latitude;
        double destLng = locations.first.longitude;

        Map<String, dynamic>? recommendedParking =
        _findNearestAvailableParking(destLat, destLng);

        currentRecommendedParking = recommendedParking;

        return recommendedParking;
      } else {
        return null;
      }
    } catch (e) {
      print('Erreur lors de la recherche d\'adresse : $e');
      return null;
    }
  }

  // Méthode pour trouver le parking disponible le plus proche de la destination
  Map<String, dynamic>? _findNearestAvailableParking(
      double destLat, double destLng) {
    if (parkingData.isNotEmpty) {
      List<Map<String, dynamic>> availableParkings = parkingData
          .where((parking) =>
      parking['etat'] == 'OUVERT' &&
          parking['dispo'] > 0 &&
          parking['dispo'] <= parking['max'] * 0.9)
          .toList()
          .cast<Map<String, dynamic>>();

      if (availableParkings.isNotEmpty) {
        availableParkings.sort((parking1, parking2) {
          double distance1 = _calculateDistance(
            destLat,
            destLng,
            parking1['geometry']['geometry']['coordinates'][1],
            parking1['geometry']['geometry']['coordinates'][0],
          );
          double distance2 = _calculateDistance(
            destLat,
            destLng,
            parking2['geometry']['geometry']['coordinates'][1],
            parking2['geometry']['geometry']['coordinates'][0],
          );
          return distance1.compareTo(distance2);
        });

        return availableParkings.first;
      }
    }
    return null;
  }

  // Méthode pour calculer la distance entre deux points géographiques
  double _calculateDistance(
      double lat1, double lng1, double lat2, double lng2) {
    double dx = lat1 - lat2;
    double dy = lng1 - lng2;
    return dx * dx + dy * dy;
  }
}
