import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:miapp_cafeconecta/models/recoleccion_model.dart';
import 'package:miapp_cafeconecta/ui/screens/auth/farm/widgets/service/farm_service.dart';
import 'package:miapp_cafeconecta/ui/screens/auth/farm/widgets/service/recoleccion_service.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import 'package:miapp_cafeconecta/controllers/auth_controller.dart';
import 'package:miapp_cafeconecta/models/farm_model.dart';

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

  List<Recoleccion> recolecciones = [];
  List<Farm> fincas = [];
  String? selectedFarmId;
  String? selectedLoteId;
  
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();
  String searchQuery = "";
  
  // Map para almacenar las expansiones actuales de cada panel
  Map<int, bool> expandedPanels = {};
  Map<String, bool> expandedTrabajadores = {};
  
  // Servicios
  final FarmService _farmService = FarmService();
  final RecoleccionService _recoleccionService = RecoleccionService();
  
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
      // Obtener el usuario actual
      final authController = Provider.of<AuthController>(context, listen: false);
      final user = authController.currentUser;
      
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }
      
      // Cargar fincas del usuario
      _farmService.getFarmsForUser(user.uid).listen((farmsData) {
        setState(() {
          fincas = farmsData;
          if (fincas.isNotEmpty && selectedFarmId == null) {
            selectedFarmId = fincas.first.id;
          }
        });
        _cargarRecolecciones();
      });
      
      // Cargar trabajadores
      final trabajadoresSnapshot = await FirebaseFirestore.instance
          .collection('trabajadores')
          .get();
          
      final List<String> trabajadoresList = [];
      for (var doc in trabajadoresSnapshot.docs) {
        trabajadoresList.add(doc['nombre']);
      }

      setState(() {
        trabajadores = trabajadoresList;
        
        // Inicializar expansión de trabajadores
        for (var trabajador in trabajadores) {
          expandedTrabajadores[trabajador] = false;
        }
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
  
  // Cargar recolecciones según la finca seleccionada
  Future<void> _cargarRecolecciones() async {
    if (selectedFarmId == null) return;
    
    setState(() {
      isLoading = true;
    });
    
    try {
      final recoleccionesList = await _recoleccionService.getRecoleccionesByFarm(selectedFarmId!);
      
      setState(() {
        recolecciones = recoleccionesList;
        isLoading = false;
        
        // Inicializar los estados de expansión
        for (int i = 0; i < recoleccionesList.length; i++) {
          expandedPanels[i] = i == 0; // El primer panel estará expandido
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar recolecciones: $e')),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  // Método para guardar una recolección en Firebase
  Future<void> _guardarRecoleccion(Recoleccion recoleccion) async {
    try {
      await _recoleccionService.saveRecoleccion(recoleccion);

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
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
            ),
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
                  expandedTrabajadores[nombre] = false;
                  
                  // Actualiza todas las recolecciones existentes con este trabajador
                  for (var recoleccion in recolecciones) {
                    final dataActualizado = Map<String, dynamic>.from(recoleccion.data);
                    dataActualizado[nombre] = {
                      for (var d in dias) d: {'D': '', 'T': ''}
                    };
                    
                    final recoleccionActualizada = Recoleccion(
                      id: recoleccion.id,
                      farmId: recoleccion.farmId,
                      loteId: recoleccion.loteId,
                      fecha: recoleccion.fecha,
                      data: dataActualizado,
                      timestamp: recoleccion.timestamp,
                    );
                    
                    _guardarRecoleccion(recoleccionActualizada);
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
                          expandedTrabajadores.remove(nombre);
                          for (var i = 0; i < recolecciones.length; i++) {
                            final dataActualizado = Map<String, dynamic>.from(recolecciones[i].data);
                            dataActualizado.remove(nombre);
                            
                            final recoleccionActualizada = Recoleccion(
                              id: recolecciones[i].id,
                              farmId: recolecciones[i].farmId,
                              loteId: recolecciones[i].loteId,
                              fecha: recolecciones[i].fecha,
                              data: dataActualizado,
                              timestamp: recolecciones[i].timestamp,
                            );
                            
                            recolecciones[i] = recoleccionActualizada;
                            _guardarRecoleccion(recoleccionActualizada);
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
    if (selectedFarmId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione una finca primero')),
      );
      return;
    }
    
    // Encontrar la finca seleccionada
    final selectedFarm = fincas.firstWhere((farm) => farm.id == selectedFarmId);
    
    // Variables para el diálogo
    String loteId = '';
    String fecha = DateFormat('yyyy-MM-dd').format(DateTime.now());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva Recolección'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Finca: ${selectedFarm.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            // Dropdown para seleccionar lote
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Seleccione un lote'),
              items: selectedFarm.plots.map((plot) {
                return DropdownMenuItem<String>(
                  value: plot.name,
                  child: Text(plot.name),
                );
              }).toList(),
              onChanged: (value) {
                loteId = value ?? '';
              },
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: () {
                _seleccionarFecha((selectedDate) {
                  fecha = DateFormat('yyyy-MM-dd').format(selectedDate);
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
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              if (loteId.isNotEmpty && fecha.isNotEmpty) {
                final data = {
                  for (var t in trabajadores)
                    t: {
                      for (var d in dias) d: {'D': '', 'T': ''}
                    }
                };
                
                final nuevaRecoleccion = Recoleccion(
                  id: '',
                  farmId: selectedFarmId!,
                  loteId: loteId,
                  fecha: fecha,
                  data: data,
                  timestamp: Timestamp.now(),
                );
                
                setState(() {
                  recolecciones.add(nuevaRecoleccion);
                  expandedPanels[recolecciones.length - 1] = true;
                });
                
                _guardarRecoleccion(nuevaRecoleccion);
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Seleccione un lote y una fecha')),
                );
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

  double calcularTotalGeneral(Map<String, dynamic> data) {
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
    final recoleccion = recolecciones[recoleccionIndex];
    final dataActualizado = Map<String, dynamic>.from(recoleccion.data);
    
    if (!dataActualizado.containsKey(trabajador)) {
      dataActualizado[trabajador] = {};
    }
    
    if (!dataActualizado[trabajador].containsKey(dia)) {
      dataActualizado[trabajador][dia] = {};
    }
    
    dataActualizado[trabajador][dia][campo] = valor;
    
    final recoleccionActualizada = Recoleccion(
      id: recoleccion.id,
      farmId: recoleccion.farmId,
      loteId: recoleccion.loteId,
      fecha: recoleccion.fecha,
      data: dataActualizado,
      timestamp: recoleccion.timestamp,
    );
    
    setState(() {
      recolecciones[recoleccionIndex] = recoleccionActualizada;
    });
    
    // Debounce para no hacer demasiadas peticiones a Firebase
    Future.delayed(const Duration(milliseconds: 500), () {
      _guardarRecoleccion(recoleccionActualizada);
    });
  }

  // Filtrar trabajadores según la búsqueda
  List<String> filtrarTrabajadores() {
    if (searchQuery.isEmpty) {
      return trabajadores;
    }
    return trabajadores
        .where((t) => t.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  // Widget para crear un campo de entrada numérico con validación y formateo adecuados
  Widget _buildInputField(
    String initialValue, 
    Function(String) onChanged,
    {String hintText = ''}
  ) {
    final controller = TextEditingController(text: initialValue);
    
    // Asegurarse de que el cursor se posicione al final del texto
    controller.selection = TextSelection.fromPosition(
      TextPosition(offset: controller.text.length),
    );
    
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        isDense: true,
        border: const OutlineInputBorder(),
      ),
      textAlign: TextAlign.center,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: onChanged,
    );
  }

  // Widget para mostrar los datos de un día específico
  Widget _buildDiaCard(
    int recoleccionIndex,
    String trabajador, 
    String dia, 
    Map<String, dynamic>? diaData
  ) {
    final dValue = diaData?['D'] ?? '';
    final tValue = diaData?['T'] ?? '';
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dia,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Expanded(
                  flex: 2,
                  child: Text('Mañana:'),
                ),
                Expanded(
                  flex: 3,
                  child: _buildInputField(
                    dValue,
                    (value) => _actualizarValor(recoleccionIndex, trabajador, dia, 'D', value),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Expanded(
                  flex: 2,
                  child: Text('Tarde:'),
                ),
                Expanded(
                  flex: 3,
                  child: _buildInputField(
                    tValue,
                    (value) => _actualizarValor(recoleccionIndex, trabajador, dia, 'T', value),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget para cada trabajador con formato acordeón
  Widget _buildTrabajadorWidget(int recoleccionIndex, String trabajador, Map<String, dynamic>? datosTrabajador) {
    final isExpanded = expandedTrabajadores[trabajador] ?? false;
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          // Encabezado expandible
          ListTile(
            title: Text(trabajador),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Total: ${datosTrabajador != null ? _calcularTotal(datosTrabajador) : "0.0"} kg',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
              ],
            ),
            onTap: () {
              setState(() {
                expandedTrabajadores[trabajador] = !isExpanded;
              });
            },
          ),
          
          // Panel expandible con los días
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: dias.map((dia) {
                  final diaData = datosTrabajador?[dia];
                  return _buildDiaCard(recoleccionIndex, trabajador, dia, diaData);
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
  
  // Widget para cada recolección con formato de panel expansible
  Widget _buildRecoleccionPanel(int index, Recoleccion recoleccion) {
    final isExpanded = expandedPanels[index] ?? false;
    final totalGeneral = calcularTotalGeneral(recoleccion.data);
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          // Encabezado del panel
          ListTile(
            title: Text('${recoleccion.loteId} - ${recoleccion.fecha}'),
            subtitle: Text('Total recolectado: ${totalGeneral.toStringAsFixed(1)} kg'),
            trailing: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
            onTap: () {
              setState(() {
                expandedPanels[index] = !isExpanded;
              });
            },
          ),
          
          // Contenido expandible
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: filtrarTrabajadores().map((trabajador) {
                  return _buildTrabajadorWidget(
                    index,
                    trabajador,
                    recoleccion.data[trabajador],
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Kilos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: _agregarTrabajador,
            tooltip: 'Agregar trabajador',
          ),
          IconButton(
            icon: const Icon(Icons.person_remove),
            onPressed: _eliminarTrabajador,
            tooltip: 'Eliminar trabajador',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _recolectarCafe,
        child: const Icon(Icons.add),
        tooltip: 'Nueva recolección',
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Selector de finca
                if (fincas.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Seleccione una finca',
                        border: OutlineInputBorder(),
                      ),
                      value: selectedFarmId,
                      items: fincas.map((farm) {
                        return DropdownMenuItem<String>(
                          value: farm.id,
                          child: Text(farm.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedFarmId = value;
                        });
                        _cargarRecolecciones();
                      },
                    ),
                  ),
                
                // Barra de búsqueda
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    controller: searchController,
                    decoration: const InputDecoration(
                      labelText: 'Buscar trabajador',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                  ),
                ),
                
                // Lista de recolecciones
                Expanded(
                  child: recolecciones.isEmpty
                      ? const Center(
                          child: Text('No hay recolecciones registradas'),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: recolecciones.length,
                          itemBuilder: (context, index) {
                            return _buildRecoleccionPanel(index, recolecciones[index]);
                          },
                        ),
                ),
              ],
            ),
    );
  }
}