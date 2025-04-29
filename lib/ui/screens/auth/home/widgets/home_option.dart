import 'package:flutter/material.dart';

class HomeOption {
  final String title;
  final IconData icon;
  final String route;

  HomeOption(this.title, this.icon, this.route);
}

final List<HomeOption> homeOptions = [
  HomeOption("Registrar Kilos", Icons.fitness_center, "/registrar_kilos"),
  HomeOption("Registrar Ventas", Icons.attach_money, "/registrar_ventas"),
  HomeOption("Cerrar Sesión", Icons.logout, "/cerrar_sesion"),
];