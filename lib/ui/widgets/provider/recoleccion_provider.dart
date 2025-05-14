import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:miapp_cafeconecta/models/farm_model.dart';
import 'package:miapp_cafeconecta/models/recoleccion_model.dart';
import 'package:miapp_cafeconecta/ui/screens/auth/farm/widgets/service/farm_service.dart';
import 'package:miapp_cafeconecta/ui/screens/auth/farm/widgets/service/recoleccion_service.dart';
import 'package:miapp_cafeconecta/ui/screens/auth/farm/widgets/service/trabajador_service.dart';

class RecoleccionProvider extends ChangeNotifier {
  final FarmService _farmService = FarmService();
  final RecoleccionService _recoleccionService = RecoleccionService();
  final TrabajadorService _trabajadorService = TrabajadorService();
  
  List<Farm> _fincas = [];
  List<Recoleccion> _recolecciones = [];
  Map<String, List<String>> _trabajadoresPorLote = {};
  
  String? _selectedFarmId;
  String? _selectedLoteId;
  
  bool _isLoading = true;
  String _searchQuery = "";
  
  // Map para almacenar las expansiones actuales de cada panel
  final Map<int, bool> _expandedPanels = {};
  final Map<String, bool> _expandedTrabajadores = {};
  
  // Getters
  List<Farm> get fincas => _fincas;
  List<Recoleccion> get recolecciones => _recolecciones;
  Map<String, List<String>> get trabajadoresPorLote => _trabajadoresPorLote;
  String? get selectedFarmId => _selectedFarmId;
  String? get selectedLoteId => _selectedLoteId;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  Map<int, bool> get expandedPanels => _expandedPanels;
  Map<String, bool> get expandedTrabajadores => _expandedTrabajadores;
  
  // Setters
  set searchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }
  
  // Inicializar datos para un usuario específico
  void initData(String userId) {
    _cargarFincas(userId);
  }
  
  // Cargar fincas del usuario
  void _cargarFincas(String userId) {
    _setLoading(true);
    
    _farmService.getFarmsForUser(userId).listen((farmsData) {
      _fincas = farmsData;
      
      if (_fincas.isNotEmpty && _selectedFarmId == null) {
        _selectedFarmId = _fincas.first.id;
        
        // Seleccionar el primer lote por defecto si existe
        if (_fincas.first.plots.isNotEmpty) {
          _selectedLoteId = _fincas.first.plots.first.name;
        }
      }
      
      _cargarRecolecciones();
      _cargarTrabajadoresPorLote();
      
      notifyListeners();
    });
  }
  
  // Cambiar finca seleccionada
  void cambiarFincaSeleccionada(String? farmId) {
    if (farmId != null && farmId != _selectedFarmId) {
      _selectedFarmId = farmId;
      
      // Si cambia la finca, actualizar el lote seleccionado
      final farm = _fincas.firstWhere((f) => f.id == farmId, orElse: () => _fincas.first);
      if (farm.plots.isNotEmpty) {
        _selectedLoteId = farm.plots.first.name;
      } else {
        _selectedLoteId = null;
      }
      
      _cargarRecolecciones();
      _cargarTrabajadoresPorLote();
      notifyListeners();
    }
  }
  
  // Método para cargar trabajadores específicos por lote
  Future<void> _cargarTrabajadoresPorLote() async {
    if (_selectedFarmId == null) return;
    
    _setLoading(true);
    
    try {
      _trabajadoresPorLote = await _trabajadorService.getTrabajadoresPorLote(_selectedFarmId!);
      
      // Inicializar expansión de trabajadores para todos los lotes
      for (var loteId in _trabajadoresPorLote.keys) {
        for (var trabajador in _trabajadoresPorLote[loteId] ?? []) {
          _expandedTrabajadores['$loteId:$trabajador'] = false;
        }
      }
      
      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      rethrow;
    }
  }
  
  // Cargar recolecciones según la finca seleccionada
  Future<void> _cargarRecolecciones() async {
    if (_selectedFarmId == null) return;
    
    _setLoading(true);
    
    try {
      final recoleccionesList = await _recoleccionService.getRecoleccionesByFarm(_selectedFarmId!);
      
      _recolecciones = recoleccionesList;
      
      // Inicializar los estados de expansión
      for (int i = 0; i < recoleccionesList.length; i++) {
        _expandedPanels[i] = i == 0; // El primer panel estará expandido
      }
      
      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      rethrow;
    }
  }
  
  // Toggle panel expandido
  void toggleExpandedPanel(int index) {
    _expandedPanels[index] = !(_expandedPanels[index] ?? false);
    notifyListeners();
  }
  
  // Toggle trabajador expandido
  void toggleExpandedTrabajador(String loteId, String trabajador) {
    final key = '$loteId:$trabajador';
    _expandedTrabajadores[key] = !(_expandedTrabajadores[key] ?? false);
    notifyListeners();
  }
  
  // Guardar recolección
  Future<void> guardarRecoleccion(Recoleccion recoleccion) async {
    try {
      await _recoleccionService.saveRecoleccion(recoleccion);
      
      // Si la recolección no tiene ID (es nueva), cargar recolecciones de nuevo
      if (recoleccion.id.isEmpty) {
        await _cargarRecolecciones();
      } else {
        // Actualizar la recolección existente en la lista local
        final index = _recolecciones.indexWhere((r) => r.id == recoleccion.id);
        if (index >= 0) {
          _recolecciones[index] = recoleccion;
          notifyListeners();
        }
      }
    } catch (e) {
      rethrow;
    }
  }
  
  // Crear nueva recolección
  Future<void> crearRecoleccion(String loteId, String fecha) async {
    if (_selectedFarmId == null) return;
    
    // Usar solo los trabajadores asociados a este lote
    final trabajadoresLote = _trabajadoresPorLote[loteId] ?? [];
    
    // Nuevo formato de datos simplificado: solo mañana y tarde por trabajador
    final Map<String, Map<String, String>> data = {};
    for (var t in trabajadoresLote) {
      data[t] = {
        'manana': '',
        'tarde': ''
      };
    }
    
    final nuevaRecoleccion = Recoleccion(
      id: '',
      farmId: _selectedFarmId!,
      loteId: loteId,
      fecha: fecha,
      data: data,
      timestamp: Timestamp.now(),
    );
    
    await guardarRecoleccion(nuevaRecoleccion);
  }
  
  // Actualizar valor de recolección (kilos)
  Future<void> actualizarValor(int recoleccionIndex, String trabajador, String campo, String valor) async {
    if (recoleccionIndex < 0 || recoleccionIndex >= _recolecciones.length) return;
    
    final recoleccion = _recolecciones[recoleccionIndex];
    final Map<String, dynamic> dataActualizado = Map<String, dynamic>.from(recoleccion.data);
    
    if (!dataActualizado.containsKey(trabajador)) {
      dataActualizado[trabajador] = {
        'manana': '',
        'tarde': ''
      };
    }
    
    // Asegúrate de que existe el trabajador y el campo
    if (dataActualizado[trabajador] != null) {
      dataActualizado[trabajador][campo] = valor;
    }
    
    final recoleccionActualizada = Recoleccion(
      id: recoleccion.id,
      farmId: recoleccion.farmId,
      loteId: recoleccion.loteId,
      fecha: recoleccion.fecha,
      data: dataActualizado,
      timestamp: recoleccion.timestamp, // Agregar valor predeterminado
    );
    
    _recolecciones[recoleccionIndex] = recoleccionActualizada;
    notifyListeners();
    
    // Debounce para no hacer demasiadas peticiones a Firebase
    await Future.delayed(const Duration(milliseconds: 500));
    await guardarRecoleccion(recoleccionActualizada);
  }
  
  // Agregar trabajador
  Future<void> agregarTrabajador(String nombre, String loteId) async {
    if (_selectedFarmId == null) return;
    
    try {
      await _trabajadorService.saveTrabajador(nombre, loteId, _selectedFarmId!);
      
      // Actualizar la lista local
      if (!_trabajadoresPorLote.containsKey(loteId)) {
        _trabajadoresPorLote[loteId] = [];
      }
      _trabajadoresPorLote[loteId]?.add(nombre);
      _expandedTrabajadores['$loteId:$nombre'] = false;
      
      // Actualizar las recolecciones existentes para este lote
      for (var i = 0; i < _recolecciones.length; i++) {
        final recoleccion = _recolecciones[i];
        if (recoleccion.loteId == loteId) {
          final Map<String, dynamic> dataActualizado = Map<String, dynamic>.from(recoleccion.data);
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
          
          await guardarRecoleccion(recoleccionActualizada);
        }
      }
      
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
  
  // Eliminar trabajador
  Future<void> eliminarTrabajador(String nombre, String loteId) async {
    if (_selectedFarmId == null) return;
    
    try {
      await _trabajadorService.deleteTrabajador(nombre, loteId, _selectedFarmId!);
      
      // Actualizar la lista local
      _trabajadoresPorLote[loteId]?.remove(nombre);
      _expandedTrabajadores.remove('$loteId:$nombre');
      
      // Actualizar recolecciones afectadas
      for (int i = 0; i < _recolecciones.length; i++) {
        if (_recolecciones[i].loteId == loteId) {
          final Map<String, dynamic> dataActualizado = Map<String, dynamic>.from(_recolecciones[i].data);
          dataActualizado.remove(nombre);
          
          final recoleccionActualizada = Recoleccion(
            id: _recolecciones[i].id,
            farmId: _recolecciones[i].farmId,
            loteId: _recolecciones[i].loteId,
            fecha: _recolecciones[i].fecha,
            data: dataActualizado,
            timestamp: _recolecciones[i].timestamp,
          );
          
          _recolecciones[i] = recoleccionActualizada;
          await guardarRecoleccion(recoleccionActualizada);
        }
      }
      
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
  
  // Filtrar trabajadores según la búsqueda y el lote seleccionado
  List<String> filtrarTrabajadores(String loteId) {
    final trabajadoresLote = _trabajadoresPorLote[loteId] ?? [];
    
    if (_searchQuery.isEmpty) {
      return trabajadoresLote;
    }
    return trabajadoresLote
        .where((t) => t.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }
  
  // Calcular total para un trabajador
  String calcularTotalTrabajador(Map<String, dynamic>? datosTrabajador) {
    if (datosTrabajador == null) return "0.0";
    
    double total = 0;
    
    final manana = double.tryParse(datosTrabajador['manana'] ?? '') ?? 0;
    final tarde = double.tryParse(datosTrabajador['tarde'] ?? '') ?? 0;
    total = manana + tarde;
    
    return total.toStringAsFixed(1);
  }
  
  // Calcular total general para todos los trabajadores
  double calcularTotalGeneral(Map<String, dynamic> data, String loteId) {
    double total = 0;
    final trabajadoresLote = _trabajadoresPorLote[loteId] ?? [];
    
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
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}