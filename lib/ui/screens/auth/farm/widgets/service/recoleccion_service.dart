import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:miapp_cafeconecta/models/recoleccion_model.dart';

class RecoleccionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'recolecciones';

  // Obtener todas las recolecciones
  Future<List<Recoleccion>> getRecolecciones() async {
    try {
      final snapshot = await _firestore.collection(_collectionName).get();
      return snapshot.docs.map((doc) {
        return Recoleccion.fromMap(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Obtener recolecciones por finca
  Future<List<Recoleccion>> getRecoleccionesByFarm(String farmId) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('farmId', isEqualTo: farmId)
          .get();
      return snapshot.docs.map((doc) {
        return Recoleccion.fromMap(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Obtener recolecciones por lote
  Future<List<Recoleccion>> getRecoleccionesByLote(String farmId, String loteId) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('farmId', isEqualTo: farmId)
          .where('loteId', isEqualTo: loteId)
          .get();
      return snapshot.docs.map((doc) {
        return Recoleccion.fromMap(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Guardar una recolección
  Future<String> saveRecoleccion(Recoleccion recoleccion) async {
    try {
      if (recoleccion.id.isEmpty) {
        // Es una nueva recolección
        final docRef = await _firestore.collection(_collectionName).add(recoleccion.toMap());
        return docRef.id;
      } else {
        // Actualizamos una recolección existente
        await _firestore.collection(_collectionName).doc(recoleccion.id).update(recoleccion.toMap());
        return recoleccion.id;
      }
    } catch (e) {
      rethrow;
    }
  }

  // Eliminar una recolección
  Future<void> deleteRecoleccion(String recoleccionId) async {
    try {
      await _firestore.collection(_collectionName).doc(recoleccionId).delete();
    } catch (e) {
      rethrow;
    }
  }
}