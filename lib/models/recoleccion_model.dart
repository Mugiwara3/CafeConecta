import 'package:cloud_firestore/cloud_firestore.dart';

class Recoleccion {
  final String id;
  final String farmId;
  final String loteld;
  final String fecha;
  final Map<String, dynamic> data; // Ahora solo guarda {trabajador: {'kilos': valor}}
  final Timestamp timestamp;

  Recoleccion({
    required this.id,
    required this.farmId,
    required this.loteld,
    required this.fecha,
    required this.data,
    required this.timestamp, required loteId,
  });

  factory Recoleccion.fromMap(Map<String, dynamic> map, String docId) {
    return Recoleccion(
      id: docId,
      farmId: map['farmId'] ?? '',
      loteld: map['loteld'] ?? '',
      fecha: map['fecha'] ?? '',
      data: map['data'] ?? {},
      timestamp: map['timestamp'] ?? Timestamp.now(), loteId: null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'farmId': farmId,
      'loteld': loteld,
      'fecha': fecha,
      'data': data,
      'timestamp': timestamp,
    };
  }
}
