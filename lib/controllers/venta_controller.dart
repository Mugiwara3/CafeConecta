import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:miapp_cafeconecta/models/venta_model.dart';

class VentaController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'ventas';

  // Añadir una nueva venta
  Future<String> addVenta(Venta venta) async {
    try {
      final docRef = await _firestore.collection(_collection).add(venta.toMap());
      return docRef.id;
    } catch (e) {
      debugPrint('Error al añadir venta: $e');
      throw Exception('Error al registrar la venta: $e');
    }
  }

  // Obtener todas las ventas de un usuario
  Stream<List<Venta>> getVentas(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Venta.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  // Obtener una venta específica
  Future<Venta?> getVenta(String ventaId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(ventaId).get();
      if (doc.exists) {
        return Venta.fromMap(doc.id, doc.data()!);
      }
      return null;
    } catch (e) {
      debugPrint('Error al obtener venta: $e');
      throw Exception('Error al obtener la venta: $e');
    }
  }

  // Actualizar una venta existente
  Future<void> updateVenta(Venta venta) async {
    try {
      await _firestore.collection(_collection).doc(venta.id).update(venta.toMap());
    } catch (e) {
      debugPrint('Error al actualizar venta: $e');
      throw Exception('Error al actualizar la venta: $e');
    }
  }

  // Eliminar una venta
  Future<void> deleteVenta(String ventaId) async {
    try {
      await _firestore.collection(_collection).doc(ventaId).delete();
    } catch (e) {
      debugPrint('Error al eliminar venta: $e');
      throw Exception('Error al eliminar la venta: $e');
    }
  }

  // Estadísticas: Total de ventas por usuario
  Future<double> getTotalVentas(String userId) async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .get();
      
      double total = 0;
      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        total += (data['total'] ?? 0).toDouble();
      }
      return total;
    } catch (e) {
      debugPrint('Error al calcular total de ventas: $e');
      throw Exception('Error al calcular el total de ventas: $e');
    }
  }

  // Estadísticas: Total de kilos vendidos por usuario
  Future<double> getTotalKilos(String userId) async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .get();
      
      double totalKilos = 0;
      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        totalKilos += (data['kilos'] ?? 0).toDouble();
      }
      return totalKilos;
    } catch (e) {
      debugPrint('Error al calcular total de kilos: $e');
      throw Exception('Error al calcular el total de kilos: $e');
    }
  }
}