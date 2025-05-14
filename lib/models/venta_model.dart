import 'package:cloud_firestore/cloud_firestore.dart';

class Venta {
  String id;
  final String userId;
  final DateTime fecha;
  final String cliente;
  final double precio;
  final double kilos;
  final double total;
  final DateTime createdAt;

  Venta({
    required this.id,
    required this.userId,
    required this.fecha,
    required this.cliente,
    required this.precio,
    required this.kilos,
    required this.total,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'fecha': Timestamp.fromDate(fecha),
      'cliente': cliente,
      'precio': precio,
      'kilos': kilos,
      'total': total,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Venta.fromMap(String id, Map<String, dynamic> map) {
    return Venta(
      id: id,
      userId: map['userId'] ?? '',
      fecha: (map['fecha'] as Timestamp).toDate(),
      cliente: map['cliente'] ?? '',
      precio: (map['precio'] ?? 0).toDouble(),
      kilos: (map['kilos'] ?? 0).toDouble(),
      total: (map['total'] ?? 0).toDouble(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}