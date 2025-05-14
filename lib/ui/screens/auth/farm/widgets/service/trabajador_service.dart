import 'package:cloud_firestore/cloud_firestore.dart';

class TrabajadorService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Obtener trabajadores por lote
  Future<Map<String, List<String>>> getTrabajadoresPorLote(String farmId) async {
    final snapshot = await _firestore
        .collection('trabajadores_lote')
        .where('farmId', isEqualTo: farmId)
        .get();
    
    Map<String, List<String>> trabajadoresPorLote = {};
    
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final loteId = data['loteId'] as String;
      final nombreTrabajador = data['nombre'] as String;
      
      if (!trabajadoresPorLote.containsKey(loteId)) {
        trabajadoresPorLote[loteId] = [];
      }
      
      trabajadoresPorLote[loteId]!.add(nombreTrabajador);
    }
    
    return trabajadoresPorLote;
  }

  // Guardar un nuevo trabajador
  Future<void> saveTrabajador(String nombre, String loteId, String farmId) async {
    await _firestore.collection('trabajadores_lote').add({
      'nombre': nombre,
      'loteId': loteId,
      'farmId': farmId,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Eliminar un trabajador
  Future<void> deleteTrabajador(String nombre, String loteId, String farmId) async {
    final querySnapshot = await _firestore
        .collection('trabajadores_lote')
        .where('nombre', isEqualTo: nombre)
        .where('loteId', isEqualTo: loteId)
        .where('farmId', isEqualTo: farmId)
        .get();
        
    for (var doc in querySnapshot.docs) {
      await doc.reference.delete();
    }
  }
}