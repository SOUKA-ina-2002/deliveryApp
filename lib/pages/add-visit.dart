import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddVisitPage extends StatefulWidget {
  @override
  _AddVisitPageState createState() => _AddVisitPageState();
}

class _AddVisitPageState extends State<AddVisitPage> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedPointVente;
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    // Liste fictive des points de vente
    final List<String> pointsVente = [
      'Point de Vente 1',
      'Point de Vente 2',
      'Point de Vente 3'
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("Ajouter une Visite"),
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
                Icons.assignment_turned_in,
                size: 80,
                color: Colors.blue.shade300,
              ),
              SizedBox(height: 10),
              Text(
                "Nouvelle Visite",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
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
                    // Liste déroulante
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[200],
                        labelText: "Point de Vente",
                        prefixIcon: Icon(Icons.store, color: Colors.blue.shade300),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: pointsVente
                          .map((point) => DropdownMenuItem(
                        value: point,
                        child: Text(point),
                      ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedPointVente = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez sélectionner un point de vente';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    // Champ Quantité Vendue
                    _buildTextField("Quantité Vendue", Icons.shopping_cart, true),
                    SizedBox(height: 20),
                    // Champ Observations / Remarques
                    _buildTextField("Observations / Remarques", Icons.comment, false),
                    SizedBox(height: 20),
                    // Sélecteur de Date et Heure
                    SizedBox(
                      width: 300, // Largeur fixe pour les deux boutons
                      child: ElevatedButton(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (date != null) {
                            setState(() {
                              _selectedDate = date;
                            });
                          }
                        },
                        child: Text(
                          _selectedDate == null
                              ? "Sélectionner une Date"
                              : "Date : ${DateFormat('dd/MM/yyyy').format(_selectedDate!)}", // Format dd/MM/yyyy
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade300,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 15),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    SizedBox(
                      width: 300, // Même largeur que le bouton précédent
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            // Logique pour enregistrer la visite
                            print("Visite ajoutée : $_selectedPointVente, $_selectedDate");
                            Navigator.pop(context);
                          }
                        },
                        child: Text(
                          "Enregistrer",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade300,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 15),
                        ),
                      ),
                    ),

                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget pour un champ de texte stylé
  Widget _buildTextField(String label, IconData icon, bool isNumeric) {
    return TextFormField(
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[200],
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue.shade300),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      validator: (value) {
        if (isNumeric && (value == null || value.isEmpty)) {
          return 'Veuillez entrer $label';
        }
        return null;
      },
    );
  }
}
