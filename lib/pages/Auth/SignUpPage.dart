import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../helpers/AuthService.dart';
import '../../helpers/DataBaseHelper.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _telController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _confirmpassController = TextEditingController();
  final AuthService _auth = AuthService();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade800, Colors.blue.shade600],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo or Icon
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person_add,
                        size: 50,
                        color: Colors.blue.shade800,
                      ),
                    ),
                    SizedBox(height: 20),
                    // Title
                    Text(
                      "Créer un compte",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 40),
                    // Nom field
                    _buildTextField(_nomController, "Nom", Icons.person),
                    SizedBox(height: 20),
                    // Prénom field
                    _buildTextField(_prenomController, "Prénom", Icons.person),
                    SizedBox(height: 20),
                    // Téléphone field
                    _buildTextField(_telController, "Téléphone", Icons.phone, keyboardType: TextInputType.phone),
                    SizedBox(height: 20),
                    // Email field
                    _buildTextField(_emailController, "Email", Icons.email),
                    SizedBox(height: 20),
                    // Password field
                    _buildTextField(_passController, "Mot de passe", Icons.lock, obscureText: true),
                    SizedBox(height: 20),
                    // Confirm Password field
                    _buildTextField(_confirmpassController, "Confirmez le mot de passe", Icons.lock, obscureText: true),
                    SizedBox(height: 30),
                    // Sign Up button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue.shade800,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 5,
                      ),
                      onPressed: _signUp,
                      child: Text(
                        "S'inscrire",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    SizedBox(height: 20),
                    // Already have an account
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Vous avez déjà un compte?",
                          style: TextStyle(color: Colors.white70),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            "Connectez-vous",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool obscureText = false, TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        prefixIcon: Icon(icon),
        labelText: label,
        labelStyle: TextStyle(color: Colors.blue.shade800),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue.shade800, width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return 'Veuillez entrer votre $label';
        } else if (label == "Confirmez le mot de passe" && value != _passController.text) {
          return 'Les mots de passe ne correspondent pas';
        }
        return null;
      },
    );
  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState?.save();

      // Sign up user with Firebase
      User? usr = await _auth.signUpWithEmailandPass(
        _emailController.text,
        _passController.text,
      );

      if (usr != null) {
        // Ajouter ou vérifier l'utilisateur dans SQLite
        String result = await _dbHelper.insertOrUpdateLivreur(
          nom: _nomController.text,
          prenom: _prenomController.text,
          tel: _telController.text,
          firebaseUserId: usr.uid,
          mail: _emailController.text,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result),
            backgroundColor: result.contains("succès") ? Colors.green : Colors.red,
          ),
        );

        // Si l'inscription est réussie, rediriger vers la page de connexion
        if (result == "Compte créé avec succès.") {
          Navigator.pushReplacementNamed(context, '/login');
        }
      }
    }
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _telController.dispose();
    _emailController.dispose();
    _passController.dispose();
    _confirmpassController.dispose();
    super.dispose();
  }
}
