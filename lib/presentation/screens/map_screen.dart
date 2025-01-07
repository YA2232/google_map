import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController mapController = MapController();
  LocationData? curruntLocation;
  List<LatLng> routePoints = [];
  List<Marker> markers = [];
  final String orsApiKey =
      "5b3ce3597851110001cf6248f459635bedfd4702901424972f27ec1e";
  bool isSearched = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getCurruntLoscation();
  }

  // Future<List<String>> _getSuggestions(String query) async {
  //   final response = await http.get(Uri.parse(
  //       "https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json"));
  //   if (response.statusCode == 200) {
  //     final data = jsonDecode(response.body);
  //     print(data.toString());
  //     if (data.isNotEmpty) {
  //       return data.map<String>((item) => item['display_name']).toList();
  //     }
  //   }
  //   return [];
  // }

  // Future<void> _searchPlace(String query) async {
  //   final response = await http.get(Uri.parse(
  //       "https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json"));
  //   if (response.statusCode == 200) {
  //     final data = jsonDecode(response.body);
  //     if (data.isNotEmpty) {
  //       final lat = double.parse(data[0]['lat']);
  //       final lon = double.parse(data[0]['lon']);
  //       setState(() {
  //         markers = [
  //           Marker(
  //             width: 88,
  //             height: 88,
  //             point: LatLng(lat, lon),
  //             child: Icon(
  //               Icons.location_on,
  //               color: Colors.red,
  //               size: 40,
  //             ),
  //           ),
  //         ];
  //         mapController.move(LatLng(lat, lon), 15);
  //       });
  //     }
  //   }
  // }

  Future<void> _getCurruntLoscation() async {
    var location = Location();
    try {
      var userLocation = await location.getLocation();
      setState(() {
        curruntLocation = userLocation;
        markers.add(Marker(
            width: 88,
            height: 88,
            point: LatLng(userLocation.latitude!, userLocation.longitude!),
            child: Icon(Icons.my_location)));
      });
    } on Exception {
      curruntLocation = null;
    }
    location.onLocationChanged.listen((LocationData newLocation) {
      setState(() {
        curruntLocation = newLocation;
      });
    });
  }

  Future<void> _getRoute(LatLng destination) async {
    if (curruntLocation == null) return;
    final start =
        LatLng(curruntLocation!.latitude!, curruntLocation!.longitude!);
    final uri = "https://api.openrouteservice.org/v2/directions/foot-walking?"
        "api_key=$orsApiKey&start=${start.longitude},${start.latitude}&end=${destination.longitude},${destination.latitude}";
    final response = await http.get(Uri.parse(uri));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(data);
      final List<dynamic> coords =
          data['features'][0]['geometry']['coordinates'];
      setState(
        () {
          routePoints =
              coords.map((coord) => LatLng(coord[1], coord[0])).toList();
          markers.add(
            Marker(
              width: 88,
              height: 88,
              point: destination,
              child: Icon(
                Icons.location_on,
                color: Colors.red,
                size: 40,
              ),
            ),
          );
        },
      );
    } else {
      print("error");
    }
  }

  void _addDestenationMarker(LatLng point) {
    setState(() {
      markers.add(Marker(
        width: 88,
        height: 88,
        point: point,
        child: Icon(
          Icons.location_on,
          color: Colors.red,
          size: 40,
        ),
      ));
      _getRoute(point);
    });
  }

  // Widget buildSearchedField() {
  //   return TypeAheadField<String>(
  //       itemBuilder: (context, sugession) {
  //         return ListTile(
  //           title: Text(sugession),
  //         );
  //       },
  //       onSelected: _searchPlace,
  //       suggestionsCallback: _getSuggestions);
  // }

  Widget buildAppBarTitle() {
    return Text("Maps");
  }

  List<Widget> buildAppBarActions() {
    if (isSearched) {
      return [
        IconButton(
            onPressed: () {
              setState(() {
                isSearched = false;
              });
            },
            icon: Icon(Icons.clear))
      ];
    } else {
      return [
        IconButton(
            onPressed: () {
              setState(() {
                isSearched = true;
              });
            },
            icon: Icon(Icons.search))
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: isSearched ? buildSearchedField() : buildAppBarTitle(),
        actions: buildAppBarActions(),
      ),
      body: curruntLocation == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.only(top: 11),
              child: FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    initialCenter: LatLng(curruntLocation!.latitude!,
                        curruntLocation!.longitude!),
                    initialZoom: 15,
                    onTap: (tapPosition, point) => _addDestenationMarker(point),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    ),
                    MarkerLayer(markers: markers),
                    PolylineLayer(polylines: [
                      Polyline(
                          points: routePoints,
                          strokeWidth: 4,
                          color: Colors.blue)
                    ])
                  ]),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (curruntLocation != null) {
            mapController.move(
                LatLng(curruntLocation!.latitude!, curruntLocation!.longitude!),
                15);
          }
        },
        child: Icon(Icons.my_location),
      ),
    );
  }
}
