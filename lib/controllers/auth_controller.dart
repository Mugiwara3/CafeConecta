import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AuthController extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  
  bool get isLoading => _isLoading;
  User? get currentUser => _auth.currentUser;
  
  AuthController() {
    // Configurar persistencia de sesión
    _setPersistence();
    
    // Escuchar cambios de autenticación
    _auth.authStateChanges().listen((User? user) {
      notifyListeners();
    });
  }
  
  // Configurar persistencia
  Future<void> _setPersistence() async {
    try {
      await _auth.setPersistence(Persistence.LOCAL);
    } catch (e) {
      print("Error al configurar persistencia: $e");
    }
  }

  Future<User?> login(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      notifyListeners(); // Notificar cambio de usuario
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw _mapAuthError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<User?> register({
    required String email,
    required String password,
    required String name,
    String? phone,
    String? farmName,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'name': name,
        'phone': phone,
        'farmName': farmName,
        'role': 'farmer', // Rol por defecto
        'createdAt': FieldValue.serverTimestamp(),
      });

      notifyListeners(); // Notificar cambio de usuario
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw _mapAuthError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email es requerido';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Email no válido';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Contraseña requerida';
    if (value.length < 6) return 'Mínimo 6 caracteres';
    if (!RegExp(r'[A-Za-z]').hasMatch(value) ||
        !RegExp(r'[0-9]').hasMatch(value)) {
      return 'Debe contener letras y números';
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) return 'Nombre es requerido';
    if (value.length < 3) return 'Mínimo 3 caracteres';
    return null;
  }

  String _mapAuthError(FirebaseAuthException error) {
    switch (error.code) {
      case 'user-not-found':
        return 'Usuario no registrado';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      case 'email-already-in-use':
        return 'El correo ya está registrado';
      case 'weak-password':
        return 'La contraseña es muy débil';
      case 'invalid-email':
        return 'Correo electrónico no válido';
      default:
        return 'Error: ${error.message ?? "Ocurrió un problema"}';
    }
  }

  Future<void> logout() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await _auth.signOut();
      
      notifyListeners(); // Notificar cambio de usuario
    } catch (e) {
      print("Error en logout: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      notifyListeners();
    } catch (e) {
      print("Error al cerrar sesión: $e");
      rethrow;
    }
  }
}