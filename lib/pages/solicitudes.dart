// solicitudesPage.dart
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/licenciaService.dart';
import '../components/barMenu.dart';
import '../models/solicitudModel.dart'; // Importa el modelo de solicitud

class SolicitudesPage extends StatefulWidget {
  @override
  _SolicitudesPageState createState() => _SolicitudesPageState();
}

class _SolicitudesPageState extends State<SolicitudesPage> {
  bool isLoading = true;
  List<Solicitud> solicitudes = []; // Usa la clase Solicitud importada

  @override
  void initState() {
    super.initState();
    _fetchSolicitudes();
  }

  Future<void> _fetchSolicitudes() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? docenteId = prefs.getInt('docente_id');
      String? token = prefs.getString('token');

      if (docenteId != null && token != null) {
        LicenciaService licenciaService = LicenciaService();
        List<Solicitud> fetchedSolicitudes = await licenciaService.obtenerSolicitudes(docenteId, token);
        setState(() {
          solicitudes = fetchedSolicitudes;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: No se encontró el docenteId o el token')),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar solicitudes: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Solicitudes de Licencia'),
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
                    Colors.orange.shade400,
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
                            "Solicitudes de Licencia",
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
                        child: buildSolicitudesList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget buildSolicitudesList() {
    return ListView.builder(
      itemCount: solicitudes.length,
      itemBuilder: (context, index) {
        final solicitud = solicitudes[index];

        return FadeInUp(
          duration: Duration(milliseconds: 1500),
          child: Card(
            color: Colors.grey[800],
            elevation: 5,
            margin: EdgeInsets.symmetric(vertical: 10),
            child: ListTile(
              title: Text(
                solicitud.materia.nombre,
                style: TextStyle(color: Colors.white),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Grupo: ${solicitud.materia.grupo}',
                    style: TextStyle(color: Colors.white70),
                  ),
                  Text(
                    'Fecha solicitada: ${solicitud.fechaSolicitada}',
                    style: TextStyle(color: Colors.white70),
                  ),
                  Text(
                    'Fecha: ${solicitud.fecha}',
                    style: TextStyle(color: Colors.white70),
                  ),
                  Text(
                    'Justificación: ${solicitud.justificacion}',
                    style: TextStyle(color: Colors.white70),
                  ),
                  Text(
                    'Estado: ${solicitud.efectuada ? "APROBADO" : "NO APROBADO"}',
                    style: TextStyle(color: solicitud.efectuada ? Colors.green : Colors.red),
                  ),
                  Text(
                    'Horario: ${solicitud.horario?.horaInicio ?? "N/A"} - ${solicitud.horario?.horaFin ?? "N/A"}',
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
