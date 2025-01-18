import 'package:flutter/material.dart';
import '../../helpers/DataBaseHelper.dart';

class PlanificationTourneePage extends StatefulWidget {
  final int livreurId;

  PlanificationTourneePage({Key? key, required this.livreurId}) : super(key: key);

  @override
  _PlanificationTourneePageState createState() => _PlanificationTourneePageState();
}

class _PlanificationTourneePageState extends State<PlanificationTourneePage> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  final TextEditingController nomTourneeController = TextEditingController();
  DateTime? selectedDate;
  late Future<List<Map<String, dynamic>>> _salesPoints;
  final Map<int, int> selectedPoints = {}; // point_id -> ordre
  final Map<int, Map<int, int>> productQuantities = {}; // point_id -> {product_id: quantity}

  @override
  void initState() {
    super.initState();
    _fetchSalesPoints();
  }

  @override
  void dispose() {
    nomTourneeController.dispose();
    super.dispose();
  }

  void _fetchSalesPoints() {
    _salesPoints = dbHelper.getSalesPoints(widget.livreurId);
  }

  Future<void> _saveTournee() async {
    if (selectedDate == null || selectedPoints.isEmpty || nomTourneeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez remplir tous les champs requis.')),
      );
      return;
    }

    try {
      // Insertion de la tournée
      final tourneeId = await dbHelper.insertTournee(
        date: selectedDate!.toIso8601String(),
        nom: nomTourneeController.text,
        livreurId: widget.livreurId,
      );

      // Insertion des visites associées
      for (var entry in selectedPoints.entries) {
        final pointId = entry.key;
        final order = entry.value;

        final products = productQuantities[pointId] ?? {};
        if (products.isEmpty) {
          await dbHelper.insertVisit(
            tourneeId: tourneeId,
            pointId: pointId,
            productId: 0,
            quantity: 0,
            order: order,
          );
        } else {
          for (var productEntry in products.entries) {
            final productId = productEntry.key;
            final quantity = productEntry.value;

            await dbHelper.insertVisit(
              tourneeId: tourneeId,
              pointId: pointId,
              productId: productId,
              quantity: quantity,
              order: order,
            );
          }
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tournée planifiée avec succès.')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      print("Erreur : $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la planification de la tournée.')),
      );
    }
  }

  void _toggleSelection(int pointId, int? order) {
    setState(() {
      if (selectedPoints.containsKey(pointId)) {
        selectedPoints.remove(pointId);
        productQuantities.remove(pointId);
      } else {
        selectedPoints[pointId] = order ?? (selectedPoints.length + 1);
      }
    });
  }

  Future<void> _showProductSelection(int pointId) async {
    final products = await dbHelper.getProducts(widget.livreurId);
    if (products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Aucun produit disponible à associer.')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final Map<int, int> pointProducts = Map.from(productQuantities[pointId] ?? {});

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom, // Ajuste le padding pour le clavier
            top: 16.0,
            left: 16.0,
            right: 16.0,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Associer des produits au Point de Vente',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                SizedBox(height: 10),
                ...products.map((product) {
                  final productId = product['id'];
                  final quantity = pointProducts[productId] ?? 0;

                  return ListTile(
                    title: Text(product['nom']),
                    trailing: SizedBox(
                      width: 100,
                      child: TextFormField(
                        initialValue: quantity > 0 ? quantity.toString() : null,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Quantité',
                          hintText: '0',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          final parsedValue = int.tryParse(value) ?? 0;
                          setState(() {
                            if (parsedValue > 0) {
                              pointProducts[productId] = parsedValue;
                            } else {
                              pointProducts.remove(productId);
                            }
                          });
                        },
                      ),
                    ),
                  );
                }).toList(),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      productQuantities[pointId] = pointProducts;
                    });
                    Navigator.pop(context);
                  },
                  child: Text('Enregistrer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade300,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Planification de Tournée'),
        backgroundColor: Colors.blue.shade300,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nom de la Tournée',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: nomTourneeController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Entrez le nom de la tournée',
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Date de la Tournée',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(Duration(days: 365)),
                );
                if (date != null) {
                  setState(() {
                    selectedDate = date;
                  });
                }
              },
              child: Text(
                selectedDate == null
                    ? 'Sélectionner une date'
                    : 'Date : ${selectedDate!.toLocal().toString().split(' ')[0]}',
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Sélectionnez les Points de Vente',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _salesPoints,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Erreur de chargement des points.'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('Aucun point de vente trouvé.'));
                  }

                  final points = snapshot.data!;
                  return ListView.builder(
                    itemCount: points.length,
                    itemBuilder: (context, index) {
                      final point = points[index];
                      final pointId = point['id'];

                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          leading: Checkbox(
                            value: selectedPoints.containsKey(pointId),
                            onChanged: (value) {
                              _toggleSelection(
                                  pointId, value == true ? selectedPoints.length + 1 : null);
                            },
                          ),
                          title: Text(point['name']),
                          subtitle: Text(
                              'Ordre : ${selectedPoints[pointId] ?? '-'}'),
                          trailing: IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () {
                              if (selectedPoints.containsKey(pointId)) {
                                _showProductSelection(pointId);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Sélectionnez d\'abord le point de vente.')),
                                );
                              }
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveTournee,
        child: Icon(Icons.save),
        backgroundColor: Colors.blue.shade300,
      ),
    );
  }
}
