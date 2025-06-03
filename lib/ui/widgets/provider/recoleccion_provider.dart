import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  String? _selectedLoteld;
  bool _isLoading = true;
  String _searchQuery = "";
  final Map<int, bool> _expandedPanels = {};
  final Map<String, bool> _expandedTrabajadores = {};

  // Getters
  List<Farm> get fincas => _fincas;
  List<Recoleccion> get recolecciones => _recolecciones;
  Map<String, List<String>> get trabajadoresPorLote => _trabajadoresPorLote;
  String? get selectedFarmId => _selectedFarmId;
  String? get selectedLoteld => _selectedLoteld;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  Map<int, bool> get expandedPanels => _expandedPanels;
  Map<String, bool> get expandedTrabajadores => _expandedTrabajadores;

  set searchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  void initData(String userId) {
    _cargarFincas(userId);
  }

  void _cargarFincas(String userId) {
    _setLoading(true);
    _farmService.getFarmsForUser(userId).listen((farmsData) {
      _fincas = farmsData;
      if (_fincas.isNotEmpty && _selectedFarmId == null) {
        _selectedFarmId = _fincas.first.id;
        if (_fincas.first.plots.isNotEmpty) {
          _selectedLoteld = _fincas.first.plots.first.name;
        }
      }
      _cargarRecolecciones();
      _cargarTrabajadoresPorLote();
      notifyListeners();
    });
  }

  void cambiarFincaSeleccionada(String? farmId) {
    if (farmId != null && farmId != _selectedFarmId) {
      _selectedFarmId = farmId;
      final farm = _fincas.firstWhere((f) => f.id == farmId, orElse: () => _fincas.first);
      if (farm.plots.isNotEmpty) {
        _selectedLoteld = farm.plots.first.name;
      } else {
        _selectedLoteld = null;
      }
      _cargarRecolecciones();
      _cargarTrabajadoresPorLote();
      notifyListeners();
    }
  }

  Future<void> _cargarTrabajadoresPorLote() async {
    if (_selectedFarmId == null) return;
    _setLoading(true);
    try {
      _trabajadoresPorLote = await _trabajadorService.getTrabajadoresPorLote(_selectedFarmId!);
      for (var loteld in _trabajadoresPorLote.keys) {
        for (var trabajador in _trabajadoresPorLote[loteld] ?? []) {
          _expandedTrabajadores["$loteld:$trabajador"] = false;
        }
      }
      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      rethrow;
    }
  }

  Future<void> _cargarRecolecciones() async {
    if (_selectedFarmId == null) return;
    _setLoading(true);
    try {
      final recoleccionesList = await _recoleccionService.getRecoleccionesByFarm(_selectedFarmId!);
      _recolecciones = recoleccionesList;
      for (int i = 0; i < recoleccionesList.length; i++) {
        _expandedPanels[i] = i == 0;
      }
      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      rethrow;
    }
  }

  void toggleExpandedPanel(int index) {
    _expandedPanels[index] = !(_expandedPanels[index] ?? false);
    notifyListeners();
  }

  void toggleExpandedTrabajador(String loteld, String trabajador) {
    final key = '$loteld:$trabajador';
    _expandedTrabajadores[key] = !(_expandedTrabajadores[key] ?? false);
    notifyListeners();
  }

  Future<void> guardarRecoleccion(Recoleccion recoleccion) async {
    try {
      await _recoleccionService.saveRecoleccion(recoleccion);
      if (recoleccion.id.isEmpty) {
        await _cargarRecolecciones();
      } else {
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

    if (dataActualizado[trabajador] != null) {
      dataActualizado[trabajador][campo] = valor;
    }

    final recoleccionActualizada = Recoleccion(
      id: recoleccion.id,
      farmId: recoleccion.farmId,
      loteld: recoleccion.loteld,
      fecha: recoleccion.fecha,
      data: dataActualizado,
      timestamp: recoleccion.timestamp, loteId: null,
    );

    _recolecciones[recoleccionIndex] = recoleccionActualizada;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));
    await guardarRecoleccion(recoleccionActualizada);
  }

  Future<void> agregarTrabajador(String nombre) async {
    if (_selectedFarmId == null) return;

    try {
      await _trabajadorService.saveTrabajador(nombre, _selectedFarmId!);

      if (!_trabajadoresPorLote.containsKey('general')) {
        _trabajadoresPorLote['general'] = [];
      }
      _trabajadoresPorLote['general']?.add(nombre);
      _expandedTrabajadores["general:$nombre"] = false;

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> eliminarTrabajador(String nombre) async {
    if (_selectedFarmId == null) return;

    try {
      await _trabajadorService.deleteTrabajador(nombre, _selectedFarmId!);

      _trabajadoresPorLote.forEach((loteld, trabajadores) {
        trabajadores.remove(nombre);
        _expandedTrabajadores.remove('$loteld:$nombre');
      });

      for (int i = 0; i < _recolecciones.length; i++) {
        final Map<String, dynamic> dataActualizado = Map<String, dynamic>.from(_recolecciones[i].data);
        dataActualizado.remove(nombre);

        final recoleccionActualizada = Recoleccion(
          id: _recolecciones[i].id,
          farmId: _recolecciones[i].farmId,
          loteld: _recolecciones[i].loteld,
          fecha: _recolecciones[i].fecha,
          data: dataActualizado,
          timestamp: _recolecciones[i].timestamp, loteId: null,
        );

        await guardarRecoleccion(recoleccionActualizada);
      }

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  List<String> filtrarTrabajadores(String loteld) {
    final trabajadoresLote = _trabajadoresPorLote[loteld] ?? [];
    if (_searchQuery.isEmpty) {
      return trabajadoresLote;
    }
    return trabajadoresLote
        .where((t) => t.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  String calcularTotalTrabajador(Map<String, dynamic>? datosTrabajador) {
    if (datosTrabajador == null) return "0.0";

    double total = 0;
    final manana = double.tryParse(datosTrabajador['manana'] ?? '') ?? 0;
    final tarde = double.tryParse(datosTrabajador['tarde'] ?? '') ?? 0;
    total = manana + tarde;

    return total.toStringAsFixed(1);
  }

  double calcularTotalGeneral(Map<String, dynamic> data, String loteld) {
    double total = 0;
    final trabajadoresLote = _trabajadoresPorLote[loteld] ?? [];

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

  filtrarHistorial(String? selectedFarmId, String loteld, String trabajador) {}
}
