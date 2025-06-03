import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:miapp_cafeconecta/models/recoleccion_model.dart';
import 'package:miapp_cafeconecta/ui/screens/auth/farm/widgets/service/farm_service.dart';
import 'package:miapp_cafeconecta/ui/screens/auth/farm/widgets/service/recoleccion_service.dart';
import 'package:provider/provider.dart';
import 'package:miapp_cafeconecta/controllers/auth_controller.dart';
import 'package:miapp_cafeconecta/models/farm_model.dart';

class RegistrarKilosScreen extends StatefulWidget {
  const RegistrarKilosScreen({super.key});

  @override
  State<RegistrarKilosScreen> createState() => _RegistrarKilosScreenState();
}

class _RegistrarKilosScreenState extends State<RegistrarKilosScreen> {
  final FarmService _farmService = FarmService();
  final RecoleccionService _recoleccionService = RecoleccionService();
  
  List<Farm> fincas = [];
  List<Recoleccion> recolecciones = [];
  Map<String, List<String>> trabajadoresPorLote = {};
  
  String? selectedFarmId;
  String? selectedLoteld;
  String? selectedTrabajador;
  
  bool isLoading = true;
  TextEditingController kilosController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => isLoading = true);
    
    try {
      final authController = Provider.of<AuthController>(context, listen: false);
      final user = authController.currentUser;
      
      if (user == null) throw Exception('Usuario no autenticado');
      
      _farmService.getFarmsForUser(user.uid).listen((farmsData) {
        setState(() {
          fincas = farmsData;
          if (fincas.isNotEmpty && selectedFarmId == null) {
            selectedFarmId = fincas.first.id;
            if (fincas.first.plots.isNotEmpty) {
              selectedLoteld = fincas.first.plots.first.name;
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
      setState(() => isLoading = false);
    }
  }

  Future<void> _cargarTrabajadoresPorLote() async {
    if (selectedFarmId == null) return;
    
    setState(() => isLoading = true);
    
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('trabajadores_lote')
          .where('farmId', isEqualTo: selectedFarmId)
          .get();
      
      Map<String, List<String>> tempTrabajadores = {};
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final loteld = data['loteld'] as String;
        final nombre = data['nombre'] as String;
        
        if (!tempTrabajadores.containsKey(loteld)) {
          tempTrabajadores[loteld] = [];
        }
        tempTrabajadores[loteld]!.add(nombre);
      }
      
      setState(() {
        trabajadoresPorLote = tempTrabajadores;
        isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar trabajadores: $e')),
      );
      setState(() => isLoading = false);
    }
  }

  Future<void> _cargarRecolecciones() async {
    if (selectedFarmId == null) return;
    
    setState(() => isLoading = true);
    
    try {
      final recoleccionesList = await _recoleccionService.getRecoleccionesByFarm(selectedFarmId!);
      setState(() {
        recolecciones = recoleccionesList;
        isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar recolecciones: $e')),
      );
      setState(() => isLoading = false);
    }
  }

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

  Future<void> _guardarTrabajador(String nombre, String loteld) async {
    try {
      await FirebaseFirestore.instance.collection('trabajadores_lote').add({
        'nombre': nombre,
        'loteld': loteld,
        'farmId': selectedFarmId,
        'timestamp': FieldValue.serverTimestamp(),
      });
      
      setState(() {
        if (!trabajadoresPorLote.containsKey(loteld)) {
          trabajadoresPorLote[loteld] = [];
        }
        trabajadoresPorLote[loteld]!.add(nombre);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar trabajador: $e')),
      );
    }
  }

  Future<void> _eliminarTrabajador(String nombre, String loteld) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('trabajadores_lote')
          .where('nombre', isEqualTo: nombre)
          .where('loteld', isEqualTo: loteld)
          .where('farmId', isEqualTo: selectedFarmId)
          .get();
      
      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
      
      setState(() {
        trabajadoresPorLote[loteld]?.remove(nombre);
      });
      
      // Actualizar recolecciones
      for (var recoleccion in recolecciones) {
        if (recoleccion.loteld == loteld) {
          final dataActualizado = Map<String, dynamic>.from(recoleccion.data);
          dataActualizado.remove(nombre);
          final recoleccionActualizada = Recoleccion(
            id: recoleccion.id,
            farmId: recoleccion.farmId,
            loteld: recoleccion.loteld,
            fecha: recoleccion.fecha,
            data: dataActualizado,
            timestamp: recoleccion.timestamp, loteId: null,
          );
          _guardarRecoleccion(recoleccionActualizada);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar trabajador: $e')),
      );
    }
  }

  void _mostrarDialogoAgregarTrabajador() {
    if (selectedFarmId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione una finca primero')),
      );
      return;
    }
    
    final selectedFarm = fincas.firstWhere((farm) => farm.id == selectedFarmId);
    String nombre = '';
    String loteld = selectedFarm.plots.isNotEmpty ? selectedFarm.plots.first.name : '';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar trabajador'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Nombre del trabajador'),
              onChanged: (value) => nombre = value,
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Lote'),
              value: loteld,
              items: selectedFarm.plots.map((plot) {
                return DropdownMenuItem<String>(
                  value: plot.name,
                  child: Text(plot.name),
                );
              }).toList(),
              onChanged: (value) => loteld = value ?? '',
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
              if (nombre.isNotEmpty && loteld.isNotEmpty) {
                if (trabajadoresPorLote[loteld]?.contains(nombre) ?? false) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('El trabajador ya existe en este lote')),
                  );
                } else {
                  _guardarTrabajador(nombre, loteld);
                  Navigator.pop(context);
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Complete todos los campos')),
                );
              }
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoEliminarTrabajador() {
    if (selectedFarmId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione una finca primero')),
      );
      return;
    }
    
    final selectedFarm = fincas.firstWhere((farm) => farm.id == selectedFarmId);
    String loteld = selectedFarm.plots.isNotEmpty ? selectedFarm.plots.first.name : '';
    
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
                  value: loteld,
                  items: selectedFarm.plots.map((plot) {
                    return DropdownMenuItem<String>(
                      value: plot.name,
                      child: Text(plot.name),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => loteld = value ?? ''),
                ),
                const SizedBox(height: 10),
                if (loteld.isNotEmpty)
                  Container(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.3,
                    ),
                    child: trabajadoresPorLote[loteld]?.isEmpty ?? true
                        ? const Center(child: Text('No hay trabajadores en este lote'))
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: trabajadoresPorLote[loteld]?.length ?? 0,
                            itemBuilder: (context, index) {
                              final nombre = trabajadoresPorLote[loteld]![index];
                              return ListTile(
                                title: Text(nombre),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    _eliminarTrabajador(nombre, loteld);
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

  void _mostrarDialogoRecoleccion() {
    if (selectedFarmId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione una finca primero')),
      );
      return;
    }
    
    final selectedFarm = fincas.firstWhere((farm) => farm.id == selectedFarmId);
    String loteld = selectedFarm.plots.isNotEmpty ? selectedFarm.plots.first.name : '';
    String trabajador = trabajadoresPorLote[loteld]?.isNotEmpty == true 
        ? trabajadoresPorLote[loteld]!.first 
        : '';
    String fecha = DateFormat('yyyy-MM-dd').format(DateTime.now());
    kilosController.text = '';
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Registrar Kilos'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Finca: ${selectedFarm.name}', 
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Lote'),
                value: loteld,
                items: selectedFarm.plots.map((plot) {
                  return DropdownMenuItem<String>(
                    value: plot.name,
                    child: Text(plot.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    loteld = value ?? '';
                    trabajador = trabajadoresPorLote[loteld]?.isNotEmpty == true
                        ? trabajadoresPorLote[loteld]!.first
                        : '';
                  });
                },
              ),
              const SizedBox(height: 10),
              if (loteld.isNotEmpty)
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Trabajador'),
                  value: trabajador.isNotEmpty ? trabajador : null,
                  items: trabajadoresPorLote[loteld]?.map((t) {
                    return DropdownMenuItem<String>(
                      value: t,
                      child: Text(t),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => trabajador = value ?? ''),
                ),
              const SizedBox(height: 10),
              InkWell(
                onTap: () {
                  showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  ).then((date) {
                    if (date != null) {
                      setState(() {
                        fecha = DateFormat('yyyy-MM-dd').format(date);
                      });
                    }
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
              const SizedBox(height: 15),
              TextField(
                controller: kilosController,
                decoration: const InputDecoration(
                  labelText: 'Kilos recolectados',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
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
                if (loteld.isNotEmpty && trabajador.isNotEmpty && kilosController.text.isNotEmpty) {
                  // Buscar si ya existe una recolección para esta fecha y lote
                  final recoleccionExistente = recolecciones.firstWhere(
                    (r) => r.loteld == loteld && r.fecha == fecha,
                    orElse: () => Recoleccion(
                      id: '',
                      farmId: '',
                      loteld: '',
                      fecha: '',
                      data: {},
                      timestamp: Timestamp.now(), loteId: null,
                    ),
                  );
                  
                  final dataActualizado = Map<String, dynamic>.from(recoleccionExistente.data);
                  dataActualizado[trabajador] = {'kilos': kilosController.text};
                  
                  final recoleccion = Recoleccion(
                    id: recoleccionExistente.id,
                    farmId: selectedFarmId!,
                    loteld: loteld,
                    fecha: fecha,
                    data: dataActualizado,
                    timestamp: recoleccionExistente.id.isEmpty 
                        ? Timestamp.now() 
                        : recoleccionExistente.timestamp, loteId: null,
                  );
                  
                  _guardarRecoleccion(recoleccion);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Complete todos los campos')),
                  );
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  double _calcularTotal(Map<String, dynamic> data, String loteld) {
    double total = 0;
    final trabajadoresLote = trabajadoresPorLote[loteld] ?? [];
    
    for (var trabajador in trabajadoresLote) {
      final kilos = double.tryParse(data[trabajador]?['kilos'] ?? '') ?? 0;
      total += kilos;
    }
    
    return total;
  }

  Widget _buildHistorialTrabajador(String trabajador) {
    final historial = recolecciones.where((r) => 
        r.data.containsKey(trabajador)).toList();
    
    if (historial.isEmpty) {
      return const ListTile(
        title: Text('No hay registros para este trabajador'),
      );
    }
    
    return ExpansionTile(
      title: Text(trabajador),
      children: historial.map((recoleccion) {
        final kilos = recoleccion.data[trabajador]?['kilos'] ?? '0';
        return ListTile(
          title: Text('Lote: ${recoleccion.loteld}'),
          subtitle: Text('Fecha: ${recoleccion.fecha}'),
          trailing: Text('$kilos kg'),
        );
      }).toList(),
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
            onPressed: _mostrarDialogoAgregarTrabajador,
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
        onPressed: _mostrarDialogoRecoleccion,
        tooltip: 'Nueva recolección',
        child: const Icon(Icons.add),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Selector de finca
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
                        final farm = fincas.firstWhere((f) => f.id == value);
                        if (farm.plots.isNotEmpty) {
                          selectedLoteld = farm.plots.first.name;
                        } else {
                          selectedLoteld = null;
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
                    onChanged: (value) => setState(() {}),
                  ),
                ),
                
                const SizedBox(height: 10),
                
                // Pestañas para cambiar entre vista de recolección e historial
                DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      const TabBar(
                        tabs: [
                          Tab(text: 'Registro Actual'),
                          Tab(text: 'Historial'),
                        ],
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.5,
                        child: TabBarView(
                          children: [
                            // Vista de registro actual
                            recolecciones.isEmpty
                                ? const Center(
                                    child: Text('No hay recolecciones registradas'),
                                  )
                                : ListView.builder(
                                    padding: const EdgeInsets.all(16.0),
                                    itemCount: recolecciones.length,
                                    itemBuilder: (context, index) {
                                      final recoleccion = recolecciones[index];
                                      final total = _calcularTotal(
                                          recoleccion.data, recoleccion.loteld);
                                      final fecha = DateFormat('yyyy-MM-dd')
                                          .parse(recoleccion.fecha);
                                      final diaSemana = DateFormat('EEEE', 'es_ES')
                                          .format(fecha)
                                          .capitalize();
                                      
                                      return Card(
                                        margin: const EdgeInsets.only(bottom: 16),
                                        child: ExpansionTile(
                                          title: Text('${recoleccion.loteld} - ${recoleccion.fecha} ($diaSemana)'),
                                          subtitle: Text('Total: ${total.toStringAsFixed(1)} kg'),
                                          children: (trabajadoresPorLote[recoleccion.loteld] ?? [])
                                              .where((t) => t.toLowerCase().contains(
                                                  searchController.text.toLowerCase()))
                                              .map((trabajador) {
                                                final kilos = recoleccion.data[trabajador]?['kilos'] ?? '0';
                                                return ListTile(
                                                  title: Text(trabajador),
                                                  trailing: Text('$kilos kg'),
                                                );
                                              }).toList(),
                                        ),
                                      );
                                    },
                                  ),
                            
                            // Vista de historial
                            
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
