import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:miapp_cafeconecta/models/farm_model.dart';

class PlotService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'farms';

  // Obtener todos los lotes de una finca
  Future<List<FarmPlot>> getPlotsForFarm(String farmId) async {
    try {
      final farmDoc = await _firestore.collection(_collectionName).doc(farmId).get();
      if (!farmDoc.exists) {
        throw Exception('La finca no existe');
      }

      final farmData = farmDoc.data()!;
      farmData['id'] = farmId;
      
      final farm = Farm.fromMap(farmData);
      return farm.plots;
    } catch (e) {
      rethrow;
    }
  }

  // Agregar un lote a una finca
  Future<void> addPlotToFarm(String farmId, FarmPlot plot) async {
    try {
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
    } catch (e) {
      rethrow;
    }
  }

  // Actualizar un lote existente
  Future<void> updatePlot(String farmId, int plotIndex, FarmPlot updatedPlot) async {
    try {
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
      
      // Actualizamos el lote
      final updatedPlots = List<FarmPlot>.from(farm.plots);
      updatedPlots[plotIndex] = updatedPlot;
      
      // Actualizamos el documento en Firestore
      await _firestore.collection(_collectionName).doc(farmId).update({
        'plots': updatedPlots.map((plot) => plot.toMap()).toList(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Eliminar un lote de una finca
  Future<void> deletePlot(String farmId, int plotIndex) async {
    try {
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
    } catch (e) {
      rethrow;
    }
  }
}