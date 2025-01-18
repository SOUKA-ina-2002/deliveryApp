import 'package:flutter/material.dart';
import '../../helpers/DataBaseHelper.dart';
import 'AddProductPage.dart';
import 'EditProductPage.dart';
import '../map-page.dart';

class ProductsPage extends StatefulWidget {
  final int livreurId;

  ProductsPage({Key? key, required this.livreurId}) : super(key: key);

  @override
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  late Future<List<Map<String, dynamic>>> _products;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  void _fetchProducts() {
    _products = dbHelper.getProducts(widget.livreurId); // Filtrer par livreurId
  }

  Future<void> _refreshProducts() async {
    setState(() {
      _fetchProducts(); // Recharger les produits
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mes Produits"),
        backgroundColor: Colors.blue.shade300,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MapPage(livreurId: widget.livreurId)),
            );
          },
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _products,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Erreur de chargement des produits"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("Aucun produit trouvé"));
          }

          final products = snapshot.data!;
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(
                margin: EdgeInsets.all(8.0),
                child: ListTile(
                  leading: Icon(Icons.inventory, color: Colors.blue.shade800),
                  title: Text(product['nom'] ?? "Nom indisponible"),
                  subtitle: Text("Prix: ${product['prix_unitaire']}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue.shade800),
                        onPressed: () async {
                          // Naviguer vers la page d'édition du produit
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditProductPage(
                                product: product, // Passez le produit à modifier
                                livreurId: widget.livreurId, // Passez le livreurId
                              ),
                            ),
                          );

                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await dbHelper.deleteProduct(product['id']);
                          _refreshProducts();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Produit supprimé")),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AddProductPage(livreurId: widget.livreurId)),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue.shade300,
      ),
    );
  }
}
