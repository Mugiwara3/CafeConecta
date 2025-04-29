import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:miapp_cafeconecta/ui/app.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async {
  Provider.debugCheckInvalidValueType = null;
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}
