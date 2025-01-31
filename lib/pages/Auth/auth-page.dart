import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../helpers/DataBaseHelper.dart';
import '../../helpers/authservice.dart';
import 'signupPage.dart';
import '../map-page.dart';

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final AuthService _auth = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.delivery_dining,
                      size: 50,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Mon Trajet",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Simplifiez vos livraisons",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: Colors.white70,
                    ),
                  ),
                  SizedBox(height: 40),
                  _buildTextField(_emailController, 'Email', Icons.email),
                  SizedBox(height: 20),
                  _buildTextField(_passController, 'Mot de passe', Icons.lock, obscureText: true),
                  SizedBox(height: 30),
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
                    onPressed: _signIn,
                    child: Text(
                      'Se connecter',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Nouveau ici?',
                        style: TextStyle(color: Colors.white70),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SignUpPage()),
                          );
                        },
                       child: Text(
                          'Créer un compte',
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
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
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
    );
  }

  Future<void> _signIn() async {
    try {
      String email = _emailController.text;
      String pass = _passController.text;

      // Authentification avec Firebase
      User? usr = await _auth.signInWithEmailandPass(email, pass);

      if (usr != null) {
        final firebaseUserId = usr.uid;

        // Vérifier si l'utilisateur existe dans SQLite
        final livreur = await DatabaseHelper().getLivreurByFirebaseUserId(firebaseUserId);

        if (livreur != null) {
          final livreurId = livreur['id']; // Récupérer l'id du livreur depuis SQLite

          // Si l'utilisateur existe dans SQLite, aller à la carte
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MapPage(livreurId: livreurId)),
          );
        } else {
          // Si l'utilisateur n'existe pas dans SQLite, aller à une page de mise à jour du profil
          //Navigator.pushReplacementNamed(context, '/updateProfile', arguments: firebaseUserId);
        }
      } else {
        // Utilisateur Firebase invalide
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Email ou mot de passe incorrect"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? "Erreur d'authentification"),
        ),
      );
    }
  }

  @override
  void dispose() {
    _passController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
