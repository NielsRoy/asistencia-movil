// solicitudModel.dart
class Solicitud {
  final int id;
  final String fechaSolicitada;
  final String fecha;
  final String justificacion;
  final bool efectuada;
  final MateriaDto materia;
  final HorarioDto? horario;  // Horario puede ser nulo

  Solicitud({
    required this.id,
    required this.fechaSolicitada,
    required this.fecha,
    required this.justificacion,
    required this.efectuada,
    required this.materia,
    this.horario,
  });

  factory Solicitud.fromJson(Map<String, dynamic> json) {
    return Solicitud(
      id: json['id'],
      fechaSolicitada: json['fechaSolicitada'],
      fecha: json['fecha'],
      justificacion: json['justificacion'],
      efectuada: json['efectuada'],
      materia: MateriaDto.fromJson(json['materiaDto']),
      horario: json['horarioDTO'] != null ? HorarioDto.fromJson(json['horarioDTO']) : null,
    );
  }
}

class MateriaDto {
  final int id;
  final String nombre;
  final String sigla;
  final String grupo;

  MateriaDto({
    required this.id,
    required this.nombre,
    required this.sigla,
    required this.grupo,
  });

  factory MateriaDto.fromJson(Map<String, dynamic> json) {
    return MateriaDto(
      id: json['id'],
      nombre: json['nombre'],
      sigla: json['sigla'],
      grupo: json['grupo'],  // Asegurarse de convertir a String
    );
  }
}

class HorarioDto {
  final int id;
  final String horaInicio;
  final String horaFin;
  final String dia;

  HorarioDto({
    required this.id,
    required this.horaInicio,
    required this.horaFin,
    required this.dia,
  });

  factory HorarioDto.fromJson(Map<String, dynamic> json) {
    return HorarioDto(
      id: json['id'],
      horaInicio: json['horaInicio'],
      horaFin: json['horaFin'],
      dia: json['dia'],
    );
  }
}
