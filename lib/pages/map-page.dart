import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../helpers/DataBaseHelper.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  List<Marker> markers = [];
  final DatabaseHelper dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _loadSalesPoints();
  }

  Future<void> _loadSalesPoints() async {
    final points = await dbHelper.getSalesPoints();
    setState(() {
      markers = points.map((point) {
        final coords = point['gps_coordinates'].split(', ');
        final lat = double.parse(coords[0]);
        final lng = double.parse(coords[1]);

        return Marker(
          point: LatLng(lat, lng),
          child: Icon(
            Icons.location_on,
            color: Colors.red,
            size: 30,
          ),
        );
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Carte"),
        backgroundColor: Colors.blue.shade300,
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(33.547665816250685, -7.650248141871139),
          initialZoom: 13.0,
          onTap: (tapPosition, point) async {
            if (point != null) {
              String coordinates = "${point.latitude}, ${point.longitude}";
              final result = await Navigator.pushNamed(
                context,
                '/addPoint',
                arguments: coordinates,
              );
              if (result == true) {
                _loadSalesPoints(); // Recharge la carte si un point a été ajouté
              }
            }
          },
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: markers,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.pushNamed(
            context,
            '/addPoint',
            arguments: "33.547665816250685, -7.650248141871139",
          );
          if (result == true) {
            _loadSalesPoints(); // Recharge la carte si un point a été ajouté
          }
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue.shade300,
      ),
    );
  }
}
