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
  // Modificamos la estructura para manejar trabajadores por lote
  Map<String, List<String>> trabajadoresPorLote = {};
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
            // Seleccionar el primer lote por defecto si existe
            if (fincas.first.plots.isNotEmpty) {
              selectedLoteId = fincas.first.plots.first.name;
            }
          }
        });
        _cargarRecolecciones();
        _cargarTrabajadoresPorLote();
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

  // Nuevo método para cargar trabajadores específicos por lote
  Future<void> _cargarTrabajadoresPorLote() async {
    if (selectedFarmId == null) return;
    
    setState(() {
      isLoading = true;
    });
    
    try {
      // Consultar la colección 'trabajadores_lote' en Firebase
      final snapshot = await FirebaseFirestore.instance
          .collection('trabajadores_lote')
          .where('farmId', isEqualTo: selectedFarmId)
          .get();
      
      Map<String, List<String>> tempTrabajadoresPorLote = {};
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final loteId = data['loteId'] as String;
        final nombreTrabajador = data['nombre'] as String;
        
        if (!tempTrabajadoresPorLote.containsKey(loteId)) {
          tempTrabajadoresPorLote[loteId] = [];
        }
        
        tempTrabajadoresPorLote[loteId]!.add(nombreTrabajador);
      }
      
      setState(() {
        trabajadoresPorLote = tempTrabajadoresPorLote;
        
        // Inicializar expansión de trabajadores para todos los lotes
        for (var loteId in trabajadoresPorLote.keys) {
          for (var trabajador in trabajadoresPorLote[loteId]!) {
            expandedTrabajadores['$loteId:$trabajador'] = false;
          }
        }
        
        isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar trabajadores: $e')),
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

  // Método modificado para guardar un trabajador en Firebase asociado a un lote
  Future<void> _guardarTrabajador(String nombre, String loteId) async {
    try {
      await FirebaseFirestore.instance.collection('trabajadores_lote').add({
        'nombre': nombre,
        'loteId': loteId,
        'farmId': selectedFarmId,
        'timestamp': FieldValue.serverTimestamp(),
      });
      
      // Actualizar la lista local
      setState(() {
        if (!trabajadoresPorLote.containsKey(loteId)) {
          trabajadoresPorLote[loteId] = [];
        }
        trabajadoresPorLote[loteId]!.add(nombre);
        expandedTrabajadores['$loteId:$nombre'] = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar trabajador: $e')),
      );
    }
  }

  // Método modificado para eliminar un trabajador de Firebase asociado a un lote
  Future<void> _eliminarTrabajador(String nombre, String loteId) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('trabajadores_lote')
          .where('nombre', isEqualTo: nombre)
          .where('loteId', isEqualTo: loteId)
          .where('farmId', isEqualTo: selectedFarmId)
          .get();
          
      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
      
      // Actualizar la lista local
      setState(() {
        trabajadoresPorLote[loteId]?.remove(nombre);
        expandedTrabajadores.remove('$loteId:$nombre');
      });
      
      // Actualizar recolecciones afectadas
      for (int i = 0; i < recolecciones.length; i++) {
        if (recolecciones[i].loteId == loteId) {
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

  // Método modificado para agregar trabajador a un lote específico
  void _agregarTrabajador() {
    if (selectedFarmId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione una finca primero')),
      );
      return;
    }
    
    // Encontrar la finca seleccionada
    final selectedFarm = fincas.firstWhere((farm) => farm.id == selectedFarmId);
    
    String nombre = '';
    String loteId = '';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar trabajador'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              autofocus: true,
              onChanged: (value) => nombre = value,
              decoration: const InputDecoration(labelText: 'Nombre del trabajador'),
            ),
            const SizedBox(height: 15),
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
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              if (nombre.isNotEmpty && loteId.isNotEmpty) {
                // Verificar si el trabajador ya existe en este lote
                bool trabajadorExiste = trabajadoresPorLote[loteId]?.contains(nombre) ?? false;
                
                if (!trabajadorExiste) {
                  _guardarTrabajador(nombre, loteId);
                  
                  // Actualizar las recolecciones existentes para este lote
                  for (var recoleccion in recolecciones) {
                    if (recoleccion.loteId == loteId) {
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
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('El trabajador ya existe en este lote')),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Complete todos los campos')),
                );
              }
              Navigator.pop(context);
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

// Método modificado para eliminar trabajador de un lote específico
  void _mostrarDialogoEliminarTrabajador() {
    if (selectedFarmId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione una finca primero')),
      );
      return;
    }
    
    // Encontrar la finca seleccionada
    final selectedFarm = fincas.firstWhere((farm) => farm.id == selectedFarmId);
    
    String loteId = '';
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Eliminar trabajador'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Seleccione un lote'),
                  items: selectedFarm.plots.map((plot) {
                    return DropdownMenuItem<String>(
                      value: plot.name,
                      child: Text(plot.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      loteId = value ?? '';
                    });
                  },
                ),
                const SizedBox(height: 10),
                if (loteId.isNotEmpty)
                  Container(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.3,
                    ),
                    child: trabajadoresPorLote[loteId]?.isEmpty ?? true
                        ? const Center(child: Text('No hay trabajadores en este lote'))
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: trabajadoresPorLote[loteId]?.length ?? 0,
                            itemBuilder: (context, index) {
                              final nombre = trabajadoresPorLote[loteId]![index];
                              return ListTile(
                                title: Text(nombre),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    _eliminarTrabajador(nombre, loteId);
                                    Navigator.pop(context);
                                  },
                                ),
                              );
                            },
                          ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
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
                // Usar solo los trabajadores asociados a este lote
                final trabajadoresLote = trabajadoresPorLote[loteId] ?? [];
                
                final data = {
                  for (var t in trabajadoresLote)
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

  double calcularTotalGeneral(Map<String, dynamic> data, String loteId) {
    double total = 0;
    // Obtener solo los trabajadores de este lote
    final trabajadoresLote = trabajadoresPorLote[loteId] ?? [];
    
    for (var trabajador in trabajadoresLote) {
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

  // Filtrar trabajadores según la búsqueda y el lote seleccionado
  List<String> filtrarTrabajadores(String loteId) {
    final trabajadoresLote = trabajadoresPorLote[loteId] ?? [];
    
    if (searchQuery.isEmpty) {
      return trabajadoresLote;
    }
    return trabajadoresLote
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
  Widget _buildTrabajadorWidget(int recoleccionIndex, String trabajador, Map<String, dynamic>? datosTrabajador, String loteId) {
    final isExpanded = expandedTrabajadores['$loteId:$trabajador'] ?? false;
    
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
                expandedTrabajadores['$loteId:$trabajador'] = !isExpanded;
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
    final totalGeneral = calcularTotalGeneral(recoleccion.data, recoleccion.loteId);
    
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
                children: filtrarTrabajadores(recoleccion.loteId).map((trabajador) {
                  return _buildTrabajadorWidget(
                    index,
                    trabajador,
                    recoleccion.data[trabajador],
                    recoleccion.loteId,
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
            onPressed: _mostrarDialogoEliminarTrabajador,
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
                        _cargarTrabajadoresPorLote();
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