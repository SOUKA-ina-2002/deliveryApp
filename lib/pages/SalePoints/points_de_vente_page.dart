import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../helpers/DataBaseHelper.dart';
import '../map-page.dart';
import 'EditPointPage.dart';
import 'SalesPointNotifier.dart';

class PointsDeVentePage extends StatefulWidget {
  final int livreurId; // Ajout du livreurId pour filtrer les points

  PointsDeVentePage({Key? key, required this.livreurId}) : super(key: key);

  @override
  _PointsDeVentePageState createState() => _PointsDeVentePageState();
}

class _PointsDeVentePageState extends State<PointsDeVentePage> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  late Future<List<Map<String, dynamic>>> _salesPoints;

  @override
  void initState() {
    super.initState();
    _fetchSalesPoints();
  }

  void _fetchSalesPoints() {
    _salesPoints = dbHelper.getSalesPoints(widget.livreurId); // Filtrage par livreurId
  }

  Future<void> _refreshSalesPoints() async {
    setState(() {
      _fetchSalesPoints(); // Recharge les données de la base
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Vos Points de Vente"),
        backgroundColor: Colors.blue.shade300,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _salesPoints,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text("Erreur de chargement des points de vente"),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text("Aucun point de vente trouvé"),
            );
          }

          final points = snapshot.data!;
          return ListView.builder(
            itemCount: points.length,
            itemBuilder: (context, index) {
              final point = points[index];
              return Card(
                margin: EdgeInsets.all(8.0),
                child: ExpansionTile(
                  leading: Icon(Icons.store, color: Colors.blue.shade800),
                  title: Text(point['name'] ?? "Nom indisponible"),
                  subtitle: Text(point['address'] ?? "Adresse indisponible"),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Contact : ${point['contact_name'] ?? 'Non disponible'}"),
                          Text("Téléphone : ${point['contact_phone'] ?? 'Non disponible'}"),
                          Text(
                              "Capacité de Stockage : ${point['storage_capacity'] ?? 'Non disponible'}"),
                          Text("Coordonnées GPS : ${point['gps_coordinates'] ?? 'Non disponible'}"),
                        ],
                      ),
                    ),
                  ],
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue.shade800),
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditPointPage(
                                point: point,
                                livreurId: widget.livreurId,
                              ),
                            ),
                          );
                          if (result == true) {
                            final updatedPoints =
                            await dbHelper.getSalesPoints(widget.livreurId);
                            Provider.of<SalesPointNotifier>(context, listen: false)
                                .updateSalesPoints(updatedPoints);
                            _refreshSalesPoints();
                          }
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await dbHelper.deleteSalesPoint(
                              point['id'], widget.livreurId);
                          final updatedPoints =
                          await dbHelper.getSalesPoints(widget.livreurId);

                          Provider.of<SalesPointNotifier>(context, listen: false)
                              .updateSalesPoints(updatedPoints);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Point de Vente supprimé")),
                          );
                          _refreshSalesPoints();
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MapPage(
                livreurId: widget.livreurId,
              ),
            ),
          );
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
