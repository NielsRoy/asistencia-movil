// licenciaService.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/solicitudModel.dart';
import '/utils/apiBack.dart';

class LicenciaService {
  final String apiUrl = "$apiBack/licencias";

  Future<Map<String, dynamic>> crearLicencia({
    required String fechaSolicitada,
    required String fecha,
    required String justificacion,
    required int progAcId

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
        'fechaSolicitada': fechaSolicitada,
        'fecha': fecha,
        'justificacion': justificacion,
        'efectuada': false,
        'progAcId': progAcId
      }),
    );

    if (response.statusCode == 200) {
      print("Respuesta Soli Licencia: ${response.body}");
      return jsonDecode(response.body);
    } else {
      print("Respuesta Error: ${response.body}");
      return {'error': 'Error en la solicitud: ${response.statusCode}'};
    }
  }

  Future<List<Solicitud>> obtenerSolicitudes(int docenteId, String token) async {
    final url = '$apiBack/licencias/docente/$docenteId';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(utf8.decode(response.bodyBytes));
      print("Estas son las licencias: ${response.body}");
      return body.map((dynamic item) => Solicitud.fromJson(item)).toList();
    } else {
      throw Exception('Error al obtener las solicitudes');
    }
  }
}
