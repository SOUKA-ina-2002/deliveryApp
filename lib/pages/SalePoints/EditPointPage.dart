import 'package:flutter/material.dart';

import '../../helpers/DataBaseHelper.dart';

class EditPointPage extends StatefulWidget {
  final Map<String, dynamic> point;
  final int livreurId; // Ajout pour vérifier le propriétaire

  EditPointPage({Key? key, required this.point, required this.livreurId})
      : super(key: key);

  @override
  _EditPointPageState createState() => _EditPointPageState();
}

class _EditPointPageState extends State<EditPointPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers pour les champs du formulaire
  late TextEditingController nameController;
  late TextEditingController addressController;
  late TextEditingController contactNameController;
  late TextEditingController contactPhoneController;
  late TextEditingController storageCapacityController;

  @override
  void initState() {
    super.initState();

    // Préremplir les champs avec les valeurs actuelles
    nameController = TextEditingController(text: widget.point['name']);
    addressController = TextEditingController(text: widget.point['address']);
    contactNameController = TextEditingController(text: widget.point['contact_name']);
    contactPhoneController = TextEditingController(text: widget.point['contact_phone']);
    storageCapacityController =
        TextEditingController(text: widget.point['storage_capacity'].toString());
  }

  @override
  void dispose() {
    // Libérer les controllers
    nameController.dispose();
    addressController.dispose();
    contactNameController.dispose();
    contactPhoneController.dispose();
    storageCapacityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Modifier le Point de Vente"),
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
                "Modifier le Point de Vente",
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
                      "Nom du Point de Vente",
                      Icons.store,
                      false,
                      nameController,
                    ),
                    SizedBox(height: 20),
                    _buildTextField(
                      "Adresse",
                      Icons.location_on,
                      false,
                      addressController,
                    ),
                    SizedBox(height: 20),
                    _buildTextField(
                      "Nom du Contact",
                      Icons.person,
                      false,
                      contactNameController,
                    ),
                    SizedBox(height: 20),
                    _buildTextField(
                      "Numéro de Téléphone",
                      Icons.phone,
                      false,
                      contactPhoneController,
                      TextInputType.phone,
                    ),
                    SizedBox(height: 20),
                    _buildTextField(
                      "Capacité de Stockage",
                      Icons.inventory,
                      false,
                      storageCapacityController,
                      TextInputType.number,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    // Récupérer les valeurs des champs
                    final updatedPoint = {
                      'id': widget.point['id'], // ID reste inchangé
                      'name': nameController.text,
                      'address': addressController.text,
                      'contact_name': contactNameController.text,
                      'contact_phone': contactPhoneController.text,
                      'storage_capacity':
                      int.tryParse(storageCapacityController.text) ?? 0,
                    };

                    final dbHelper = DatabaseHelper();
                    final result = await dbHelper.updateSalesPoint(
                      id: updatedPoint['id'],
                      livreurId: widget.livreurId,
                      name: updatedPoint['name'],
                      address: updatedPoint['address'],
                      contactName: updatedPoint['contact_name'],
                      contactPhone: updatedPoint['contact_phone'],
                      storageCapacity: updatedPoint['storage_capacity'],
                      gpsCoordinates: widget.point['gps_coordinates'],
                    );

                    if (result > 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Point de Vente modifié avec succès')),
                      );
                      Navigator.pop(context, true); // Retourner à la liste
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Échec de la modification. Vérifiez vos données."),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
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

  Widget _buildTextField(
      String label,
      IconData icon,
      bool obscure,
      TextEditingController controller, [
        TextInputType keyboardType = TextInputType.text,
      ]) {
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
