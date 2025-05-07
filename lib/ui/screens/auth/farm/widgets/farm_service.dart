import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:miapp_cafeconecta/models/farm_model.dart';

class FarmService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'farms';

  // Obtener todas las fincas del usuario
  Stream<List<Farm>> getFarmsForUser(String userId) {
    return _firestore
        .collection(_collectionName)
        .where('ownerId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Asegurar que el ID esté presente
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
        .map((doc) {
      if (doc.exists) {
        final data = doc.data()!;
        data['id'] = doc.id;
        return Farm.fromMap(data);
      }
      return null;
    });
  }

  // Crear una nueva finca
  Future<String> createFarm(Farm farm) async {
    final docRef = await _firestore.collection(_collectionName).add(farm.toMap());
    return docRef.id;
  }

  // Actualizar una finca existente
  Future<void> updateFarm(Farm farm) async {
    await _firestore.collection(_collectionName).doc(farm.id).update(farm.toMap());
  }

  // Eliminar una finca
  Future<void> deleteFarm(String farmId) async {
    await _firestore.collection(_collectionName).doc(farmId).delete();
  }

  // Agregar un lote a una finca
  Future<void> addPlotToFarm(String farmId, FarmPlot plot) async {
    // Primero obtenemos la finca actual
    final farmDoc = await _firestore.collection(_collectionName).doc(farmId).get();
    if (!farmDoc.exists) {
      throw Exception('La finca no existe');
    }

    // Convertimos los datos de Firestore
    final farmData = farmDoc.data()!;
    farmData['id'] = farmId;
    
    // Creamos el objeto Farm
    final farm = Farm.fromMap(farmData);
    
    // Agregamos el nuevo lote
    final updatedPlots = List<FarmPlot>.from(farm.plots)..add(plot);
    
    // Actualizamos el documento en Firestore
    await _firestore.collection(_collectionName).doc(farmId).update({
      'plots': updatedPlots.map((plot) => plot.toMap()).toList(),
    });
  }

  // Eliminar un lote de una finca
  Future<void> removePlotFromFarm(String farmId, int plotIndex) async {
    // Primero obtenemos la finca actual
    final farmDoc = await _firestore.collection(_collectionName).doc(farmId).get();
    if (!farmDoc.exists) {
      throw Exception('La finca no existe');
    }

    // Convertimos los datos de Firestore
    final farmData = farmDoc.data()!;
    farmData['id'] = farmId;
    
    // Creamos el objeto Farm
    final farm = Farm.fromMap(farmData);
    
    // Verificamos que el índice sea válido
    if (plotIndex < 0 || plotIndex >= farm.plots.length) {
      throw Exception('Índice de lote inválido');
    }
    
    // Eliminamos el lote
    final updatedPlots = List<FarmPlot>.from(farm.plots);
    updatedPlots.removeAt(plotIndex);
    
    // Actualizamos el documento en Firestore
    await _firestore.collection(_collectionName).doc(farmId).update({
      'plots': updatedPlots.map((plot) => plot.toMap()).toList(),
    });
  }
}