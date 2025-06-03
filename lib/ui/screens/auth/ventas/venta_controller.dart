// venta_controller.dart
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:miapp_cafeconecta/ui/screens/auth/ventas/venta_model.dart';

class VentaController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> agregarVenta(Venta venta) async {
    await _firestore.collection('ventas').doc(venta.id).set(venta.toMap());
    notifyListeners();
  }

  Future<void> actualizarVenta(Venta venta) async {
    await _firestore.collection('ventas').doc(venta.id).update(venta.toMap());
    notifyListeners();
  }

  Future<void> eliminarVenta(String id) async {
    await _firestore.collection('ventas').doc(id).delete();
    notifyListeners();
  }

  Stream<List<Venta>> obtenerVentas() {
    return _firestore
        .collection('ventas')
        .orderBy('fecha', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Venta.fromMap(doc.data())).toList(),
        );
  }

  Future<Venta?> obtenerVentaPorId(String id) async {
    final doc = await _firestore.collection('ventas').doc(id).get();
    return doc.exists ? Venta.fromMap(doc.data()!) : null;
  }
}