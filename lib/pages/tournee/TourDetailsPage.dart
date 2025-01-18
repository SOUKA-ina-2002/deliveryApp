import 'package:flutter/material.dart';
import '../../helpers/DataBaseHelper.dart';

class TourDetailsPage extends StatefulWidget {
  final int tourneeId;
  final String tourName;
  final int livreurId;

  TourDetailsPage({
    Key? key,
    required this.tourneeId,
    required this.tourName,
    required this.livreurId,
  }) : super(key: key);

  @override
  _TourDetailsPageState createState() => _TourDetailsPageState();
}

class _TourDetailsPageState extends State<TourDetailsPage> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  late Future<List<Map<String, dynamic>>> _visits;

  @override
  void initState() {
    super.initState();
    _fetchVisits();
  }

  void _fetchVisits() {
    _visits = dbHelper.getVisitsByTournee(widget.tourneeId);
  }

  Future<void> _refreshVisits() async {
    setState(() {
      _fetchVisits();
    });
  }

  void _showAddVisitSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return AddVisitForm(
          tourneeId: widget.tourneeId,
          livreurId: widget.livreurId,
          onVisitAdded: _refreshVisits,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Détails de la tournée : ${widget.tourName}"),
        backgroundColor: Colors.blue.shade300,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _visits,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Erreur de chargement des visites"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("Aucune visite trouvée"));
          }

          final visits = snapshot.data!;
          return ListView.builder(
            itemCount: visits.length,
            itemBuilder: (context, index) {
              final visit = visits[index];
              return Card(
                margin: EdgeInsets.all(8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: ListTile(
                  title: Text("Point de vente : ${visit['point_name'] ?? 'Inconnu'}"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Produit : ${visit['product_name'] ?? 'Aucun'}"),
                      Text("Quantité : ${visit['quantite_vendue'] ?? 0}"),
                      Text("Heure : ${visit['visit_time'] ?? 'Non spécifiée'}"),
                      Text("Observation : ${visit['visit_observation'] ?? 'Aucune'}"),
                    ],
                  ),
                  trailing: Icon(Icons.info, color: Colors.blue.shade800),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddVisitSheet(context),
        child: Icon(Icons.add),
        backgroundColor: Colors.blue.shade300,
      ),
    );
  }
}

class AddVisitForm extends StatefulWidget {
  final int tourneeId;
  final int livreurId;
  final VoidCallback onVisitAdded;

  AddVisitForm({
    Key? key,
    required this.tourneeId,
    required this.livreurId,
    required this.onVisitAdded,
  }) : super(key: key);

  @override
  _AddVisitFormState createState() => _AddVisitFormState();
}

class _AddVisitFormState extends State<AddVisitForm> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  final _formKey = GlobalKey<FormState>();

  int? selectedPointId;
  int? selectedProductId;
  int quantity = 0;
  String? observation;
  TimeOfDay? selectedTime;

  late Future<List<Map<String, dynamic>>> _points;
  late Future<List<Map<String, dynamic>>> _products;

  @override
  void initState() {
    super.initState();
    _points = dbHelper.getSalesPointsByTournee(widget.tourneeId);
    _products = dbHelper.getProducts(widget.livreurId);
  }

  Future<void> _saveVisit() async {
    if (_formKey.currentState!.validate() && selectedTime != null) {
      _formKey.currentState!.save();
      final timeString = "${selectedTime!.hour}:${selectedTime!.minute}";

      await dbHelper.insertVisit(
        tourneeId: widget.tourneeId,
        pointId: selectedPointId!,
        productId: selectedProductId ?? 0,
        quantity: quantity,
        order: 0,
        observations: observation ?? '',
        time: timeString,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Visite ajoutée avec succès.')),
      );

      widget.onVisitAdded(); // Rafraîchir la liste des visites
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez remplir tous les champs.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 16.0,
        left: 16.0,
        right: 16.0,
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Ajouter une visite',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _points,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  }
                  final points = snapshot.data!;
                  return DropdownButtonFormField<int>(
                    items: points.map((point) {
                      return DropdownMenuItem<int>(
                        value: point['id'] as int,
                        child: Text(point['name'] ?? ''),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => selectedPointId = value),
                    decoration: InputDecoration(labelText: 'Point de Vente'),
                    validator: (value) => value == null ? 'Obligatoire' : null,
                  );
                },
              ),
              SizedBox(height: 20),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _products,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  }
                  final products = snapshot.data!;
                  return DropdownButtonFormField<int>(
                    items: products.map((product) {
                      return DropdownMenuItem<int>(
                        value: product['id'] as int,
                        child: Text(product['nom'] ?? ''),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => selectedProductId = value),
                    decoration: InputDecoration(labelText: 'Produit'),
                  );
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Quantité'),
                onChanged: (value) => quantity = int.tryParse(value) ?? 0,
                validator: (value) =>
                value == null || int.tryParse(value) == null ? 'Obligatoire' : null,
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(labelText: 'Observation'),
                onChanged: (value) => setState(() => observation = value),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (time != null) {
                    setState(() => selectedTime = time);
                  }
                },
                child: Text(selectedTime == null
                    ? 'Sélectionner l\'heure'
                    : 'Heure : ${selectedTime!.hour}:${selectedTime!.minute}'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveVisit,
                child: Text('Enregistrer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade300,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
