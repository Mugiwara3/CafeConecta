import 'package:flutter/material.dart';

class RegistrarKilosScreen extends StatefulWidget {
  const RegistrarKilosScreen({super.key});

  @override
  State<RegistrarKilosScreen> createState() => _RegistrarKilosScreenState();
}

class _RegistrarKilosScreenState extends State<RegistrarKilosScreen> {
  List<String> trabajadores = [];
  final List<String> dias = [
    "Lunes",
    "Martes",
    "Miércoles",
    "Jueves",
    "Viernes",
    "Sábado",
    "Domingo"
  ];

  List<Map<String, dynamic>> recolecciones = [];

  void _agregarTrabajador() {
    String nombre = '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar trabajador'),
        content: TextField(
          autofocus: true,
          onChanged: (value) => nombre = value,
          decoration: const InputDecoration(labelText: 'Nombre del trabajador'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (nombre.isNotEmpty && !trabajadores.contains(nombre)) {
                setState(() {
                  trabajadores.add(nombre);
                  // Actualiza todas las recolecciones existentes con este trabajador
                  for (var recoleccion in recolecciones) {
                    recoleccion['data'][nombre] = {
                      for (var d in dias) d: {'D': '', 'T': ''}
                    };
                  }
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  void _eliminarTrabajador() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar trabajador'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: trabajadores
              .map((nombre) => ListTile(
                    title: Text(nombre),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          trabajadores.remove(nombre);
                          for (var recoleccion in recolecciones) {
                            recoleccion['data'].remove(nombre);
                          }
                        });
                        Navigator.pop(context);
                      },
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }

  void _recolectarCafe() {
    String lote = '';
    String fecha = '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva Recolección'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Nombre del lote'),
              onChanged: (value) => lote = value,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Fecha'),
              onChanged: (value) => fecha = value,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (lote.isNotEmpty && fecha.isNotEmpty) {
                final data = {
                  for (var t in trabajadores)
                    t: {
                      for (var d in dias) d: {'D': '', 'T': ''}
                    }
                };
                setState(() {
                  recolecciones.add({
                    'lote': lote,
                    'fecha': fecha,
                    'data': data,
                  });
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  String _calcularTotal(Map<String, dynamic> datosTrabajador) {
    double total = 0;
    for (var dia in dias) {
      if (datosTrabajador.containsKey(dia)) {
        final diaData = datosTrabajador[dia];
        if (diaData != null) {
          final d = double.tryParse(diaData['D'] ?? '');
          final t = double.tryParse(diaData['T'] ?? '');
          if (d != null) total += d;
          if (t != null) total += t;
        }
      }
    }
    return total.toStringAsFixed(1);
  }

  double _calcularTotalGeneral(Map<String, dynamic> data) {
    double total = 0;
    for (var trabajador in trabajadores) {
      final datosTrabajador = data[trabajador];
      if (datosTrabajador != null) {
        for (var dia in dias) {
          final diaData = datosTrabajador[dia];
          if (diaData != null) {
            final d = double.tryParse(diaData['D'] ?? '');
            final t = double.tryParse(diaData['T'] ?? '');
            if (d != null) total += d;
            if (t != null) total += t;
          }
        }
      }
    }
    return total;
  }

  Widget _buildTabla(Map<String, dynamic> recoleccion) {
    final data = recoleccion['data'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lote: ${recoleccion['lote']} - Fecha: ${recoleccion['fecha']}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Table(
            defaultColumnWidth: const IntrinsicColumnWidth(),
            border: TableBorder.all(),
            children: [
              TableRow(
                children: [
                  const TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Text('Trabajador',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  for (var dia in dias)
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(dia,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  const TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Text("Total",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              for (var trabajador in trabajadores)
                TableRow(
                  children: [
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(trabajador),
                      ),
                    ),
                    ...dias.map((dia) {
                      return TableCell(
                        child: Column(
                          children: [
                            TextField(
                              decoration: const InputDecoration(
                                hintText: '',
                                border: InputBorder.none,
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 4),
                              ),
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                setState(() {
                                  data[trabajador][dia]['D'] = value;
                                });
                              },
                            ),
                            const Divider(height: 1),
                            TextField(
                              decoration: const InputDecoration(
                                hintText: '',
                                border: InputBorder.none,
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 4),
                              ),
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                setState(() {
                                  data[trabajador][dia]['T'] = value;
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    }),
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          _calcularTotal(data[trabajador]),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              TableRow(
                children: [
                  const TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        "Total General",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                    ),
                  ),
                  for (var _ in dias) const TableCell(child: SizedBox.shrink()),
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        _calcularTotalGeneral(data).toStringAsFixed(1),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Kilos'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ElevatedButton(
                  onPressed: _recolectarCafe,
                  child: const Text('Recolectar Café'),
                ),
                ElevatedButton(
                  onPressed: _agregarTrabajador,
                  child: const Text('Agregar Trabajador'),
                ),
                ElevatedButton(
                  onPressed: _eliminarTrabajador,
                  child: const Text('Eliminar Trabajador'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: recolecciones.isEmpty
                  ? const Text("No hay recolecciones aún.")
                  : ListView.builder(
                      itemCount: recolecciones.length,
                      itemBuilder: (context, index) {
                        return _buildTabla(recolecciones[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
