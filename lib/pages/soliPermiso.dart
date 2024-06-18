import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:system_univ_movil/Services/licenciaService.dart';
import '../components/barMenu.dart';
import '../services/horarioService.dart';
import '../models/materiaModel.dart';

class SolicitarPermisoPage extends StatefulWidget {
  @override
  _SolicitarPermisoPageState createState() => _SolicitarPermisoPageState();
}

class _SolicitarPermisoPageState extends State<SolicitarPermisoPage> {
  String? selectedSubjectValue;
  DateTime selectedDate = DateTime.now();
  final TextEditingController _justificacionController = TextEditingController();
  bool isLoading = true;
  List<Materia> materias = [];

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
        materias = fetchedMaterias;
        if (materias.isNotEmpty) {
          selectedSubjectValue = _uniqueValue(materias[0]); // Selecciona el primer ítem
        }
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar materias: $e')),
      );
    }
  }

  Future<void> _crearLicencia() async {
    if (selectedSubjectValue == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, seleccione una materia')),
      );
      return;
    }

    Materia? materiaSeleccionada = _findMateriaByUniqueValue(selectedSubjectValue!);

    if (materiaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Materia seleccionada no encontrada')),
      );
      return;
    }

    String fecha = DateFormat('yyyy-MM-dd').format(selectedDate);
    String justificacion = _justificacionController.text;
    int progAcId = materiaSeleccionada.programacionAcademica.id;

    LicenciaService licenciaService = LicenciaService();
    Map<String, dynamic> response = await licenciaService.crearLicencia(
      fechaSolicitada: DateFormat('yyyy-MM-dd').format(DateTime.now()),
      fecha: fecha,
      justificacion: justificacion,
      progAcId: progAcId,
    );

    if (response.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ocurrio un error vuelva a intentarlo')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('La solicitud fue enviada con exito')),
      );
      Navigator.of(context).pop();
    }
  }

  String _uniqueValue(Materia materia) {
    return "${materia.materia.nombre}_${materia.hashCode}";
  }

  String _displayValue(Materia materia) {
    return '${materia.materia.nombre} - ${materia.materia.sigla} - Grupo: ${materia.materia.grupo} - Dia: ${materia.dia} - ${materia.horaInicio} - ${materia.horaFin}';
  }

  Materia? _findMateriaByUniqueValue(String uniqueValue) {
    return materias.firstWhere((materia) => _uniqueValue(materia) == uniqueValue);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Solicitar Licencia'),
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
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: 20),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Text(
                        "Solicitar Permiso de Inasistencia",
                        style: TextStyle(color: Colors.white, fontSize: 30),
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(30),
                        child: Column(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: DropdownButton<String>(
                                value: selectedSubjectValue,
                                isExpanded: true,
                                icon: Icon(Icons.arrow_drop_down, color: Colors.orange.shade900),
                                underline: SizedBox(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedSubjectValue = newValue;
                                  });
                                },
                                items: materias.map<DropdownMenuItem<String>>((Materia materia) {
                                  return DropdownMenuItem<String>(
                                    value: _uniqueValue(materia),
                                    child: Text(_displayValue(materia)),
                                  );
                                }).toList(),
                              ),
                            ),
                            SizedBox(height: 20),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ListTile(
                                title: Text(
                                  "Fecha de inasistencia: ${DateFormat('dd/MM/yyyy').format(selectedDate)}",
                                  style: TextStyle(color: Colors.grey),
                                ),
                                trailing: Icon(Icons.calendar_today, color: Colors.orange.shade900),
                                onTap: () => _selectDate(context),
                              ),
                            ),
                            SizedBox(height: 20),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: TextField(
                                controller: _justificacionController,
                                maxLines: 5,
                                decoration: InputDecoration(
                                  hintText: "Escriba su justificación",
                                  hintStyle: TextStyle(color: Colors.grey),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.all(10),
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            MaterialButton(
                              onPressed: () {
                                _crearLicencia();
                              },
                              height: 50,
                              color: Colors.grey.shade900,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  "Solicitar Permiso",
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
