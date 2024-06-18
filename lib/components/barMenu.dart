// ignore_for_file: prefer_const_constructors, file_names

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

class BarMenu extends StatelessWidget {
  const BarMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          Container(
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
            child: UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: Colors.transparent,
              ),
              accountName: FadeInUp(
                duration: Duration(milliseconds: 1000),
                child: Text(
                  'Bienvenido',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              accountEmail: FadeInUp(
                duration: Duration(milliseconds: 1300),
                child: Text(
                  'Docente',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
              currentAccountPicture: FadeInUp(
                duration: Duration(milliseconds: 1500),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    color: Colors.orange.shade900,
                    size: 40,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.white,
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  _buildDrawerItem(
                    context,
                    title: 'Perfil',
                    icon: Icons.person,
                    routeName: '/perfil',
                    duration: 1600,
                  ),
                  _buildDrawerItem(
                    context,
                    title: 'Marcar Asistencia',
                    icon: Icons.check_circle_outline,
                    routeName: '/marcarAsist',
                    duration: 1700,
                  ),
                  _buildDrawerItem(
                    context,
                    title: 'Horarios',
                    icon: Icons.schedule,
                    routeName: '/horarios',
                    duration: 1800,
                  ),
                  _buildDrawerItem(
                    context,
                    title: 'Materias',
                    icon: Icons.book,
                    routeName: '/materias',
                    duration: 1900,
                  ),
                  _buildDrawerItem(
                    context,
                    title: 'Registro de Asistencias',
                    icon: Icons.assignment,
                    routeName: '/asistencias',
                    duration: 2000,
                  ),
                  _buildDrawerItem(
                    context,
                    title: 'Solicitudes de Licencia',
                    icon: Icons.assignment,
                    routeName: '/solicitudes',
                    duration: 2100,
                  ),
                ],
              ),
            ),
          ),
          Container(
            color: Colors.grey[850],
            child: Column(
              children: <Widget>[
                Divider(color: Colors.white),
                _buildDrawerItem(
                  context,
                  title: 'Configuraciones',
                  icon: Icons.settings,
                  routeName: '/settings',
                  duration: 2100,
                ),
                _buildDrawerItem(
                  context,
                  title: 'Cerrar Sesión',
                  icon: Icons.exit_to_app,
                  routeName: '/',
                  duration: 2200,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, {required String title, required IconData icon, required String routeName, required int duration}) {
    return FadeInUp(
      duration: Duration(milliseconds: duration),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
            color: title == 'Configuraciones' || title == 'Cerrar Sesión' ? Colors.white : Colors.black,
          ),
        ),
        leading: Icon(
          icon,
          color: title == 'Configuraciones' || title == 'Cerrar Sesión' ? Colors.white : Colors.black,
        ),
        onTap: () {
          Navigator.pushNamed(context, routeName);
        },
      ),
    );
  }
}
