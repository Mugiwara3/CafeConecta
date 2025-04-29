import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:miapp_cafeconecta/models/farm_model.dart';


class FarmController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  
  bool get isLoading => _isLoading;

  Stream<List<Farm>> getFarms(String userId) {
    try {
      return _firestore
          .collection('farms')
          .where('ownerId', isEqualTo: userId)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => Farm.fromMap({
                      ...doc.data(),
                      'id': doc.id,
                    }))
                .toList();
          });
    } catch (e) {
      print("Error al obtener fincas: $e");
      return Stream.value([]);
    }
  }

    Future<String> addFarm(Farm farm) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // Crear la colección si no existe
      final collectionRef = _firestore.collection('farms');
      
      // Agregar documento
      final docRef = await collectionRef.add(farm.toMap());
      print("Finca agregada con ID: ${docRef.id}");
      
      return docRef.id;
    } catch (e) {
      print("Error al agregar finca: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  Future<void> updateFarm(Farm farm) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await _firestore.collection('farms').doc(farm.id).update(farm.toMap());
      print("Finca actualizada con ID: ${farm.id}");
    } catch (e) {
      print("Error al actualizar finca: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteFarm(String farmId) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await _firestore.collection('farms').doc(farmId).delete();
      print("Finca eliminada con ID: $farmId");
    } catch (e) {
      print("Error al eliminar finca: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}