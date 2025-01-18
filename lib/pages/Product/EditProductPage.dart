import 'package:flutter/material.dart';
import '../../helpers/DataBaseHelper.dart';
import 'ProductsPage.dart';

class EditProductPage extends StatefulWidget {
  final Map<String, dynamic> product;
  final int livreurId;

  EditProductPage({Key? key, required this.product, required this.livreurId}) : super(key: key);

  @override
  _EditProductPageState createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers pour les champs du formulaire
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController priceController;

  @override
  void initState() {
    super.initState();

    // Préremplir les champs avec les valeurs actuelles
    nameController = TextEditingController(text: widget.product['nom']);
    descriptionController = TextEditingController(text: widget.product['description']);
    priceController =
        TextEditingController(text: widget.product['prix_unitaire'].toString());
  }

  @override
  void dispose() {
    // Libérer les controllers
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Modifier le Produit"),
        backgroundColor: Colors.blue.shade300,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Retour à la page précédente
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.edit,
                size: 80,
                color: Colors.blue.shade300,
              ),
              SizedBox(height: 10),
              Text(
                "Modifier le Produit",
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
                      "Nom du Produit",
                      Icons.label,
                      false,
                      nameController,
                    ),
                    SizedBox(height: 20),
                    _buildTextField(
                      "Description",
                      Icons.description,
                      false,
                      descriptionController,
                    ),
                    SizedBox(height: 20),
                    _buildTextField(
                      "Prix Unitaire",
                      Icons.attach_money,
                      false,
                      priceController,
                      TextInputType.number,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    // Récupérer les valeurs mises à jour
                    final updatedProduct = {
                      'id': widget.product['id'], // L'identifiant reste inchangé
                      'nom': nameController.text,
                      'description': descriptionController.text,
                      'prix_unitaire': double.tryParse(priceController.text) ?? 0.0,
                      'livreur_id': widget.livreurId,
                    };

                    // Mettre à jour la base de données
                    final dbHelper = DatabaseHelper();
                    await dbHelper.updateProduct(updatedProduct);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Produit modifié avec succès')),
                    );

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => ProductsPage(livreurId: widget.livreurId)),
            );
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
