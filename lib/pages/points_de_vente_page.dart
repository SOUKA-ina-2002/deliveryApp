import 'package:flutter/material.dart';

import 'add_point_page.dart';

class PointsDeVentePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Vos Points de Vente"),
        backgroundColor: Colors.blue.shade300,
      ),
      body: ListView.builder(
        itemCount: 5, // Nombre de points de vente (temporaire)
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              leading: Icon(Icons.store, color: Colors.blue.shade800),
              title: Text("Point de Vente ${index + 1}"),
              subtitle: Text("Adresse ${index + 1}"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue.shade800),
                    onPressed: () {
                      // Logique pour modifier le point de vente
                      print("Modifier Point de Vente ${index + 1}");
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      // Logique pour supprimer le point de vente
                      print("Supprimer Point de Vente ${index + 1}");
                    },
                  ),
                ],
              ),
              onTap: () {
                // Logique pour afficher les détails du point de vente
                print("Afficher détails Point de Vente ${index + 1}");
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
         /* Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddPointPage()),
          );*/
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue.shade300,
      ),
    );
  }
}
