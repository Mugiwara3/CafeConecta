import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:miapp_cafeconecta/ui/app.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:miapp_cafeconecta/ui/screens/auth/ventas/venta_controller.dart';
import 'firebase_options.dart';

void main() async {
  Provider.debugCheckInvalidValueType = null;
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Inicializar localización para español
  await initializeDateFormatting('es_ES', null);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => VentaController()),
        // Agrega aquí otros providers que necesites
      ],
      child: const MyApp(),
    ),
  );
}