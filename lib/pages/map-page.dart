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
import 'tournee/manage-visits-page.dart';

class MapPage extends StatefulWidget {
  final int livreurId;
  MapPage({Key? key, required this.livreurId}) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final DatabaseHelper dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _initializeSalesPoints();
  }

  Future<void> _initializeSalesPoints() async {
    final points = await dbHelper.getSalesPoints(widget.livreurId);
    Provider.of<SalesPointNotifier>(context, listen: false).updateSalesPoints(points);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Carte des Points de Vente"),
        backgroundColor: Colors.blue.shade500,
        elevation: 0,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue.shade500,
              ),
              child: Text(
                'Menu Principal',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            _buildDrawerItem(Icons.location_on, 'Points de Vente', () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PointsDeVentePage(livreurId: widget.livreurId),
                ),
              );
            }),
            _buildDrawerItem(Icons.inventory, 'Mes Produits', () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductsPage(livreurId: widget.livreurId),
                ),
              );
            }),
            _buildDrawerItem(Icons.calendar_today, 'Planification de Tournée', () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PlanificationTourneePage(livreurId: widget.livreurId),
                ),
              );
            }),
            _buildDrawerItem(Icons.assignment, 'Gérer les Visites', () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ManageVisitsPage(livreurId: widget.livreurId),
                ),
              );
            }),
            _buildDrawerItem(Icons.exit_to_app, 'Déconnexion', () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => AuthPage()),
              );
            }),
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
                    _initializeSalesPoints();
                  }
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c'],
              ),
              MarkerLayer(markers: markers),
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
        backgroundColor: Colors.blue.shade500,
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, Function() onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue.shade500),
      title: Text(title, style: TextStyle(color: Colors.blue.shade500)),
      onTap: onTap,
    );
  }
}
