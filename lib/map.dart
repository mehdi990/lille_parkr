import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'DataManager.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  DataManager dataManager = DataManager();
  List<dynamic> parkingData = [];
  bool isListView = false;
  GoogleMapController? _mapController;
  Map<String, dynamic>? recommendedParking;
  Set<Marker> markers = Set();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    parkingData = await dataManager.fetchParkingData();
    updateMarkers();
  }

  Future<void> updateMarkers() async {
    markers.clear();

    for (var parking in parkingData) {
      if (parking['geometry'] != null &&
          parking['geometry']['geometry']['coordinates'] != null) {
        double lat = parking['geometry']['geometry']['coordinates'][1];
        double lng = parking['geometry']['geometry']['coordinates'][0];

        Marker marker = Marker(
          markerId: MarkerId(parking['id']),
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(
            title: parking['libelle'],
            snippet:
            'Disponibilité : ${parking['dispo']} places sur ${parking['max']}',
          ),
        );

        markers.add(marker);
      }
    }

    setState(() {});
  }

  // Méthode pour ouvrir la recherche d'adresse
  void _openSearch() async {
    String? destinationAddress = await showSearch(
      context: context,
      delegate: _DataSearch(),
    );

    if (destinationAddress != null) {
      // L'utilisateur a choisi une adresse, recommandez un parking
      recommendedParking =
      await dataManager.recommendParking(destinationAddress);
      // Mettez à jour la carte avec le nouveau marqueur recommandé
      updateMarkers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF0000FF),
        title: Text('Trouver un parking'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.view_list),
            onPressed: () {
              setState(() {
                isListView = !isListView;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              _openSearch();
            },
          ),
        ],
      ),
      body: isListView ? _buildListView() : _buildMapView(),
    );
  }

  Widget _buildMapView() {
    return GoogleMap(
      onMapCreated: (GoogleMapController controller) {
        _mapController = controller;
      },
      initialCameraPosition: CameraPosition(
        target: LatLng(50.62925, 3.057256),
        zoom: 12,
      ),
      markers: _getMarkersWithRecommended(),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
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

            return ListTile(
              title: Text(parking['libelle']),
              subtitle: Text(parking['adresse']),
              trailing: IconButton(
                icon: isFavorite
                    ? Icon(Icons.favorite, color: Colors.red)
                    : Icon(Icons.favorite_border),
                onPressed: () async {
                  await dataManager.toggleFavoriteParking(parking);
                  fetchData(); // Refresh data to update favorites status
                },
              ),
            );
          },
        );
      },
    );
  }

  Set<Marker> _getMarkersWithRecommended() {
    Set<Marker> markersWithRecommended = Set.from(markers);

    if (recommendedParking != null) {
      double lat = recommendedParking!['geometry']['geometry']['coordinates'][1];
      double lng = recommendedParking!['geometry']['geometry']['coordinates'][0];

      Marker recommendedMarker = Marker(
        markerId: MarkerId(recommendedParking!['id']),
        position: LatLng(lat, lng),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(
          title: recommendedParking!['libelle'],
          snippet:
          'Disponibilité : ${recommendedParking!['dispo']} places sur ${recommendedParking!['max']}',
        ),
      );

      markersWithRecommended.add(recommendedMarker);
    }

    return markersWithRecommended;
  }
}

class _DataSearch extends SearchDelegate<String> {
  DataManager dataManager = DataManager();

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Appelle la recommandation de parking avec l'adresse sélectionnée
    dataManager.recommendParking(query).then((recommendedParking) {
      // Met à jour la carte avec le nouveau marqueur recommandé
      // Vous pourriez ne rien faire ici si la mise à jour est gérée dans _MapScreenState
    });

    // Affiche les résultats de la recommandation de parking
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Retourne une liste d'adresses en fonction de la requête de l'utilisateur
    return _getAddressSuggestions(query);
  }

  Widget _getAddressSuggestions(String query) {
    // Implémentez la logique pour obtenir des suggestions d'adresse en fonction de la requête de l'utilisateur
    // Vous pouvez utiliser des API de géocodage, comme Google Maps Geocoding API, pour obtenir des suggestions d'adresse
    // Pour simplifier, vous pouvez afficher une liste statique d'adresses ici.
    return ListView(
      children: <Widget>[
        ListTile(
          title: Text('123 Rue de la République, Lille'),
          onTap: () {
            // Fermez la recherche avec l'adresse sélectionnée
            close(context, '123 Rue de la République, Lille');
          },
        ),
        ListTile(
          title: Text('456 Avenue des Fleurs, Lille'),
          onTap: () {
            // Fermez la recherche avec l'adresse sélectionnée
            close(context, '456 Avenue des Fleurs, Lille');
          },
        ),
        // Ajoutez d'autres suggestions d'adresse au besoin
      ],
    );
  }

  Widget _buildSearchResults() {
    // Implémentez la logique pour afficher les résultats de la recommandation de parking
    return FutureBuilder<Map<String, dynamic>?>(
      future: dataManager.recommendParking(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Erreur de recherche'));
        }

        final recommendedParking = snapshot.data;

        if (recommendedParking != null) {
          return ListTile(
            title: Text(recommendedParking['libelle']),
            subtitle: Text(recommendedParking['adresse']),
            onTap: () {
              // Fermez la recherche avec l'adresse sélectionnée
              close(context, recommendedParking['libelle']);
            },
          );
        } else {
          return Center(child: Text('Aucun parking trouvé'));
        }
      },
    );
  }
}
