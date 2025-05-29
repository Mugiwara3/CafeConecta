import 'package:flutter/foundation.dart'; // Añade esto
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:miapp_cafeconecta/ui/screens/auth/ventas/venta_model.dart';

class VentaController extends ChangeNotifier {
  // Extiende ChangeNotifier
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> agregarVenta(Venta venta) async {
    await _firestore.collection('ventas').doc(venta.id).set(venta.toMap());
    notifyListeners(); // Añade esta línea
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
}
