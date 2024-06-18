// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, avoid_print, prefer_const_constructors

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import '../Services/horarioService.dart';
import '../components/barMenu.dart';
import '../models/materiaModel.dart';

class MateriasPage extends StatefulWidget {
  @override
  _MateriasPageState createState() => _MateriasPageState();
}

class _MateriasPageState extends State<MateriasPage> {
  bool isLoading = true;
  List<MateriaGrouped> materias = [];

  @override
  void initState() {
    super.initState();
    _fetchMaterias();
  }

  Future<void> _fetchMaterias() async {
    try {
      HorarioService horarioService = HorarioService();
      List<Materia> fetchedMaterias = await horarioService.obtenerHorarios();
      setState(() {
        materias = _groupMateriasByNombreYGrupo(fetchedMaterias);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // Manejar el error (e.g., mostrar un mensaje de error)
    }
  }

  List<MateriaGrouped> _groupMateriasByNombreYGrupo(List<Materia> materias) {
    Map<String, MateriaGrouped> materiasMap = {};

    for (var materia in materias) {
      String key = '${materia.materia.nombre}_${materia.materia.grupo}';
      if (!materiasMap.containsKey(key)) {
        materiasMap[key] = MateriaGrouped(
          materia: materia.materia,
          horarios: [],
        );
      }
      materiasMap[key]!.horarios.add(MateriaHorario(
        dia: materia.dia,
        horaInicio: materia.horaInicio,
        horaFin: materia.horaFin,
        aula: materia.aula.numero.toString(),
      ));
    }

    return materiasMap.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Materias'),
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
                            "Materias",
                            style: TextStyle(color: Colors.white, fontSize: 30),
                          ),
                          SizedBox(height: 20),
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
                        child: buildMateriasList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget buildMateriasList() {
    return ListView.builder(
      itemCount: materias.length,
      itemBuilder: (context, index) {
        final materiaGrouped = materias[index];

        return FadeInUp(
          duration: Duration(milliseconds: 1500),
          child: Card(
            color: Colors.grey[800],
            elevation: 5,
            margin: EdgeInsets.symmetric(vertical: 10),
            child: ListTile(
              title: Text(
                materiaGrouped.materia.nombre,
                style: TextStyle(color: Colors.white),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sigla: ${materiaGrouped.materia.sigla}',
                    style: TextStyle(color: Colors.white70),
                  ),
                  Text(
                    'Grupo: ${materiaGrouped.materia.grupo}',
                    style: TextStyle(color: Colors.white70),
                  ),
                  ...materiaGrouped.horarios.map((horario) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: Text(
                        '${horario.dia.capitalize()}: ${horario.horaInicio} - ${horario.horaFin}, Aula: ${horario.aula}',
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

class MateriaGrouped {
  final MateriaInfo materia;
  final List<MateriaHorario> horarios;

  MateriaGrouped({
    required this.materia,
    required this.horarios,
  });
}

class MateriaHorario {
  final String dia;
  final String horaInicio;
  final String horaFin;
  final String aula;

  MateriaHorario({
    required this.dia,
    required this.horaInicio,
    required this.horaFin,
    required this.aula,
  });
}
