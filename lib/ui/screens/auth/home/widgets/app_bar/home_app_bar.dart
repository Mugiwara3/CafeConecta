import 'package:flutter/material.dart';
import 'package:miapp_cafeconecta/controllers/auth_controller.dart';
import 'package:miapp_cafeconecta/ui/screens/auth/home/widgets/home_option.dart';
import 'package:provider/provider.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final List<Widget>? actions;
  final Function(String)? onMenuSelected;
  
  const HomeAppBar({
    super.key,
    this.onMenuSelected,
    this.actions,
  });

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
      actions: actions ?? [
        PopupMenuButton<HomeOption>(
          icon: const Icon(Icons.more_vert),
          onSelected: (HomeOption option) {
            if (onMenuSelected != null) {
              onMenuSelected!(option.route);
            }
          },
          itemBuilder: (BuildContext context) {
            return homeOptions.map((HomeOption option) {
              return PopupMenuItem<HomeOption>(
                value: option,
                child: Row(
                  children: [
                    Icon(option.icon, color: option.route == "/cerrar_sesion" ? Colors.red : Colors.brown[700]),
                    const SizedBox(width: 10),
                    Text(option.title),
                  ],
                ),
              );
            }).toList();
          },
        ),
        IconButton(
          icon: const Icon(Icons.notifications),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.account_circle),
          onPressed: () => _showLogoutDialog(context),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
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
              Navigator.pop(context);
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