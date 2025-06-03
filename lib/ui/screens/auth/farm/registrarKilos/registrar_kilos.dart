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

  final Map<String, bool> _expandedTrabajadores = {};
  
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
    List<String> trabajadoresGenerales = [];
    
    // Primero obtenemos todos los trabajadores
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final loteld = data['loteld'] as String;
      final nombre = data['nombre'] as String;
      
      if (loteld == 'general') {
        // Los trabajadores generales se agregan a todos los lotes
        trabajadoresGenerales.add(nombre);
      } else {
        // Trabajadores específicos de lote
        if (!tempTrabajadores.containsKey(loteld)) {
          tempTrabajadores[loteld] = [];
        }
        tempTrabajadores[loteld]!.add(nombre);
      }
    }
    
    // Ahora agregamos los trabajadores generales a todos los lotes de la finca
    if (selectedFarmId != null) {
      final selectedFarm = fincas.firstWhere((farm) => farm.id == selectedFarmId);
      
      for (var plot in selectedFarm.plots) {
        if (!tempTrabajadores.containsKey(plot.name)) {
          tempTrabajadores[plot.name] = [];
        }
        
        // Agregar trabajadores generales a este lote (evitando duplicados)
        for (var trabajadorGeneral in trabajadoresGenerales) {
          if (!tempTrabajadores[plot.name]!.contains(trabajadorGeneral)) {
            tempTrabajadores[plot.name]!.add(trabajadorGeneral);
          }
        }
      }
    }
    
    // También mantenemos la lista general
    tempTrabajadores['general'] = trabajadoresGenerales;
    
    setState(() {
      trabajadoresPorLote = tempTrabajadores;
      
      // Inicializar estado expandido para todos los trabajadores
      for (var loteld in tempTrabajadores.keys) {
        for (var trabajador in tempTrabajadores[loteld] ?? []) {
          _expandedTrabajadores["$loteld:$trabajador"] = false;
        }
      }
      
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
    // Si el trabajador se elimina desde 'general', lo eliminamos de todos los lotes
    if (loteld == 'general') {
      // Eliminar de la base de datos
      final querySnapshot = await FirebaseFirestore.instance
          .collection('trabajadores_lote')
          .where('nombre', isEqualTo: nombre)
          .where('farmId', isEqualTo: selectedFarmId)
          .where('loteld', isEqualTo: 'general')
          .get();
      
      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
      
      // Eliminar de todos los lotes en el estado local
      setState(() {
        trabajadoresPorLote.forEach((loteName, trabajadores) {
          trabajadores.remove(nombre);
          _expandedTrabajadores.remove('$loteName:$nombre');
        });
      });
    } else {
      // Eliminar solo de un lote específico (si fuera el caso)
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
        _expandedTrabajadores.remove('$loteld:$nombre');
      });
    }
    
    // Actualizar recolecciones existentes eliminando datos del trabajador
    for (var recoleccion in recolecciones) {
      if (recoleccion.data.containsKey(nombre)) {
        final dataActualizado = Map<String, dynamic>.from(recoleccion.data);
        dataActualizado.remove(nombre);

        final recoleccionActualizada = Recoleccion(
          id: recoleccion.id,
          farmId: recoleccion.farmId,
          loteld: recoleccion.loteld,
          fecha: recoleccion.fecha,
          data: dataActualizado,
          timestamp: recoleccion.timestamp, 
          loteId: null,
        );

        await _guardarRecoleccion(recoleccionActualizada);
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Trabajador "$nombre" eliminado correctamente'),
        backgroundColor: Colors.green,
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error al eliminar trabajador: $e')),
    );
  }
}

void _mostrarDialogoEliminarTrabajador() {
  if (selectedFarmId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Seleccione una finca primero')),
    );
    return;
  }
  
  // Obtener todos los trabajadores únicos de todos los lotes
  Set<String> todosLosTrabajadores = {};
  trabajadoresPorLote.forEach((loteld, trabajadores) {
    todosLosTrabajadores.addAll(trabajadores);
  });
  
  if (todosLosTrabajadores.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No hay trabajadores para eliminar')),
    );
    return;
  }
  
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.person_remove,
              color: Colors.red[700],
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Eliminar trabajador',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selecciona el trabajador que deseas eliminar:',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.4,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: todosLosTrabajadores.length,
                itemBuilder: (context, index) {
                  final nombre = todosLosTrabajadores.elementAt(index);
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.red[100],
                        child: Icon(
                          Icons.person,
                          color: Colors.red[700],
                          size: 20,
                        ),
                      ),
                      title: Text(
                        nombre,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: const Text(
                        'Disponible en todos los lotes',
                        style: TextStyle(fontSize: 12),
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          Icons.delete_forever,
                          color: Colors.red[600],
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          _confirmarEliminacionTrabajador(nombre);
                        },
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _confirmarEliminacionTrabajador(nombre);
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
          child: Text(
            'Cerrar',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      ],
    ),
  );
}

void _confirmarEliminacionTrabajador(String nombre) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Icon(Icons.warning, color: Colors.red[600]),
          const SizedBox(width: 8),
          const Text('Confirmar eliminación'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¿Estás seguro de que deseas eliminar al trabajador "$nombre"?',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red[200]!),
            ),
            child: const Text(
              '⚠️ Esta acción eliminará:\n\n'
              '• El trabajador de todos los lotes\n'
              '• Todos sus registros de recolección\n'
              '• Esta acción NO se puede deshacer',
              style: TextStyle(
                fontSize: 14,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
            _eliminarTrabajador(nombre, 'general');
          },
          child: const Text('Eliminar'),
        ),
      ],
    ),
  );
}

  void _mostrarDialogoAgregarTrabajador() {
  if (selectedFarmId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Seleccione una finca primero')),
    );
    return;
  }
  
  TextEditingController nombreController = TextEditingController();
  
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.person_add,
              color: Colors.green[700],
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Agregar trabajador',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ingresa el nombre del trabajador. Podrás asignarlo a cualquier lote al registrar kilos.',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: nombreController,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: 'Nombre del trabajador',
              hintText: 'Ej: Juan Pérez',
              prefixIcon: const Icon(Icons.person),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onSubmitted: (value) {
              if (value.trim().isNotEmpty) {
                _guardarTrabajadorGeneral(value.trim());
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            nombreController.dispose();
            Navigator.pop(context);
          },
          child: Text(
            'Cancelar',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            final nombre = nombreController.text.trim();
            if (nombre.isNotEmpty) {
              // Verificar si el trabajador ya existe
              bool trabajadorExiste = false;
              for (var trabajadores in trabajadoresPorLote.values) {
                if (trabajadores.contains(nombre)) {
                  trabajadorExiste = true;
                  break;
                }
              }
              
              if (trabajadorExiste) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('El trabajador "$nombre" ya existe'),
                    backgroundColor: Colors.orange,
                  ),
                );
              } else {
                _guardarTrabajadorGeneral(nombre);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Trabajador "$nombre" agregado correctamente'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Por favor ingrese un nombre'),
                  backgroundColor: Colors.red,
                ),
              );
            }
            nombreController.dispose();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[700],
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Agregar'),
        ),
      ],
    ),
  );
}

  // Nuevo método para guardar trabajador de forma general (disponible para todos los lotes)
Future<void> _guardarTrabajadorGeneral(String nombre) async {
  try {
    await FirebaseFirestore.instance.collection('trabajadores_lote').add({
      'nombre': nombre,
      'loteld': 'general', // Lo guardamos como general para que esté disponible en todos los lotes
      'farmId': selectedFarmId,
      'timestamp': FieldValue.serverTimestamp(),
    });
    
    // Agregar el trabajador a todos los lotes de la finca actual
    if (selectedFarmId != null) {
      final selectedFarm = fincas.firstWhere((farm) => farm.id == selectedFarmId);
      
      // Agregar a cada lote existente
      for (var plot in selectedFarm.plots) {
        if (!trabajadoresPorLote.containsKey(plot.name)) {
          trabajadoresPorLote[plot.name] = [];
        }
        if (!trabajadoresPorLote[plot.name]!.contains(nombre)) {
          trabajadoresPorLote[plot.name]!.add(nombre);
        }
      }
      
      // También agregar a 'general' por si acaso
      if (!trabajadoresPorLote.containsKey('general')) {
        trabajadoresPorLote['general'] = [];
      }
      trabajadoresPorLote['general']!.add(nombre);
      
      setState(() {});
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error al guardar trabajador: $e')),
    );
  }
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
              onPressed: () async {
                if (loteld.isNotEmpty && trabajador.isNotEmpty && kilosController.text.isNotEmpty) {
                  await _guardarRegistroKilos(fecha, loteld, trabajador, kilosController.text);
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

  // Método corregido para guardar registro de kilos
  Future<void> _guardarRegistroKilos(String fecha, String loteld, String trabajador, String kilos) async {
    try {
      // Buscar si ya existe una recolección para esta fecha y lote
      final existingRecoleccion = recolecciones.firstWhere(
        (r) => r.loteld == loteld && r.fecha == fecha,
        orElse: () => Recoleccion(
          id: '',
          farmId: selectedFarmId!,
          loteld: loteld,
          fecha: fecha,
          data: {},
          timestamp: Timestamp.now(),
          loteId: null,
        ),
      );
      
      // Crear o actualizar los datos
      final dataActualizado = Map<String, dynamic>.from(existingRecoleccion.data);
      dataActualizado[trabajador] = {'kilos': kilos};
      
      final recoleccion = Recoleccion(
        id: existingRecoleccion.id,
        farmId: selectedFarmId!,
        loteld: loteld,
        fecha: fecha,
        data: dataActualizado,
        timestamp: existingRecoleccion.id.isEmpty 
            ? Timestamp.now() 
            : existingRecoleccion.timestamp,
        loteId: null,
      );
      
      // Guardar en Firestore
      await _recoleccionService.saveRecoleccion(recoleccion);
      
      // Recargar datos
      await _cargarRecolecciones();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registrado: $trabajador - $kilos kg en $loteld'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Método para obtener solo el registro actual (hoy)
  List<Recoleccion> _getRegistroActual() {
    final hoy = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return recolecciones.where((r) => r.fecha == hoy).toList();
  }

  // Método para obtener el historial (excluyendo hoy)
  List<Recoleccion> _getHistorial() {
    final hoy = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return recolecciones.where((r) => r.fecha != hoy).toList();
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