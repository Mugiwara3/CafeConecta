import 'package:flutter/material.dart';
import 'package:miapp_cafeconecta/controllers/auth_controller.dart';
import 'package:miapp_cafeconecta/ui/screens/auth/home/chat/Chat_screen.dart';
import 'package:miapp_cafeconecta/ui/screens/auth/register/register_screen.dart';
import 'package:miapp_cafeconecta/ui/screens/auth/home/home_screen.dart';
import 'package:miapp_cafeconecta/ui/screens/auth/login/login_screen.dart';
import 'package:provider/provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: AuthController(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Cafe Conecta',
        theme: ThemeData(
          primarySwatch: Colors.brown,
          primaryColor: Colors.brown[800],
          visualDensity: VisualDensity.adaptivePlatformDensity,
          scaffoldBackgroundColor: Colors.brown[50],
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.brown,
            accentColor: Colors.green[700],
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.brown[700],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
          '/register': (context) => const RegisterScreen(),
          '/chat': (context) => const ChatScreen(),
        },
        initialRoute: '/login',
      ),
    );
  }
}
