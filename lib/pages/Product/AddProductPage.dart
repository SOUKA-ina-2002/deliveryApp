import 'package:flutter/material.dart';
import '../../helpers/DataBaseHelper.dart';
import 'ProductsPage.dart';

class AddProductPage extends StatefulWidget {
  final int livreurId;

  AddProductPage({Key? key, required this.livreurId}) : super(key: key);

  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers pour les champs du formulaire
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

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
        title: Text("Ajouter un Produit"),
        backgroundColor: Colors.blue.shade300,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ProductsPage(livreurId: widget.livreurId)),
            );
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
                Icons.inventory,
                size: 80,
                color: Colors.blue.shade300,
              ),
              SizedBox(height: 10),
              Text(
                "Ajouter un Nouveau Produit",
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
                    // Récupérer les valeurs des champs
                    final name = nameController.text;
                    final description = descriptionController.text;
                    final price = double.tryParse(priceController.text) ?? 0.0;

                    // Insérer dans la base de données
                    final dbHelper = DatabaseHelper();
                    await dbHelper.insertProduct(
                      nom: name,
                      description: description,
                      prixUnitaire: price,
                      livreurId: widget.livreurId,
                    );

                    // Confirmation
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Produit ajouté avec succès')),
                    );

                    // Réinitialiser les champs
                    nameController.clear();
                    descriptionController.clear();
                    priceController.clear();

                    // Conserver l'utilisateur sur la page
                    FocusScope.of(context).unfocus(); // Fermer le clavier si ouvert
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
