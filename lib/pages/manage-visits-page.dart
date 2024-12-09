import 'package:flutter/material.dart';

import 'add-visit.dart';

class ManageVisitsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Données fictives pour les visites
    final List<Map<String, String>> visits = [
      {
        'pointVente': 'Point de Vente 1',
        'date': '10/12/2024',
        'remarque': 'Bonne condition',
      },
      {
        'pointVente': 'Point de Vente 2',
        'date': '11/12/2024',
        'remarque': 'Stock faible',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("Gérer les Visites"),
        backgroundColor: Colors.blue.shade300,
      ),
      body: ListView.builder(
        itemCount: visits.length,
        itemBuilder: (context, index) {
          final visit = visits[index];
          return Card(
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              leading: Icon(Icons.assignment, color: Colors.blue.shade800),
              title: Text("Visite de ${visit['pointVente']}"),
              subtitle: Text(
                  "Date: ${visit['date']}\nRemarque: ${visit['remarque']}"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue.shade800),
                    onPressed: () {
                      // Logique pour modifier la visite
                      print("Modifier visite ${visit['pointVente']}");
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      // Logique pour supprimer la visite
                      print("Supprimer visite ${visit['pointVente']}");
                    },
                  ),
                ],
              ),
              onTap: () {
                // Logique pour afficher les détails
                print("Afficher détails visite ${visit['pointVente']}");
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AddVisitPage()), // Page pour ajouter une visite
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue.shade300,
      ),
    );
  }
}
