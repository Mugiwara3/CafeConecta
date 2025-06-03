import 'package:cloud_firestore/cloud_firestore.dart';

class Trabajador {
  final String id;
  final String nombre;
  final String loteId;
  final String farmId;
  final Timestamp timestamp;

  Trabajador({
    required this.id,
    required this.nombre,
    required this.loteId,
    required this.farmId,
    required this.timestamp,
  });

  factory Trabajador.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Trabajador(
      id: doc.id,
      nombre: data['nombre'] ?? '',
      loteId: data['loteId'] ?? '',
      farmId: data['farmId'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'loteId': loteId,
      'farmId': farmId,
      'timestamp': timestamp,
    };
  }
}
