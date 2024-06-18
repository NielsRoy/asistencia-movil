// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:animate_do/animate_do.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:system_univ_movil/utils/apiBack.dart';
import '../components/barMenu.dart';

class AsistenciasPage extends StatefulWidget {
  @override
  _AsistenciasPageState createState() => _AsistenciasPageState();
}

class _AsistenciasPageState extends State<AsistenciasPage> {
  DateTime now = DateTime.now();
  String _selectedYear = DateFormat('yyyy').format(DateTime.now());
  String _selectedMonth = DateFormat('MMMM', 'es_ES').format(DateTime.now()).capitalize();
  String _selectedWeek = 'Semana 1';

  Map<String, List<Asistencia>> asistenciasPorFecha = {};
  bool isLoading = true;

  final List<String> years = List.generate(10, (index) => (DateTime.now().year - index).toString());
  final List<String> months = [
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre',
  ];
  final List<String> weeks = List.generate(5, (index) => 'Semana ${index + 1}');

  @override
  void initState() {
    super.initState();
    fetchAsistencias().then((data) {
      setState(() {
        asistenciasPorFecha = data;
        isLoading = false;
      });
    });
  }

Future<Map<String, List<Asistencia>>> fetchAsistencias() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    int? docenteID = prefs.getInt('docente_id');

    final response = await http.get(Uri.parse('$apiBack/asistencias/registro/$docenteID'),
        headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body)['asistencias'];
      Map<String, List<Asistencia>> asistenciasPorFecha = {};

      data.forEach((key, value) {
        List<Asistencia> asistencias = (value as List).map((asistenciaData) {
          return Asistencia(
            asistenciaData['tipo'],
            asistenciaData['fecha'],
            asistenciaData['hora'],
            asistenciaData['materia'],
            asistenciaData['sigla'],
            asistenciaData['grupo'],
          );
        }).toList();

        asistenciasPorFecha[key] = asistencias;
      });

      return asistenciasPorFecha;
    } else {
      throw Exception('Failed to load asistencias');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registro de Asistencias'),
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
        child: Column(
          children: <Widget>[
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                "Registro de Asistencias",
                style: TextStyle(color: Colors.white, fontSize: 30),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  Expanded(child: _buildDropdown(years, _selectedYear, 'Año', (newValue) => _updateYear(newValue))),
                  SizedBox(width: 10),
                  Expanded(child: _buildDropdown(months, _selectedMonth, 'Mes', (newValue) => _updateMonth(newValue))),
                  SizedBox(width: 10),
                  Expanded(child: _buildDropdown(weeks, _selectedWeek, 'Semana', (newValue) => _updateWeek(newValue))),
                ],
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(top: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: buildAsistencias(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(List<String> items, String selectedItem, String hint, ValueChanged<String?> onChanged) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.orange.shade800,
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButton<String>(
        value: selectedItem,
        isExpanded: true,
        icon: Icon(Icons.arrow_downward, color: Colors.white),
        iconSize: 24,
        elevation: 16,
        style: TextStyle(color: Colors.white),
        dropdownColor: Colors.orange.shade800,
        underline: Container(
          height: 2,
          color: Colors.transparent,
        ),
        onChanged: onChanged,
        items: items.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value, style: TextStyle(color: Colors.white)),
          );
        }).toList(),
      ),
    );
  }

  void _updateYear(String? newValue) {
    setState(() {
      _selectedYear = newValue!;
      _updateMonth(months.first);
    });
  }

  void _updateMonth(String? newValue) {
    setState(() {
      _selectedMonth = newValue!;
      _selectedWeek = weeks.first;
    });
  }

  void _updateWeek(String? newValue) {
    setState(() {
      _selectedWeek = newValue!;
    });
  }

  Widget buildAsistencias() {
    final String key = '${_selectedYear}_${_selectedMonth.toLowerCase()}_${_selectedWeek.toLowerCase()}';
    final List<Asistencia> asistencias = asistenciasPorFecha[key] ?? [];

    if (asistencias.isEmpty) {
      return Center(
        child: Text(
          'No hay registros',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: asistencias.length,
      itemBuilder: (context, index) {
        final asistencia = asistencias[index];

        return FadeInUp(
          duration: Duration(milliseconds: 1500),
          child: Card(
            color: Colors.grey[800],
            elevation: 5,
            margin: EdgeInsets.symmetric(vertical: 10),
            child: ListTile(
              title: Text(
                'Asistencia: ${asistencia.tipo}',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fecha: ${asistencia.fecha}',
                    style: TextStyle(color: Colors.white70),
                  ),
                  Text(
                    'Hora: ${asistencia.hora}',
                    style: TextStyle(color: Colors.white70),
                  ),
                  Text(
                    'Materia: ${asistencia.materia}',
                    style: TextStyle(color: Colors.white70),
                  ),
                  Text(
                    'Sigla: ${asistencia.sigla}',
                    style: TextStyle(color: Colors.white70),
                  ),
                  Text(
                    'Grupo: ${asistencia.grupo}',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class Asistencia {
  final String tipo;
  final String fecha;
  final String hora;
  final String materia;
  final String sigla;
  final String grupo;

  Asistencia(this.tipo, this.fecha, this.hora, this.materia, this.sigla, this.grupo);
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
