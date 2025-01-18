import 'package:flutter/material.dart';
import '../helpers/DataBaseHelper.dart';

class ManageVisitsPage extends StatefulWidget {
  final int livreurId;

  ManageVisitsPage({Key? key, required this.livreurId}) : super(key: key);

  @override
  _ManageVisitsPageState createState() => _ManageVisitsPageState();
}

class _ManageVisitsPageState extends State<ManageVisitsPage> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  late Future<List<Map<String, dynamic>>> _tours;

  @override
  void initState() {
    super.initState();
    _fetchTours();
  }

  void _fetchTours() {
    _tours = dbHelper.getTourneesByLivreur(widget.livreurId);
  }

  Future<void> _deleteTour(int tourneeId) async {
    await dbHelper.deleteTournee(tourneeId);
    setState(() {
      _fetchTours(); // Recharger les données après suppression
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Tournée supprimée avec succès")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gérer les Tournées"),
        backgroundColor: Colors.blue.shade300,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _tours,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Erreur de chargement des tournées"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("Aucune tournée trouvée"));
          }

          final tours = snapshot.data!;
          return ListView.builder(
            itemCount: tours.length,
            itemBuilder: (context, index) {
              final tour = tours[index];
              return Card(
                margin: EdgeInsets.all(8.0),
                child: ListTile(
                  leading: Icon(Icons.assignment, color: Colors.blue.shade800),
                  title: Text("Tournée du ${tour['date']}"),
                  subtitle: Text("ID: ${tour['id']}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteTour(tour['id']),
                      ),
                    ],
                  ),
                  onTap: () {
                    // Afficher les détails de la tournée
                    print("Afficher détails tournée ${tour['id']}");
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Naviguer vers une page pour ajouter une tournée
          /*Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddVisitPage(livreurId: widget.livreurId),
            ),
          );*/
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue.shade300,
      ),
    );
  }
}
