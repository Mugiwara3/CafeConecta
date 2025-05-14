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

  // Método para cargar trabajadores específicos por lote
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

  // Método para guardar un trabajador en Firebase asociado a un lote
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

  // Método para eliminar un trabajador de Firebase asociado a un lote
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

  // Método para agregar trabajador a un lote específico
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
                      // Ahora solo almacenamos mañana y tarde por trabajador, sin los días
                      dataActualizado[nombre] = {
                        'manana': '',
                        'tarde': ''
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

  // Método para eliminar trabajador de un lote específico
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
                
                // Nuevo formato de datos simplificado: solo mañana y tarde por trabajador
                final data = {
                  for (var t in trabajadoresLote)
                    t: {
                      'manana': '',
                      'tarde': ''
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

  // Calcular total para un trabajador
  String _calcularTotal(Map<String, dynamic> datosTrabajador) {
    double total = 0;
    
    // Ahora simplemente sumamos mañana y tarde
    final manana = double.tryParse(datosTrabajador['manana'] ?? '') ?? 0;
    final tarde = double.tryParse(datosTrabajador['tarde'] ?? '') ?? 0;
    total = manana + tarde;
    
    return total.toStringAsFixed(1);
  }

  // Calcular total general para todos los trabajadores
  double calcularTotalGeneral(Map<String, dynamic> data, String loteId) {
    double total = 0;
    // Obtener solo los trabajadores de este lote
    final trabajadoresLote = trabajadoresPorLote[loteId] ?? [];
    
    for (var trabajador in trabajadoresLote) {
      final datosTrabajador = data[trabajador];
      if (datosTrabajador != null) {
        final manana = double.tryParse(datosTrabajador['manana'] ?? '') ?? 0;
        final tarde = double.tryParse(datosTrabajador['tarde'] ?? '') ?? 0;
        total += manana + tarde;
      }
    }
    return total;
  }

  // Función para actualizar los valores en Firebase
  void _actualizarValor(int recoleccionIndex, String trabajador, String campo, String valor) {
    final recoleccion = recolecciones[recoleccionIndex];
    final dataActualizado = Map<String, dynamic>.from(recoleccion.data);
    
    if (!dataActualizado.containsKey(trabajador)) {
      dataActualizado[trabajador] = {
        'manana': '',
        'tarde': ''
      };
    }
    
    dataActualizado[trabajador][campo] = valor;
    
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

  // Widget para crear un campo de entrada numérico
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

  // Widget para cada trabajador con formato acordeón
  Widget _buildTrabajadorWidget(int recoleccionIndex, String trabajador, Map<String, dynamic>? datosTrabajador, String loteId) {
    final isExpanded = expandedTrabajadores['$loteId:$trabajador'] ?? false;
    
    // Valores por defecto si no existen
    final mananaValue = datosTrabajador?['manana'] ?? '';
    final tardeValue = datosTrabajador?['tarde'] ?? '';
    
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
          
          // Panel expandible con los campos simplificados
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Campo para mañana
                  Row(
                    children: [
                      const Expanded(
                        flex: 2,
                        child: Text('Mañana:'),
                      ),
                      Expanded(
                        flex: 3,
                        child: _buildInputField(
                          mananaValue,
                          (value) => _actualizarValor(recoleccionIndex, trabajador, 'manana', value),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Campo para tarde
                  Row(
                    children: [
                      const Expanded(
                        flex: 2,
                        child: Text('Tarde:'),
                      ),
                      Expanded(
                        flex: 3,
                        child: _buildInputField(
                          tardeValue,
                          (value) => _actualizarValor(recoleccionIndex, trabajador, 'tarde', value),
                        ),
                      ),
                    ],
                  ),
                ],
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
    
    // Obtener el nombre del día de la semana en español
    final fecha = DateFormat('yyyy-MM-dd').parse(recoleccion.fecha);
    final diaSemana = DateFormat('EEEE', 'es_ES').format(fecha).capitalize();
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          // Encabezado del panel
          ListTile(
            title: Text('${recoleccion.loteId} - ${recoleccion.fecha} ($diaSemana)'),
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
        tooltip: 'Nueva recolección',
        child: const Icon(Icons.add),
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
                        // Si cambia la finca, actualizar el lote seleccionado
                        final farm = fincas.firstWhere((f) => f.id == value);
                        if (farm.plots.isNotEmpty) {
                          selectedLoteId = farm.plots.first.name;
                        } else {
                          selectedLoteId = null;
                        }
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
              
              const SizedBox(height: 10),
              
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

// Extensión para capitalizar la primera letra
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}