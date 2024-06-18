// ignore_for_file: file_names, avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/materiaModel.dart';
import '../utils/apiBack.dart';

class HorarioService {
  Future<List<Materia>> obtenerHorarios() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? docenteID = prefs.getInt('docente_id');
    String? token = prefs.getString('token');
    print("Este es el id del docente: $docenteID, y este es el Token: $token");
    if (docenteID == null) {
      throw Exception("Docente ID no encontrado en SharedPreferences");
    }
    if (token == null) {
      throw Exception("Token no encontrado en SharedPreferences");
    }
    print("Hasta aqui vamos bien");
    final response = await http.get(
      Uri.parse('$apiBack/horarios/docente/$docenteID'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    print("Respuesta de las materias por docente: ${response.body}");
    if (response.statusCode == 200) {
      // Normalizar y decodificar la respuesta
      List<dynamic> body = json.decode(utf8.decode(response.bodyBytes));
      print("Corregido los tildes: $body");
      return body.map((dynamic item) => Materia.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load horarios');
    }
  }
}
