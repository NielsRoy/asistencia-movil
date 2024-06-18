// ignore_for_file: file_names

class LoginResponse {
  final int id;
  final String name;
  final String email;
  final String token;
  final Docente docente;

  LoginResponse({
    required this.id,
    required this.name,
    required this.email,
    required this.token,
    required this.docente,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      token: json['token'],
      docente: Docente.fromJson(json['docente']),
    );
  }
}

class Docente {
  final int id;
  final String telefono;
  final String profesion;
  final String sexo;
  final String direccion;
  final int userId;

  Docente({
    required this.id,
    required this.telefono,
    required this.profesion,
    required this.sexo,
    required this.direccion,
    required this.userId,
  });

  factory Docente.fromJson(Map<String, dynamic> json) {
    return Docente(
      id: json['id'],
      telefono: json['telefono'],
      profesion: json['profesion'],
      sexo: json['sexo'],
      direccion: json['direccion'],
      userId: json['userId'],
    );
  }
}
