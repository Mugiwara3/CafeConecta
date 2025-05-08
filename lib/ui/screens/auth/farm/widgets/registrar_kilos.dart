import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

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
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();
  String searchQuery = "";
  
  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  // Método para cargar datos desde Firebase
  Future<void> _cargarDatos() async {
    setState(() {
      isLoading = true;
    });
    
    try {
      // Cargar trabajadores
      final trabajadoresSnapshot = await FirebaseFirestore.instance
          .collection('trabajadores')
          .get();
          
      final List<String> trabajadoresList = [];
      for (var doc in trabajadoresSnapshot.docs) {
        trabajadoresList.add(doc['nombre']);
      }

      // Cargar recolecciones
      final recoleccionesSnapshot = await FirebaseFirestore.instance
          .collection('recolecciones')
          .get();
          
      final List<Map<String, dynamic>> recoleccionesList = [];
      for (var doc in recoleccionesSnapshot.docs) {
        recoleccionesList.add({
          'id': doc.id,
          'lote': doc['lote'],
          'fecha': doc['fecha'],
          'data': doc['data'],
        });
      }

      setState(() {
        trabajadores = trabajadoresList;
        recolecciones = recoleccionesList;
        isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar datos: $e')),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  // Método para guardar una recolección en Firebase
  Future<void> _guardarRecoleccion(Map<String, dynamic> recoleccion) async {
    try {
      final docRef = recoleccion.containsKey('id')
          ? FirebaseFirestore.instance.collection('recolecciones').doc(recoleccion['id'])
          : FirebaseFirestore.instance.collection('recolecciones').doc();
          
      await docRef.set({
        'lote': recoleccion['lote'],
        'fecha': recoleccion['fecha'],
        'data': recoleccion['data'],
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (!recoleccion.containsKey('id')) {
        // Si es nueva, actualiza el id
        setState(() {
          recoleccion['id'] = docRef.id;
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recolección guardada correctamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $e')),
      );
    }
  }

  // Método para guardar un trabajador en Firebase
  Future<void> _guardarTrabajador(String nombre) async {
    try {
      await FirebaseFirestore.instance.collection('trabajadores').add({
        'nombre': nombre,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar trabajador: $e')),
      );
    }
  }

  // Método para eliminar un trabajador de Firebase
  Future<void> _eliminarTrabajadorFirebase(String nombre) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('trabajadores')
          .where('nombre', isEqualTo: nombre)
          .get();
          
      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar trabajador: $e')),
      );
    }
  }

  void _seleccionarFecha(Function(DateTime) onDateSelected) {
    DateTime selectedDate = DateTime.now();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleccionar Fecha'),
        content: SizedBox(
          width: 300,
          height: 400,
          child: TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: selectedDate,
            calendarFormat: CalendarFormat.month,
            selectedDayPredicate: (day) {
              return isSameDay(selectedDate, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              selectedDate = selectedDay;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              onDateSelected(selectedDate);
              Navigator.pop(context);
            },
            child: const Text('Seleccionar'),
          ),
        ],
      ),
    );
  }

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
                    _guardarRecoleccion(recoleccion); // Actualiza en Firebase
                  }
                });
                _guardarTrabajador(nombre);
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
                            _guardarRecoleccion(recoleccion); // Actualiza en Firebase
                          }
                        });
                        _eliminarTrabajadorFirebase(nombre);
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
    String fecha = DateFormat('yyyy-MM-dd').format(DateTime.now());

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
            const SizedBox(height: 10),
            InkWell(
              onTap: () {
                _seleccionarFecha((selectedDate) {
                  fecha = DateFormat('yyyy-MM-dd').format(selectedDate);
                  setState(() {});
                });
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Fecha',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(fecha),
              ),
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
                
                final nuevaRecoleccion = {
                  'lote': lote,
                  'fecha': fecha,
                  'data': data,
                };
                
                setState(() {
                  recolecciones.add(nuevaRecoleccion);
                });
                
                _guardarRecoleccion(nuevaRecoleccion);
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

  // Función para actualizar los valores en Firebase después de cambios
  void _actualizarValor(int recoleccionIndex, String trabajador, String dia, String campo, String valor) {
    setState(() {
      recolecciones[recoleccionIndex]['data'][trabajador][dia][campo] = valor;
    });
    
    // Debounce para no hacer demasiadas peticiones a Firebase
    Future.delayed(const Duration(milliseconds: 500), () {
      _guardarRecoleccion(recolecciones[recoleccionIndex]);
    });
  }

  // Filtrar trabajadores según la búsqueda
  List<String> _filtrarTrabajadores() {
    if (searchQuery.isEmpty) {
      return trabajadores;
    }
    return trabajadores
        .where((t) => t.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  Widget _buildTabla(Map<String, dynamic> recoleccion, int index) {
    final data = recoleccion['data'];
    final trabajadoresFiltrados = _filtrarTrabajadores();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Lote: ${recoleccion['lote']} - Fecha: ${recoleccion['fecha']}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.save, color: Colors.green),
              onPressed: () => _guardarRecoleccion(recoleccion),
              tooltip: 'Guardar cambios',
            ),
          ],
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
              for (var trabajador in trabajadoresFiltrados)
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
                              controller: TextEditingController(
                                text: data[trabajador]?[dia]?['D'] ?? '',
                              ),
                              onChanged: (value) {
                                _actualizarValor(index, trabajador, dia, 'D', value);
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
                              controller: TextEditingController(
                                text: data[trabajador]?[dia]?['T'] ?? '',
                              ),
                              onChanged: (value) {
                                _actualizarValor(index, trabajador, dia, 'T', value);
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
                          _calcularTotal(data[trabajador] ?? {}),
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
            // Buscador de trabajadores
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Buscar trabajador',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                          setState(() {
                            searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 20),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
                    child: recolecciones.isEmpty
                        ? const Center(child: Text("No hay recolecciones aún"))
                        : ListView.builder(
                            itemCount: recolecciones.length,
                            itemBuilder: (context, index) {
                              return _buildTabla(recolecciones[index], index);
                            },
                          ),
                  ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _cargarDatos,
        tooltip: 'Actualizar datos',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}