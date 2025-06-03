import 'package:cloud_firestore/cloud_firestore.dart';

class TrabajadorService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, List<String>>> getTrabajadoresPorLote(String farmId) async {
    final snapshot = await _firestore
        .collection('trabajadores')
        .where('farmId', isEqualTo: farmId)
        .get();

    Map<String, List<String>> trabajadores = {'general': []};
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final nombreTrabajador = data['nombre'] as String;
      trabajadores['general']!.add(nombreTrabajador);
    }

    return trabajadores;
  }

  Future<void> saveTrabajador(String nombre, String farmId) async {
    await _firestore.collection('trabajadores').add({
      'nombre': nombre,
      'farmId': farmId,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteTrabajador(String nombre, String farmId) async {
    final querySnapshot = await _firestore
        .collection('trabajadores')
        .where('nombre', isEqualTo: nombre)
        .where('farmId', isEqualTo: farmId)
        .get();

    for (var doc in querySnapshot.docs) {
      await doc.reference.delete();
    }
  }
}
