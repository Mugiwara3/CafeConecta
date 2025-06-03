import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:miapp_cafeconecta/models/farm_model.dart';

class FarmService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'farms';

  // Obtener todas las fincas del usuario actual
  Stream<List<Farm>> getFarmsForUser(String userId) {
    return _firestore
        .collection(_collectionName)
        .where('ownerId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Farm.fromMap(data);
      }).toList();
    });
  }

  // Obtener una finca específica
  Stream<Farm?> getFarm(String farmId) {
    return _firestore
        .collection(_collectionName)
        .doc(farmId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        return null;
      }
      final data = snapshot.data()!;
      data['id'] = snapshot.id;
      return Farm.fromMap(data);
    });
  }

  // Agregar una nueva finca
  Future<String> addFarm(Farm farm) async {
    try {
      // Removemos el ID ya que Firestore lo generará
      final farmData = farm.toMap();
      
      final docRef = await _firestore.collection(_collectionName).add(farmData);
      return docRef.id;
    } catch (e) {
      rethrow;
    }
  }

  // Actualizar una finca existente
  Future<void> updateFarm(Farm farm) async {
    try {
      await _firestore.collection(_collectionName).doc(farm.id).update(farm.toMap());
    } catch (e) {
      rethrow;
    }
  }

  // Eliminar una finca
  Future<void> deleteFarm(String farmId) async {
    try {
      // Antes de eliminar la finca, eliminamos todos los datos relacionados
      await _deleteRelatedData(farmId);
      
      // Luego eliminamos la finca
      await _firestore.collection(_collectionName).doc(farmId).delete();
    } catch (e) {
      rethrow;
    }
  }

  // Método privado para eliminar datos relacionados con la finca
  Future<void> _deleteRelatedData(String farmId) async {
    try {
      // Eliminar recolecciones relacionadas
      final recoleccionesSnapshot = await _firestore
          .collection('recolecciones')
          .where('farmId', isEqualTo: farmId)
          .get();
      
      for (var doc in recoleccionesSnapshot.docs) {
        await doc.reference.delete();
      }

      // Eliminar trabajadores relacionados
      final trabajadoresSnapshot = await _firestore
          .collection('trabajadores')
          .where('farmId', isEqualTo: farmId)
          .get();
      
      for (var doc in trabajadoresSnapshot.docs) {
        await doc.reference.delete();
      }

      // Eliminar trabajadores por lote relacionados
      final trabajadoresLoteSnapshot = await _firestore
          .collection('trabajadores_lote')
          .where('farmId', isEqualTo: farmId)
          .get();
      
      for (var doc in trabajadoresLoteSnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      print('Error eliminando datos relacionados: $e');
      // Continuamos con la eliminación de la finca aunque haya errores
    }
  }

  // Agregar un lote a una finca
  Future<void> addPlotToFarm(String farmId, FarmPlot plot) async {
    try {
      final farmDoc = await _firestore.collection(_collectionName).doc(farmId).get();
      if (!farmDoc.exists) {
        throw Exception('La finca no existe');
      }

      final farmData = farmDoc.data()!;
      farmData['id'] = farmId;
      
      final farm = Farm.fromMap(farmData);
      
      final updatedPlots = List<FarmPlot>.from(farm.plots)..add(plot);
      
      await _firestore.collection(_collectionName).doc(farmId).update({
        'plots': updatedPlots.map((plot) => plot.toMap()).toList(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Actualizar un lote específico de una finca
  Future<void> updatePlot(String farmId, int plotIndex, FarmPlot updatedPlot) async {
    try {
      final farmDoc = await _firestore.collection(_collectionName).doc(farmId).get();
      if (!farmDoc.exists) {
        throw Exception('La finca no existe');
      }

      final farmData = farmDoc.data()!;
      farmData['id'] = farmId;
      
      final farm = Farm.fromMap(farmData);
      
      if (plotIndex < 0 || plotIndex >= farm.plots.length) {
        throw Exception('Índice de lote inválido');
      }
      
      final updatedPlots = List<FarmPlot>.from(farm.plots);
      updatedPlots[plotIndex] = updatedPlot;
      
      await _firestore.collection(_collectionName).doc(farmId).update({
        'plots': updatedPlots.map((plot) => plot.toMap()).toList(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Eliminar un lote de una finca
  Future<void> removePlotFromFarm(String farmId, int plotIndex) async {
    try {
      final farmDoc = await _firestore.collection(_collectionName).doc(farmId).get();
      if (!farmDoc.exists) {
        throw Exception('La finca no existe');
      }

      final farmData = farmDoc.data()!;
      farmData['id'] = farmId;
      
      final farm = Farm.fromMap(farmData);
      
      if (plotIndex < 0 || plotIndex >= farm.plots.length) {
        throw Exception('Índice de lote inválido');
      }

      // Obtener el nombre del lote que se va a eliminar
      final plotToDelete = farm.plots[plotIndex];
      
      // Eliminar datos relacionados con este lote
      await _deletePlotRelatedData(farmId, plotToDelete.name);
      
      final updatedPlots = List<FarmPlot>.from(farm.plots);
      updatedPlots.removeAt(plotIndex);
      
      await _firestore.collection(_collectionName).doc(farmId).update({
        'plots': updatedPlots.map((plot) => plot.toMap()).toList(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Método privado para eliminar datos relacionados con un lote específico
  Future<void> _deletePlotRelatedData(String farmId, String plotName) async {
    try {
      // Eliminar recolecciones relacionadas con este lote
      final recoleccionesSnapshot = await _firestore
          .collection('recolecciones')
          .where('farmId', isEqualTo: farmId)
          .where('loteld', isEqualTo: plotName)
          .get();
      
      for (var doc in recoleccionesSnapshot.docs) {
        await doc.reference.delete();
      }

      // Eliminar trabajadores asignados a este lote específico
      final trabajadoresLoteSnapshot = await _firestore
          .collection('trabajadores_lote')
          .where('farmId', isEqualTo: farmId)
          .where('loteld', isEqualTo: plotName)
          .get();
      
      for (var doc in trabajadoresLoteSnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      print('Error eliminando datos relacionados del lote: $e');
      // Continuamos con la eliminación del lote aunque haya errores
    }
  }

  // Obtener estadísticas de una finca
  Future<Map<String, dynamic>> getFarmStatistics(String farmId) async {
    try {
      final farmDoc = await _firestore.collection(_collectionName).doc(farmId).get();
      if (!farmDoc.exists) {
        throw Exception('La finca no existe');
      }

      final farmData = farmDoc.data()!;
      farmData['id'] = farmId;
      final farm = Farm.fromMap(farmData);

      // Obtener estadísticas de recolección
      final recoleccionesSnapshot = await _firestore
          .collection('recolecciones')
          .where('farmId', isEqualTo: farmId)
          .get();

      double totalKilosRecolectados = 0;
      int totalRecolecciones = recoleccionesSnapshot.docs.length;

      for (var doc in recoleccionesSnapshot.docs) {
        final data = doc.data();
        final recoleccionData = data['data'] as Map<String, dynamic>? ?? {};
        
        for (var trabajadorData in recoleccionData.values) {
          if (trabajadorData is Map<String, dynamic>) {
            final kilos = double.tryParse(trabajadorData['kilos']?.toString() ?? '0') ?? 0;
            totalKilosRecolectados += kilos;
          }
        }
      }

      return {
        'totalHectares': farm.hectares,
        'hectaresCafe': farm.coffeeHectares,
        'totalLotes': farm.plots.length,
        'altitudPromedio': farm.altitude,
        'totalKilosRecolectados': totalKilosRecolectados,
        'totalRecolecciones': totalRecolecciones,
        'promedioKilosPorHectarea': farm.coffeeHectares > 0 
            ? totalKilosRecolectados / farm.coffeeHectares 
            : 0,
      };
    } catch (e) {
      rethrow;
    }
  }
}