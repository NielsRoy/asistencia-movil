import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'pages/regAsist.dart';

import 'pages/horarios.dart';
import 'pages/marcarAsist.dart';
import 'pages/login.dart';
import 'pages/materias.dart';
import 'pages/perfil.dart';
import 'pages/soliPermiso.dart';
import 'pages/solicitudes.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_ES', null);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // final pushProvider = new PushNotificationProvider();
    // pushProvider.initNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routes: {
        '/': (context) => const LoginPage(),
        '/perfil': (context) => const PerfilPage(),
        '/marcarAsist': (context) => const MarcarAsist(),
        '/horarios': (context) => Horario(),
        '/materias': (context) =>  MateriasPage(),
        '/asistencias': (context) =>  AsistenciasPage(),
        '/licencia': (context) => SolicitarPermisoPage(),
        '/solicitudes': (context) => SolicitudesPage(),

        // Define más rutas para otras páginas si es necesario
      },
    );
  }
}
