import 'package:flutter/material.dart';

class RegistrarKilosScreen extends StatefulWidget {
  const RegistrarKilosScreen({super.key});

  @override
  State<RegistrarKilosScreen> createState() => _RegistrarKilosScreenState();
}

class _RegistrarKilosScreenState extends State<RegistrarKilosScreen> {
  // Lista de trabajadores
  final List<String> trabajadores = [];
  
  // Días de la semana
  static const List<String> dias = [
    "Lunes",
    "Martes",
    "Miércoles",
    "Jueves",
    "Viernes",
    "Sábado",
    "Domingo"
  ];

  // Lista de recolecciones
  final List<Map<String, dynamic>> recolecciones = [];

  // Controladores para los diálogos
  final TextEditingController _trabajadorController = TextEditingController();
  final TextEditingController _loteController = TextEditingController();
  final TextEditingController _fechaController = TextEditingController();

  @override
  void dispose() {
    _trabajadorController.dispose();
    _loteController.dispose();
    _fechaController.dispose();
    super.dispose();
  }

  // Agregar un nuevo trabajador
  void _agregarTrabajador() {
    _trabajadorController.clear();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar trabajador'),
        content: TextField(
          controller: _trabajadorController,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Nombre del trabajador',
            hintText: 'Ej: Juan Pérez',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final nombre = _trabajadorController.text.trim();
              if (nombre.isNotEmpty && !trabajadores.contains(nombre)) {
                setState(() {
                  trabajadores.add(nombre);
                  // Actualizar todas las recolecciones existentes
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

  // Eliminar un trabajador existente
  void _eliminarTrabajador() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar trabajador'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: trabajadores.length,
            itemBuilder: (context, index) {
              final trabajador = trabajadores[index];
              return ListTile(
                title: Text(trabajador),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      trabajadores.removeAt(index);
                      for (var recoleccion in recolecciones) {
                        recoleccion['data'].remove(trabajador);
                      }
                    });
                    Navigator.pop(context);
                  },
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  // Crear una nueva recolección
  void _recolectarCafe() {
    _loteController.clear();
    _fechaController.clear();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva Recolección'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _loteController,
              decoration: const InputDecoration(
                labelText: 'Nombre del lote',
                hintText: 'Ej: Lote Norte',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _fechaController,
              decoration: const InputDecoration(
                labelText: 'Fecha',
                hintText: 'Ej: 15/05/2023',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true,
              onTap: () async {
                final fecha = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (fecha != null) {
                  _fechaController.text =
                      "${fecha.day}/${fecha.month}/${fecha.year}";
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final lote = _loteController.text.trim();
              final fecha = _fechaController.text.trim();
              
              if (lote.isNotEmpty && fecha.isNotEmpty) {
                setState(() {
                  recolecciones.add({
                    'lote': lote,
                    'fecha': fecha,
                    'data': {
                      for (var t in trabajadores)
                        t: {for (var d in dias) d: {'D': '', 'T': ''}}
                    },
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

  // Calcular total para un trabajador
  String _calcularTotal(Map<String, dynamic> datosTrabajador) {
    double total = 0;
    for (var dia in dias) {
      if (datosTrabajador.containsKey(dia)) {
        final diaData = datosTrabajador[dia];
        if (diaData != null) {
          final d = double.tryParse(diaData['D'] ?? '') ?? 0;
          final t = double.tryParse(diaData['T'] ?? '') ?? 0;
          total += d + t;
        }
      }
    }
    return total.toStringAsFixed(1);
  }

  // Calcular total general para una recolección
  double _calcularTotalGeneral(Map<String, dynamic> data) {
    double total = 0;
    for (var trabajador in trabajadores) {
      final datosTrabajador = data[trabajador];
      if (datosTrabajador != null) {
        for (var dia in dias) {
          final diaData = datosTrabajador[dia];
          if (diaData != null) {
            final d = double.tryParse(diaData['D'] ?? '') ?? 0;
            final t = double.tryParse(diaData['T'] ?? '') ?? 0;
            total += d + t;
          }
        }
      }
    }
    return total;
  }

  // Construir la tabla de recolección
  Widget _buildTabla(Map<String, dynamic> recoleccion) {
    final data = recoleccion['data'];

    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Lote: ${recoleccion['lote']}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Fecha: ${recoleccion['fecha']}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Table(
                defaultColumnWidth: const FixedColumnWidth(100),
                border: TableBorder.all(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(5),
                ),
                children: [
                  TableRow(
                    decoration: BoxDecoration(
                      color: Colors.brown.shade100,
                    ),
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          'Trabajador',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      ...dias.map((dia) => Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              dia,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          )),
                      const Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          "Total",
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  ...trabajadores.map((trabajador) {
                    return TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            trabajador,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        ...dias.map((dia) {
                          return Column(
                            children: [
                              TextField(
                                decoration: const InputDecoration(
                                  hintText: '0',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 4),
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
                                  hintText: '0',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 4),
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
                          );
                        }),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            _calcularTotal(data[trabajador]),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    );
                  }),
                  TableRow(
                    decoration: BoxDecoration(
                      color: Colors.brown.shade50,
                    ),
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          "Total General",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.brown),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      ...List.generate(dias.length, (_) => const SizedBox.shrink()),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          _calcularTotalGeneral(data).toStringAsFixed(1),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.brown),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Kilos'),
        centerTitle: true,
        backgroundColor: Colors.brown[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Botones de acción
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Nueva Recolección'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _recolectarCafe,
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.person_add),
                  label: const Text('Agregar Trabajador'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _agregarTrabajador,
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.person_remove),
                  label: const Text('Eliminar Trabajador'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _eliminarTrabajador,
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Lista de recolecciones
            Expanded(
              child: recolecciones.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.coffee, size: 50, color: Colors.grey),
                          SizedBox(height: 10),
                          Text(
                            "No hay recolecciones registradas",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
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