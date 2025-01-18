import 'package:flutter/material.dart';
import '../../helpers/DataBaseHelper.dart';

class AddPointPage extends StatefulWidget {
  final String initialCoordinates;
  final String firebaseUserId; // Ajoutez le firebaseUserId pour identifier le livreur

  AddPointPage({Key? key, required this.initialCoordinates, required this.firebaseUserId})
      : super(key: key);

  @override
  _AddPointPageState createState() => _AddPointPageState();
}

class _AddPointPageState extends State<AddPointPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers pour les champs du formulaire
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController contactNameController = TextEditingController();
  final TextEditingController contactPhoneController = TextEditingController();
  final TextEditingController storageCapacityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Nouveau Point de Vente"),
        backgroundColor: Colors.blue.shade300,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.store_mall_directory,
                size: 80,
                color: Colors.blue.shade300,
              ),
              SizedBox(height: 10),
              Text(
                "Ajouter un Nouveau Point",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade300,
                ),
              ),
              SizedBox(height: 30),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(
                        "Nom du Point de Vente", Icons.store, false, nameController),
                    SizedBox(height: 20),
                    _buildTextField(
                        "Adresse", Icons.location_on, false, addressController),
                    SizedBox(height: 20),
                    _buildTextField(
                        "Nom du Contact", Icons.person, false, contactNameController),
                    SizedBox(height: 20),
                    _buildTextField("Numéro de Téléphone", Icons.phone, false,
                        contactPhoneController, TextInputType.phone),
                    SizedBox(height: 20),
                    _buildTextField("Capacité de Stockage", Icons.inventory, false,
                        storageCapacityController, TextInputType.number),
                    SizedBox(height: 20),
                    TextFormField(
                      initialValue: widget.initialCoordinates,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[200],
                        prefixIcon: Icon(Icons.map, color: Colors.blue.shade300),
                        labelText: "Coordonnées GPS (Lat, Long)",
                        labelStyle: TextStyle(color: Colors.blue.shade300),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      readOnly: true,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    // Récupérer l'id du livreur connecté via la méthode existante
                    final dbHelper = DatabaseHelper();
                    final livreur = await dbHelper.getLivreurByFirebaseUserId(widget.firebaseUserId);

                    if (livreur == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erreur : Livreur introuvable')),
                      );
                      return;
                    }

                    final livreurId = livreur['id']; // Extraire l'id du livreur

                    // Récupérer les valeurs des champs
                    final name = nameController.text;
                    final address = addressController.text;
                    final contactName = contactNameController.text;
                    final contactPhone = contactPhoneController.text;
                    final storageCapacity = int.tryParse(storageCapacityController.text) ?? 0;

                    // Insérer dans la base de données
                    await dbHelper.insertSalesPoint(
                      name: name,
                      address: address,
                      contactName: contactName,
                      contactPhone: contactPhone,
                      storageCapacity: storageCapacity,
                      gpsCoordinates: widget.initialCoordinates,
                      livreurId: livreurId, // Inclure l'id du livreur
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Point de Vente ajouté avec succès')),
                    );

                    Navigator.pop(context, true); // Indique que la carte doit se rafraîchir
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade300,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
                child: Text(
                  "Enregistrer",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, bool obscure,
      TextEditingController controller,
      [TextInputType keyboardType = TextInputType.text]) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[200],
        prefixIcon: Icon(icon, color: Colors.blue.shade300),
        labelText: label,
        labelStyle: TextStyle(color: Colors.blue.shade300),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      keyboardType: keyboardType,
      obscureText: obscure,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez entrer $label';
        }
        return null;
      },
    );
  }
}
