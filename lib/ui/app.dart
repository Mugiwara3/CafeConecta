import 'package:flutter/material.dart';
import 'package:miapp_cafeconecta/controllers/auth_controller.dart';
import 'package:miapp_cafeconecta/ui/screens/auth/register/register_screen.dart';
import 'package:miapp_cafeconecta/ui/screens/auth/home/home_screen.dart';
import 'package:miapp_cafeconecta/ui/screens/auth/login/login_screen.dart';
import 'package:provider/provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider<AuthController>.value(
      value: AuthController(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Cafe Conecta',
        routes: {
          '/login': (context) => LoginScreen(),
          '/home': (context) => HomeScreen(),
          '/register': (context) => RegisterScreen(),
        },
        initialRoute: '/login',
      ),
    );
  }
}