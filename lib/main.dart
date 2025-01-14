import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import '/pages/auth-page.dart';
import '/pages/add_point_page.dart'; // Assurez-vous d'importer votre AddPointPage

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Application Livreurs',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/', // Route initiale (AuthPage)
      routes: {
        '/': (context) => AuthPage(), // Page d'authentification
        '/addPoint': (context) => AddPointPage(
          initialCoordinates: ModalRoute.of(context)!.settings.arguments as String,
        ), // Page pour ajouter un point
      },
    );
  }
}
