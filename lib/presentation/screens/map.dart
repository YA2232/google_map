import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapState();
}

class _MapState extends State<MapPage> {
  final MapController mapController = MapController();
  LocationData? curuuntLocation;
  List<Marker> marker = [];
  List<LatLng> routPoints = [];
  final orgApiKey = "5b3ce3597851110001cf6248f459635bedfd4702901424972f27ec1e";

  Future<void> gitCurruntLocation() async {
    var location = Location();
    try {
      var userLocation = await location.getLocation();
      setState(() {
        curuuntLocation = userLocation;
        marker.add(Marker(
            point: LatLng(userLocation.latitude!, userLocation.latitude!),
            child: Icon(
              Icons.location_on,
              color: Colors.red,
            )));
      });
    } on Exception {
      curuuntLocation = null;
    }
    location.onLocationChanged.listen((LocationData newLocation) {
      setState(() {
        curuuntLocation = newLocation;
      });
    });
  }

  Future<void> getRout(LatLng destination) async {
    if (curuuntLocation == null) return;
    final start =
        LatLng(curuuntLocation!.latitude!, curuuntLocation!.longitude!);
    final url = Uri.parse(
        "https://api.openrouteservice.org/v2/directions/foot-walking?"
        "api_key=$orgApiKey&start=${start.longitude},${start.latitude}&end=${destination.longitude},${destination.latitude}");
    var response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List coords = data['features'][0]['geometry']['coordinates'];
      routPoints = coords.map((coord) => LatLng(coord[1], coord[0])).toList();
      marker.add(
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
    }
  }

  void _addDestenationMarker(LatLng point) {
    setState(() {
      marker.add(Marker(
        width: 88,
        height: 88,
        point: point,
        child: Icon(
          Icons.location_on,
          color: Colors.red,
          size: 40,
        ),
      ));
      getRout(point);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterMap(
        mapController: mapController,
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
          ),
          PolylineLayer(polylines: [
            Polyline(points: routPoints, strokeWidth: 3, color: Colors.blue)
          ])
        ],
      ),
      floatingActionButton: FloatingActionButton(onPressed: () {
        if (curuuntLocation == null) {
          mapController.move(
              LatLng(curuuntLocation!.latitude!, curuuntLocation!.longitude!),
              15);
        }
      }),
    );
  }
}
