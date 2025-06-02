import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
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
    // Preparar los datos para Firebase (sin el ID en el map)
    final farmData = farm.toMap();
    
    // Actualizar el documento en Firestore
    await _firestore.collection(_collectionName).doc(farm.id).update(farmData);
    
    debugPrint("Finca actualizada exitosamente: ${farm.id}");
  } catch (e) {
    debugPrint("Error al actualizar finca: $e");
    rethrow;
  }
}

  // Eliminar una finca
  Future<void> deleteFarm(String farmId) async {
    try {
      await _firestore.collection(_collectionName).doc(farmId).delete();
    } catch (e) {
      rethrow;
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
      
      final updatedPlots = List<FarmPlot>.from(farm.plots);
      updatedPlots.removeAt(plotIndex);
      
      await _firestore.collection(_collectionName).doc(farmId).update({
        'plots': updatedPlots.map((plot) => plot.toMap()).toList(),
      });
    } catch (e) {
      rethrow;
    }
  }
}