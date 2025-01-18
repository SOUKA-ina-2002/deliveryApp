import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';


class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'sales_management.db');
    /*return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Table Livreurs
        await db.execute('''
        CREATE TABLE livreurs (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nom TEXT NOT NULL,
          prenom TEXT NOT NULL,
          tel TEXT NOT NULL,
          mail TEXT NOT NULL UNIQUE,
          firebase_user_id TEXT NOT NULL UNIQUE
        )
      ''');

        // Table Produits
        await db.execute('''
        CREATE TABLE produits (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nom TEXT NOT NULL,
          description TEXT,
          prix_unitaire REAL NOT NULL,
          livreur_id INTEGER NOT NULL,
          FOREIGN KEY (livreur_id) REFERENCES livreurs(id) ON DELETE CASCADE
        )
      ''');

        // Table Points de Vente
        await db.execute('''
        CREATE TABLE sales_points (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          address TEXT NOT NULL,
          contact_name TEXT,
          contact_phone TEXT,
          storage_capacity INTEGER,
          gps_coordinates TEXT,
          livreur_id INTEGER NOT NULL,
          FOREIGN KEY (livreur_id) REFERENCES livreurs(id) ON DELETE CASCADE
        )
      ''');

        // Table Tournées
        await db.execute('''
        CREATE TABLE tournees (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          date TEXT NOT NULL,
          nom TEXT NOT NULL,
          livreur_id INTEGER NOT NULL,
          FOREIGN KEY (livreur_id) REFERENCES livreurs(id) ON DELETE CASCADE
      );
      ''');

        // Table Visites (Association entre tournées, points de vente, et produits)
        await db.execute('''
        CREATE TABLE visites (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          tournee_id INTEGER NOT NULL,
          point_vente_id INTEGER NOT NULL,
          produit_id INTEGER, -- Peut être NULL si aucun produit n’est associé
          quantite_vendue INTEGER,
          ordre INTEGER NOT NULL, -- Ordre de la visite
          observations TEXT,
          time TEXT,
          FOREIGN KEY (tournee_id) REFERENCES tournees(id) ON DELETE CASCADE,
          FOREIGN KEY (point_vente_id) REFERENCES sales_points(id) ON DELETE CASCADE,
          FOREIGN KEY (produit_id) REFERENCES produits(id) ON DELETE CASCADE
      );
      ''');

        // Table Itinéraires
        await db.execute('''
        CREATE TABLE itineraires (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          tournee_id INTEGER NOT NULL,
          point_depart TEXT NOT NULL,
          point_arrivee TEXT NOT NULL,
          distance REAL NOT NULL,
          temps_estime TEXT NOT NULL,
          FOREIGN KEY (tournee_id) REFERENCES tournees(id) ON DELETE CASCADE
        )
      ''');
      },
    )*/
    return await openDatabase(
      path,
      version: 2, // Mettez à jour la version
      onCreate: (db, version) async {
        // Votre code pour créer les tables
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE visites ADD COLUMN time TEXT');
        }
      },
    );
    ;
  }

  //CRUD des tables

  //table livreurs:
  Future<String> insertOrUpdateLivreur({
    required String nom,
    required String prenom,
    required String tel,
    required String firebaseUserId,
    required String mail,
  }) async {
    final db = await database;

    // Vérifiez si un livreur existe déjà avec ce firebaseUserId
    final existingLivreur = await db.query(
      'livreurs',
      where: 'firebase_user_id = ?',
      whereArgs: [firebaseUserId],
    );

    if (existingLivreur.isNotEmpty) {
      // Si le livreur existe, retourner un message d'erreur
      return "Un compte associé à cet utilisateur existe déjà.";
    }

    // Si le livreur n'existe pas, insérer un nouvel enregistrement
    await db.insert('livreurs', {
      'nom': nom,
      'prenom': prenom,
      'tel': tel,
      'mail': mail,
      'firebase_user_id': firebaseUserId,
    });

    return "Compte créé avec succès.";
  }


  Future<Map<String, dynamic>?> getLivreurByFirebaseUserId(String firebaseUserId) async {
    final db = await database;

    final result = await db.query(
      'livreurs',
      where: 'firebase_user_id = ?',
      whereArgs: [firebaseUserId],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }


  //table SalePoints:

  Future<List<Map<String, dynamic>>> getSalesPointsByTournee(int tourneeId) async {
    final db = await database;

    // Exécuter une requête pour récupérer les points de vente associés à une tournée spécifique
    return await db.rawQuery('''
    SELECT sp.*
    FROM sales_points sp
    INNER JOIN visites v ON sp.id = v.point_vente_id
    WHERE v.tournee_id = ?
  ''', [tourneeId]);
  }

  Future<List<Map<String, dynamic>>> getSalesPoints(int livreurId) async {
    final db = await database;
    return await db.query(
      'sales_points',
      where: 'livreur_id = ?',
      whereArgs: [livreurId],
    );
  }


  Future<int> insertSalesPoint({
    required String name,
    required String address,
    required String contactName,
    required String contactPhone,
    required int storageCapacity,
    required String gpsCoordinates,
    required int livreurId, // Ajout de l'ID du livreur
  }) async {
    final db = await database;
    return await db.insert('sales_points', {
      'name': name,
      'address': address,
      'contact_name': contactName,
      'contact_phone': contactPhone,
      'storage_capacity': storageCapacity,
      'gps_coordinates': gpsCoordinates,
      'livreur_id': livreurId, // Associer le point de vente au livreur
    });
  }


  Future<int> updateSalesPoint({
    required int id,
    required int livreurId,
    required String name,
    required String address,
    required String contactName,
    required String contactPhone,
    required int storageCapacity,
    required String gpsCoordinates,
  }) async {
    final db = await database;
    return await db.update(
      'sales_points',
      {
        'name': name,
        'address': address,
        'contact_name': contactName,
        'contact_phone': contactPhone,
        'storage_capacity': storageCapacity,
        'gps_coordinates': gpsCoordinates,
      },
      where: 'id = ? AND livreur_id = ?', // Vérification par id et livreur_id
      whereArgs: [id, livreurId],
    );
  }


  Future<int> deleteSalesPoint(int id, int livreurId) async {
    final db = await database;
    return await db.delete(
      'sales_points',
      where: 'id = ? AND livreur_id = ?',
      whereArgs: [id, livreurId],
    );
  }


  //table Produit

  Future<List<Map<String, dynamic>>> getProducts(int livreurId) async {
    final db = await database;
    return await db.query(
      'produits',
      where: 'livreur_id = ?',
      whereArgs: [livreurId],
    );
  }

  Future<int> insertProduct({
    required String nom,
    required String description,
    required double prixUnitaire,
    required int livreurId,
  }) async {
    final db = await database;
    return await db.insert('produits', {
      'nom': nom,
      'description': description,
      'prix_unitaire': prixUnitaire,
      'livreur_id': livreurId,
    });
  }

  Future<int> updateProduct(Map<String, dynamic> product) async {
    final db = await database;
    return await db.update(
      'produits',
      product,
      where: 'id = ?',
      whereArgs: [product['id']],
    );
  }

  Future<int> deleteProduct(int productId) async {
    final db = await database;
    return await db.delete(
      'produits',
      where: 'id = ?',
      whereArgs: [productId],
    );
  }

//table tournee
  Future<int> insertTournee({
    required String date,
    required String nom, // Ajout du champ nom
    required int livreurId,
  }) async {
    final db = await database;

    return await db.insert('tournees', {
      'date': date,
      'nom': nom, // Ajout du nom
      'livreur_id': livreurId,
    });
  }


  Future<List<Map<String, dynamic>>> getTourneesByLivreur(int livreurId) async {
    final db = await database;
    return await db.query(
      'tournees',
      where: 'livreur_id = ?',
      whereArgs: [livreurId],
      orderBy: 'date DESC',
    );
  }

  Future<void> deleteTournee(int tourneeId) async {
    final db = await database;
    await db.delete('tournees', where: 'id = ?', whereArgs: [tourneeId]);
    await db.delete('visites', where: 'tournee_id = ?', whereArgs: [tourneeId]);
  }


  //table visit
  Future<int> insertVisit({
    required int tourneeId,
    required int pointId,
    int? productId, // Facultatif
    int? quantity,
    required int order,
    String? observations,
    String? time
  }) async {
    final db = await database;

    return await db.insert('visites', {
      'tournee_id': tourneeId,
      'point_vente_id': pointId,
      'produit_id': productId, // Peut être NULL si non fourni
      'quantite_vendue': quantity,
      'ordre': order,
      'observations' : observations,
      'time' : time,
    });
  }


  Future<List<Map<String, dynamic>>> getVisitsByTournee(int tourneeId) async {
    final db = await database;
    return await db.rawQuery('''
    SELECT 
      v.*, 
      sp.name AS point_name, 
      p.nom AS product_name, 
      v.observations AS observation
    FROM visites v
    LEFT JOIN sales_points sp ON v.point_vente_id = sp.id
    LEFT JOIN produits p ON v.produit_id = p.id
    WHERE v.tournee_id = ? AND v.produit_id IS NOT NULL
    ORDER BY v.ordre ASC
  ''', [tourneeId]);
  }



}
