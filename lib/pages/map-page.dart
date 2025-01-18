import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_project/pages/tournee/PlanificationTourneePage.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../helpers/DataBaseHelper.dart';
import 'Product/ProductsPage.dart';
import 'SalePoints/SalesPointNotifier.dart';
import 'SalePoints/points_de_vente_page.dart';
import 'Auth/auth-page.dart';
import 'manage-visits-page.dart';

class MapPage extends StatefulWidget {
  final int livreurId; // Ajout du livreurId pour filtrer les points
  MapPage({Key? key, required this.livreurId}) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final DatabaseHelper dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _initializeSalesPoints(); // Initialiser les points dans le notifier
  }

  Future<void> _initializeSalesPoints() async {
    final points = await dbHelper.getSalesPoints(widget.livreurId);
    Provider.of<SalesPointNotifier>(context, listen: false)
        .updateSalesPoints(points);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Carte"),
        backgroundColor: Colors.blue.shade300,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue.shade300,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.location_on),
              title: Text('Points de Vente'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PointsDeVentePage(
                      livreurId: widget.livreurId,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.inventory),
              title: Text('Mes Produits'), // Nouvelle option
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductsPage(livreurId: widget.livreurId), // Naviguer vers la page des produits
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.calendar_today),
              title: Text('Planification de Tournée'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PlanificationTourneePage(
                      livreurId: widget.livreurId,
                    ),
                  ),
                );
              },
            ),

            ListTile(
              leading: Icon(Icons.assignment),
              title: Text('Gérer les Visites'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ManageVisitsPage(livreurId: widget.livreurId)),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Déconnexion'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AuthPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: Consumer<SalesPointNotifier>(
        builder: (context, notifier, _) {
          final markers = notifier.salesPoints.map((point) {
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

          return FlutterMap(
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
                    _initializeSalesPoints(); // Recharger les points
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
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Choisir votre point de vente sur la carte")),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue.shade300,
      ),
    );
  }
}
