import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '/utils/apiBack.dart';

class MarcarAsistService {
  final String apiUrl = "$apiBack/asistencias/marcar";

  Future<Map<String, dynamic>> marcarAsistencia({
    required int docenteId,
    required String hora,
    required String fecha,
    required double latitud,
    required double longitud,
    required int materiaId,
    required int horarioId,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      return {'error': 'Token no encontrado'};
    }

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'docenteId': docenteId,
        'hora': hora,
        'fecha': fecha,
        'latitud': latitud,
        'longitud': longitud,
        'materiaId': materiaId,
        'horarioId': horarioId,
      }),
    );

    if (response.statusCode == 200) {
      print("Respuesta Marc Asist: ${response.body}");
      return jsonDecode(response.body);
    } else {
      print("Respuesta Error: ${response.body}");
      return {'error': 'Error en la solicitud: ${response.statusCode}'};
    }
  }

  Future<Map<String, dynamic>> marcarAsistenciaVirtual({
    required int docenteId,
    required String hora,
    required String fecha,
    required int materiaId,
    required int horarioId,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      return {'error': 'Token no encontrado'};
    }

    final response = await http.post(
      Uri.parse('$apiBack/asistencias/marcar/virtual'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'docenteId': docenteId,
        'hora': hora,
        'fecha': fecha,
        'materiaId': materiaId,
        'horarioId': horarioId,
      }),
    );

    if (response.statusCode == 200) {
      print("Respuesta Marc Virtual: ${response.body}");
      return jsonDecode(response.body);
    } else {
      print("Respuesta Error: ${response.body}");
      return {'error': 'Error en la solicitud: ${response.statusCode}'};
    }
  }

  Future<Map<String, dynamic>> crearAtraso({
    required int asistenciaId,
    required String motivo,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      return {'error': 'Token no encontrado'};
    }

    final response = await http.post(
      Uri.parse('$apiBack/atrasos'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'asistenciaId': asistenciaId,
        'motivo': motivo,
      }),
    );

    if (response.statusCode == 200) {
      print("Respuesta Crear Atraso: ${response.body}");
      return jsonDecode(response.body);
    } else {
      print("Respuesta Error: ${response.body}");
      return {'error': 'Error en la solicitud: ${response.statusCode}'};
    }
  }
}
