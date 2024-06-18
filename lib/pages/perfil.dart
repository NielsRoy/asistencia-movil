// ignore_for_file: prefer_const_constructors

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/barMenu.dart';

class PerfilPage extends StatelessWidget {
  const PerfilPage({super.key});

  Future<Map<String, dynamic>> _getUserData() async {
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
      },
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil'),
        backgroundColor: Colors.orange.shade900,
      ),
      drawer: const BarMenu(),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            colors: [
              Colors.orange.shade900,
              Colors.orange.shade800,
              Colors.orange.shade400,
            ],
          ),
        ),
        child: FutureBuilder<Map<String, dynamic>>(
          future: _getUserData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error al cargar los datos"));
            } else {
              final userData = snapshot.data!;
              final docenteData = userData['docente'] as Map<String, dynamic>;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 80),
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        FadeInUp(
                          duration: Duration(milliseconds: 1000),
                          child: Text(
                            "Perfil del Usuario",
                            style: TextStyle(color: Colors.white, fontSize: 40),
                          ),
                        ),
                        SizedBox(height: 10),
                        FadeInUp(
                          duration: Duration(milliseconds: 1300),
                          child: Text(
                            "Información personal",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(60),
                          topRight: Radius.circular(60),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(height: 20),
                            FadeInUp(
                              duration: Duration(milliseconds: 1400),
                              child: ListTile(
                                leading: Icon(
                                  Icons.person,
                                  color: Colors.orange.shade900,
                                ),
                                title: Text(
                                  "Nombre de Usuario",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(userData['name'] ?? 'N/A'),
                              ),
                            ),
                            FadeInUp(
                              duration: Duration(milliseconds: 1500),
                              child: ListTile(
                                leading: Icon(
                                  Icons.email,
                                  color: Colors.orange.shade900,
                                ),
                                title: Text(
                                  "Correo Electrónico",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(userData['email'] ?? 'N/A'),
                              ),
                            ),
                            FadeInUp(
                              duration: Duration(milliseconds: 1600),
                              child: ListTile(
                                leading: Icon(
                                  Icons.phone,
                                  color: Colors.orange.shade900,
                                ),
                                title: Text(
                                  "Número de Teléfono",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(docenteData['telefono'] ?? 'N/A'),
                              ),
                            ),
                            FadeInUp(
                              duration: Duration(milliseconds: 1700),
                              child: ListTile(
                                leading: Icon(
                                  Icons.home,
                                  color: Colors.orange.shade900,
                                ),
                                title: Text(
                                  "Dirección",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(docenteData['direccion'] ?? 'N/A'),
                              ),
                            ),
                            FadeInUp(
                              duration: Duration(milliseconds: 1700),
                              child: ListTile(
                                leading: Icon(
                                  Icons.work,
                                  color: Colors.orange.shade900,
                                ),
                                title: Text(
                                  "Profesion",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(docenteData['profesion'] ?? 'N/A'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
