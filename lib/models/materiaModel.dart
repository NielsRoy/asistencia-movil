// ignore_for_file: file_names

class Materia {
  final int horarioId;
  final String horaInicio;
  final String horaFin;
  final String dia;
  final Aula aula;
  final ProgramacionAcademica programacionAcademica;
  final MateriaInfo materia;

  Materia({
    required this.horarioId,
    required this.horaInicio,
    required this.horaFin,
    required this.dia,
    required this.aula,
    required this.programacionAcademica,
    required this.materia,
  });

  factory Materia.fromJson(Map<String, dynamic> json) {
    return Materia(
      horarioId: json['horarioId'],
      horaInicio: json['horaInicio'],
      horaFin: json['horaFin'],
      dia: json['dia'],
      aula: Aula.fromJson(json['aula']),
      programacionAcademica: ProgramacionAcademica.fromJson(json['programacionAcademica']),
      materia: MateriaInfo.fromJson(json['materia']),
    );
  }
}

class Aula {
  final int id;
  final int numero;
  final int capacidad;

  Aula({
    required this.id,
    required this.numero,
    required this.capacidad,
  });

  factory Aula.fromJson(Map<String, dynamic> json) {
    return Aula(
      id: json['id'],
      numero: json['numero'],
      capacidad: json['capacidad'],
    );
  }
}

class ProgramacionAcademica {
  final int id;
  final int ano;
  final String periodo;

  ProgramacionAcademica({
    required this.id,
    required this.ano,
    required this.periodo,
  });

  factory ProgramacionAcademica.fromJson(Map<String, dynamic> json) {
    return ProgramacionAcademica(
      id: json['id'],
      ano: json['ano'],
      periodo: json['periodo'],
    );
  }
}

class MateriaInfo {
  final int id;
  final String nombre;
  final String sigla;
  final String grupo;

  MateriaInfo({
    required this.id,
    required this.nombre,
    required this.sigla,
    required this.grupo,
  });

  factory MateriaInfo.fromJson(Map<String, dynamic> json) {
    return MateriaInfo(
      id: json['id'],
      nombre: json['nombre'],
      sigla: json['sigla'],
      grupo: json['grupo'],
    );
  }
}
