import 'package:cloud_firestore/cloud_firestore.dart';

class Recoleccion {
  final String id;
  final String farmId; 
  final String loteId; 
  final String fecha;
  final Map<String, dynamic> data; // Datos de trabajadores y kilos
  final Timestamp timestamp;

  Recoleccion({
    required this.id,
    required this.farmId,
    required this.loteId,
    required this.fecha,
    required this.data,
    required this.timestamp,
  });

  factory Recoleccion.fromMap(Map<String, dynamic> map, String docId) {
    return Recoleccion(
      id: docId,
      farmId: map['farmId'] ?? '',
      loteId: map['loteId'] ?? '',
      fecha: map['fecha'] ?? '',
      data: map['data'] ?? {},
      timestamp: map['timestamp'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'farmId': farmId,
      'loteId': loteId,
      'fecha': fecha,
      'data': data,
      'timestamp': timestamp,
    };
  }
}