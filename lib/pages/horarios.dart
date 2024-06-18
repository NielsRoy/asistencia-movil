// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, avoid_print, prefer_const_constructors

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Services/horarioService.dart';
import '../components/barMenu.dart';
import '../models/materiaModel.dart';

class Horario extends StatefulWidget {
  @override
  _HorarioState createState() => _HorarioState();
}

class _HorarioState extends State<Horario> {
  String _selectedDay = DateFormat('EEEE', 'es_ES').format(DateTime.now());
  Map<String, List<Materia>> materiasPorDia = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    print("Entrado a _fetchHorario");
    _fetchHorario();
  }

  Future<void> _fetchHorario() async {
    print("Ya estoy en _fetchHorario");
    try {
      HorarioService horarioService = HorarioService();
      List<Materia> materias = await horarioService.obtenerHorarios();

      // Agrupar las materias por día
      Map<String, List<Materia>> materiasGrouped = {};
      for (var materia in materias) {
        final dia = materia.dia.toLowerCase();
        if (!materiasGrouped.containsKey(dia)) {
          materiasGrouped[dia] = [];
        }
        materiasGrouped[dia]!.add(materia);
      }

      setState(() {
        materiasPorDia = materiasGrouped;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // Manejar el error (e.g., mostrar un mensaje de error)
    }
  }

  final List<String> daysOfWeek = ['lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado', 'domingo'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Horario'),
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
                children: <Widget>[
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: FadeInUp(
                      duration: Duration(milliseconds: 1000),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Horario de Clases",
                            style: TextStyle(color: Colors.white, fontSize: 30),
                          ),
                          SizedBox(height: 20),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade800,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: DropdownButton<String>(
                              value: _selectedDay,
                              icon: Icon(Icons.arrow_downward, color: Colors.white),
                              iconSize: 24,
                              elevation: 16,
                              style: TextStyle(color: Colors.white),
                              dropdownColor: Colors.orange.shade800,
                              underline: Container(
                                height: 2,
                                color: Colors.white,
                              ),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedDay = newValue!;
                                });
                              },
                              items: daysOfWeek.map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: buildHorario(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget buildHorario() {
    final List<Materia> materias = materiasPorDia[_selectedDay.toLowerCase()] ?? [];

    return ListView.builder(
      itemCount: 15, // De 7am a 10pm son 15 horas
      itemBuilder: (context, index) {
        final hour = 7 + index;
        final materia = materias.firstWhere(
          (materia) {
            final startHour = int.parse(materia.horaInicio.split(':')[0]);
            final endHour = int.parse(materia.horaFin.split(':')[0]);
            return startHour <= hour && endHour > hour;
          },
          orElse: () => Materia(
            horarioId: 0,
            horaInicio: '',
            horaFin: '',
            dia: '',
            aula: Aula(id: 0, numero: 0, capacidad: 0),
            programacionAcademica: ProgramacionAcademica(id: 0, ano: 0, periodo: ''),
            materia: MateriaInfo(id: 0, nombre: '', sigla: '', grupo: ''),
          ),
        );

        return Row(
          children: <Widget>[
            Container(
              width: 60,
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text(
                '$hour:00',
                style: TextStyle(fontSize: 16),
              ),
            ),
            SizedBox(width: 10),
            if (materia.horarioId != 0)
              Expanded(
                child: FadeInUp(
                  duration: Duration(milliseconds: 1500),
                  child: Card(
                    color: Colors.grey[800],
                    elevation: 5,
                    margin: EdgeInsets.symmetric(vertical: 5),
                    child: ListTile(
                      title: Text(
                        materia.materia.nombre,
                        style: TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        '${materia.materia.sigla} - Grupo: ${materia.materia.grupo} - ${materia.horaInicio} - ${materia.horaFin} - Aula: ${materia.aula.numero}',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
