// ignore_for_file: file_names, avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/apiBack.dart';
import '../models/loginModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  Future<LoginResponse> login(String email, String password) async {
    print("Dentro del login service se envio $email y $password");
    final url = Uri.parse('$apiBack/login');
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
      }),
    );
print("Dentro del login auhtservice");//esta linea ya no se imprime
    if (response.statusCode == 200) {
      print("Respuesta del login: ${response.body}");
      final userData = json.decode(response.body);
      await saveUserData(userData);
      return LoginResponse.fromJson(userData);
    } else {
      throw Exception('Failed to login');
    }
  }

  Future<void> saveUserData(Map<String, dynamic> userData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('id', userData['id']);
    await prefs.setString('name', userData['name']);
    await prefs.setString('email', userData['email']);
    await prefs.setString('token', userData['token']);

    final docenteData = userData['docente'];
    await prefs.setInt('docente_id', docenteData['id']);
    await prefs.setString('docente_telefono', docenteData['telefono']);
    await prefs.setString('docente_profesion', docenteData['profesion']);
    await prefs.setString('docente_sexo', docenteData['sexo']);
    await prefs.setString('docente_direccion', docenteData['direccion']);
    await prefs.setInt('docente_userId', docenteData['userId']);
  }

  Future<Map<String, dynamic>?> getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? id = prefs.getInt('id');
    String? name = prefs.getString('name');
    String? email = prefs.getString('email');
    String? token = prefs.getString('token');

    int? docenteId = prefs.getInt('docente_id');
    String? docenteTelefono = prefs.getString('docente_telefono');
    String? docenteProfesion = prefs.getString('docente_profesion');
    String? docenteSexo = prefs.getString('docente_sexo');
    String? docenteDireccion = prefs.getString('docente_direccion');
    int? docenteUserId = prefs.getInt('docente_userId');

    if (id != null && name != null && email != null && token != null) {
      return {
        'id': id,
        'name': name,
        'email': email,
        'token': token,
        'docente': {
          'id': docenteId,
          'telefono': docenteTelefono,
          'profesion': docenteProfesion,
          'sexo': docenteSexo,
          'direccion': docenteDireccion,
          'userId': docenteUserId,
        }
      };
    } else {
      return null;
    }
  }

  Future<void> clearUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<bool> checkIfLoggedIn() async {
    Map<String, dynamic>? userData = await getUserData();
    return userData != null;
  }
}
