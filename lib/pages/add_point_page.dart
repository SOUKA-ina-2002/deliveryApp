import 'package:flutter/material.dart';

class AddPointPage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

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
              // En-tête visuel
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
              // Formulaire
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField("Nom du Point de Vente", Icons.store, false),
                    SizedBox(height: 20),
                    _buildTextField("Adresse", Icons.location_on, false),
                    SizedBox(height: 20),
                    _buildTextField("Nom du Contact", Icons.person, false),
                    SizedBox(height: 20),
                    _buildTextField(
                        "Numéro de Téléphone", Icons.phone, false, TextInputType.phone),
                    SizedBox(height: 20),
                    _buildTextField(
                        "Capacité de Stockage", Icons.inventory, false, TextInputType.number),
                    SizedBox(height: 20),
                    _buildTextField("Coordonnées GPS (Lat, Long)", Icons.map, false),
                  ],
                ),
              ),
              SizedBox(height: 30),
              // Bouton Enregistrer
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    print("Point de Vente ajouté");
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade300,
                  foregroundColor: Colors.white, // Couleur du texte
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

  // Widget pour un champ de texte stylé
  Widget _buildTextField(String label, IconData icon, bool obscure,
      [TextInputType keyboardType = TextInputType.text]) {
    return TextFormField(
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
