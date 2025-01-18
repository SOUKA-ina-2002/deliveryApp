import 'package:flutter/material.dart';

class SalesPointNotifier extends ChangeNotifier {
  List<Map<String, dynamic>> salesPoints = [];

  void updateSalesPoints(List<Map<String, dynamic>> points) {
    salesPoints = points;
    notifyListeners();
  }

  void removeSalesPoint(int id) {
    salesPoints.removeWhere((point) => point['id'] == id);
    notifyListeners();
  }
}
