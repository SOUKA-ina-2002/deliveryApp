import 'dart:convert';
import 'package:http/http.dart' as http;

class RouteService {
  final String apiKey = '5b3ce3597851110001cf6248c130fe258042474eb7bb6b415801d354'; // Remplacez par votre clé API

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remainingSeconds = seconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m ${remainingSeconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${remainingSeconds}s';
    } else {
      return '${remainingSeconds}s';
    }
  }

  Future<Map<String, dynamic>?> getRoute({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) async {
    final url =
        'https://api.openrouteservice.org/v2/directions/driving-car?api_key=$apiKey';
    final body = {
      "coordinates": [
        [startLng, startLat],
        [endLng, endLat]
      ]
    };

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final distance = data['features'][0]['properties']['segments'][0]['distance'];
      final duration = data['features'][0]['properties']['segments'][0]['duration'];
      final geometry = json.encode(data['features'][0]['geometry']['coordinates']);
      final formattedDuration = _formatDuration(duration);

      return {
        'distance': distance / 1000, // Convertir en kilomètres
        'temps_estime': formattedDuration,
        'geometry': geometry,
      };
    } else {
      print('Erreur API: ${response.body}');
      return null;
    }
  }

}
