import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project/pages/SalePoints/SalesPointNotifier.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'pages/Auth/auth-page.dart';
import 'pages/SalePoints/add_point_page.dart'; // Assurez-vous d'importer votre AddPointPage
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    ChangeNotifierProvider(
      create: (_) => SalesPointNotifier(),
      child: MyApp(),
    ),
  );
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
          initialCoordinates: ModalRoute.of(context)?.settings.arguments as String? ?? '',
          firebaseUserId: FirebaseAuth.instance.currentUser?.uid ?? '', // Récupération de l'UID Firebase
        ), // Page pour ajouter un point
      },
    );
  }
}
