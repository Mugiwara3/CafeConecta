import 'package:flutter/material.dart';
import 'package:miapp_cafeconecta/controllers/auth_controller.dart';
import 'package:provider/provider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key, required String title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.brown[700],
      title: Row(
        children: [
          const Icon(Icons.coffee_rounded, color: Colors.white),
          const SizedBox(width: 10),
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: "Café",
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: "Connecta",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.account_circle),
          onPressed: () {},
        ),
      ],
    );
  }


  void showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro que deseas cerrar tu sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Cerrar diálogo
              await _handleLogout(context);
            },
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }

    Future<void> _handleLogout(BuildContext context) async {
    try {
      final authController = Provider.of<AuthController>(context, listen: false);
      await authController.signOut();
      
      // Navegar a la pantalla de login
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cerrar sesión: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}