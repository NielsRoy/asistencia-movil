// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, file_names, library_private_types_in_public_api

import 'dart:async';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/barMenu.dart';
import '../services/horarioService.dart';
import '../services/marcarAsistService.dart';
import '../models/materiaModel.dart';

class MarcarAsist extends StatefulWidget {
  const MarcarAsist({super.key});

  @override
  _MarcarAsistState createState() => _MarcarAsistState();
}

class _MarcarAsistState extends State<MarcarAsist> {
  static String latitud = "";
  static String longitud = "";
  String selectedSubject = ""; // Valor inicial vacío
  bool isLoading = true;
  List<Materia> materiasHoy = [];

  Future<Position> determinePosition() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Error');
      }
    }
    return await Geolocator.getCurrentPosition();
  }

  void getCurrentLocation() async {
    Position position = await determinePosition();
    setState(() {
      longitud = position.longitude.toString();
      latitud = position.latitude.toString();
    });
  }

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
    _fetchHorarioDelDia();
  }

  Future<void> _fetchHorarioDelDia() async {
    try {
      HorarioService horarioService = HorarioService();
      List<Materia> materias = await horarioService.obtenerHorarios();

      // Obtener el día actual
      String diaActual = DateFormat('EEEE', 'es_ES').format(DateTime.now()).toLowerCase();

      // Filtrar las materias del día actual
      List<Materia> materiasDelDia = materias.where((materia) => materia.dia.toLowerCase() == diaActual).toList();

      setState(() {
        materiasHoy = materiasDelDia;
        if (materiasHoy.isNotEmpty) {
          selectedSubject = '${materiasHoy[0].materia.nombre} - ${materiasHoy[0].materia.sigla} - Grupo: ${materiasHoy[0].materia.grupo} - ${materiasHoy[0].horaInicio} - ${materiasHoy[0].horaFin}';
        }
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // Manejar el error (e.g., mostrar un mensaje de error)
    }
  }

Future<void> _marcarAsistencia() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int? docenteId = prefs.getInt('docente_id');

  if (docenteId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: Docente ID no encontrado')),
    );
    return;
  }

  // Obtener la materia y horario seleccionados
  Materia materiaSeleccionada = materiasHoy.firstWhere(
    (materia) =>
        '${materia.materia.nombre} - ${materia.materia.sigla} - Grupo: ${materia.materia.grupo} - ${materia.horaInicio} - ${materia.horaFin}' ==
        selectedSubject,
  );

  String horaActual = DateFormat('HH:mm:ss').format(DateTime.now());
  String fechaActual = DateFormat('yyyy-MM-dd').format(DateTime.now());

  MarcarAsistService marcarAsistService = MarcarAsistService();
  Map<String, dynamic> response = await marcarAsistService.marcarAsistencia(
    docenteId: docenteId,
    hora: horaActual,
    fecha: fechaActual,
    latitud: double.parse(latitud),
    longitud: double.parse(longitud),
    materiaId: materiaSeleccionada.materia.id,
    horarioId: materiaSeleccionada.horarioId,
  );

  if (response.containsKey('error')) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(response['error'])),
    );
  } else {
    int statusCode = response['statusCode'];
    String message = response['message'];

    if (statusCode == 209) {
      _mostrarVentanaRetraso(response['data']['id']);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

Future<void> _marcarAsistenciaVirtual() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? docenteId = prefs.getInt('docente_id');

    if (docenteId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: Docente ID no encontrado')),
      );
      return;
    }

    // Obtener la materia y horario seleccionados
    Materia materiaSeleccionada = materiasHoy.firstWhere(
      (materia) =>
          '${materia.materia.nombre} - ${materia.materia.sigla} - Grupo: ${materia.materia.grupo} - ${materia.horaInicio} - ${materia.horaFin}' ==
          selectedSubject,
    );

    String horaActual = DateFormat('HH:mm:ss').format(DateTime.now());
    String fechaActual = DateFormat('yyyy-MM-dd').format(DateTime.now());

    MarcarAsistService marcarAsistService = MarcarAsistService();
    Map<String, dynamic> response = await marcarAsistService.marcarAsistenciaVirtual(
      docenteId: docenteId,
      hora: horaActual,
      fecha: fechaActual,
      materiaId: materiaSeleccionada.materia.id,
      horarioId: materiaSeleccionada.horarioId,
    );

    if (response.containsKey('error')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['error'])),
      );
    } else {
        int statusCode = response['statusCode'];
        String message = response['message'];

      if (statusCode == 209) {
          _mostrarVentanaRetraso(response['data']['id']);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }


  void _mostrarVentanaRetraso(int asistenciaId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String motivoRetraso = '';
        return AlertDialog(
          title: Text('Marcaste tarde. Por favor, explique el motivo de su retraso'),
          content: TextField(
            decoration: InputDecoration(hintText: "Motivo del retraso"),
            onChanged: (value) {
              motivoRetraso = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await _crearAtraso(asistenciaId, motivoRetraso);
                Navigator.of(context).pop();
              },
              child: Text('Enviar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _crearAtraso(int asistenciaId, String motivo) async {
    MarcarAsistService marcarAsistService = MarcarAsistService();
    Map<String, dynamic> response = await marcarAsistService.crearAtraso(
      asistenciaId: asistenciaId,
      motivo: motivo
    );
    if (response.containsKey('error')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['error'])),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Motivo de retraso enviado exitosamente')),
      );
    }
    
  }

  Stream<String> getCurrentTime() async* {
    while (true) {
      await Future.delayed(Duration(seconds: 1));
      yield DateFormat('HH:mm:ss').format(DateTime.now());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Marcar Asistencia'),
        backgroundColor: Colors.orange.shade900,
      ),
      drawer: const BarMenu(),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  colors: [
                    Colors.orange.shade900,
                    Colors.orange.shade800,
                    Colors.orange.shade400
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 10),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        FadeInUp(
                          duration: Duration(milliseconds: 1000),
                          child: Text(
                            "Marcar asistencia",
                            style: TextStyle(color: Colors.white, fontSize: 40),
                          ),
                        ),
                        SizedBox(height: 10),
                        FadeInUp(
                          duration: Duration(milliseconds: 1300),
                          child: StreamBuilder<String>(
                            stream: getCurrentTime(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return Text(
                                  "Hora actual: ${snapshot.data}",
                                  style: TextStyle(color: Colors.white, fontSize: 18),
                                );
                              } else {
                                return Text(
                                  "Hora actual: Cargando...",
                                  style: TextStyle(color: Colors.white, fontSize: 18),
                                );
                              }
                            },
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
                          children: <Widget>[
                            SizedBox(height: 60),
                            FadeInUp(
                              duration: Duration(milliseconds: 1400),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color.fromRGBO(225, 95, 27, .3),
                                      blurRadius: 20,
                                      offset: Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(color: Colors.grey.shade200),
                                        ),
                                      ),
                                      child: Text(
                                        "Seleccione la materia correspondiente",
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(color: Colors.grey.shade200),
                                        ),
                                      ),
                                      child: DropdownButton<String>(
                                        value: selectedSubject,
                                        isExpanded: true,
                                        icon: Icon(Icons.arrow_drop_down),
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            selectedSubject = newValue!;
                                          });
                                        },
                                        items: materiasHoy.map<DropdownMenuItem<String>>((Materia materia) {
                                          String materiaInfo = '${materia.materia.nombre} - ${materia.materia.sigla} - Grupo: ${materia.materia.grupo} - ${materia.horaInicio} - ${materia.horaFin}';
                                          return DropdownMenuItem<String>(
                                            value: materiaInfo,
                                            child: Text(materiaInfo),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 40),
                            FadeInUp(
                              duration: Duration(milliseconds: 1500),
                              child: Text(
                                "Posición: $latitud, $longitud",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                            SizedBox(height: 40),
                            FadeInUp(
                              duration: Duration(milliseconds: 1600),
                              child: MaterialButton(
                                onPressed: _marcarAsistencia,
                                height: 50,
                                color: Colors.orange[900],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Center(
                                  child: Text(
                                    "Marcar Asistencia",
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 50),
                            FadeInUp(
                              duration: Duration(milliseconds: 1700),
                              child: Text(
                                "Solicite permisos especiales",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                            SizedBox(height: 30),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: FadeInUp(
                                    duration: Duration(milliseconds: 1800),
                                    child: MaterialButton(
                                      onPressed: _marcarAsistenciaVirtual,
                                      height: 50,
                                      color: Colors.blue,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      child: Center(
                                        child: Text(
                                          "Clases virtuales",
                                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 30),
                                Expanded(
                                  child: FadeInUp(
                                    duration: Duration(milliseconds: 1900),
                                    child: MaterialButton(
                                      onPressed: () {Navigator.pushNamed(context, '/licencia');},
                                      height: 50,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      color: Colors.black,
                                      child: Center(
                                        child: Text(
                                          "Solicitar Licencia",
                                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
