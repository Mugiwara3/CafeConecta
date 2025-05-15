import 'package:flutter/material.dart';
import 'package:miapp_cafeconecta/models/farm_model.dart';
import 'package:miapp_cafeconecta/ui/screens/auth/farm/DetalleFincaScreen.dart';
import 'package:miapp_cafeconecta/ui/screens/auth/farm/registrarKilos/registrar_kilos.dart';
import 'package:miapp_cafeconecta/ui/screens/auth/home/widgets/app_bar/home_app_bar.dart';
import 'package:miapp_cafeconecta/ui/screens/auth/home/widgets/farm_card.dart';
import 'package:miapp_cafeconecta/ui/screens/auth/home/widgets/price_card.dart';
import 'package:miapp_cafeconecta/controllers/auth_controller.dart';
import 'package:miapp_cafeconecta/controllers/farm_controller.dart';
import 'package:miapp_cafeconecta/ui/screens/auth/farm/add_farm_screen.dart';
import 'package:miapp_cafeconecta/ui/screens/auth/login/login_screen.dart';
import 'package:provider/provider.dart';

// Nueva clase para las opciones del menú
class HomeOption {
  final String title;
  final IconData icon;
  final String route;

  HomeOption(this.title, this.icon, this.route);
}

// Lista de opciones del menú
final List<HomeOption> homeOptions = [
  HomeOption("Registrar Kilos", Icons.fitness_center, "/registrar_kilos"),
  HomeOption("Registrar Ventas", Icons.attach_money, "/registrar_ventas"),
  HomeOption("Cerrar Sesión", Icons.logout, "/cerrar_sesion"),
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _isLoading = false;
  late final FarmController _farmController;

  @override
  void initState() {
    super.initState();
    _farmController = FarmController();
  }

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    final user = authController.currentUser;

    if (user == null) {
      // Si no hay usuario autenticado, redirigimos al login
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/login');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: HomeAppBar(
        actions: [
          PopupMenuButton<HomeOption>(
            icon: const Icon(Icons.more_vert),
            onSelected: (HomeOption option) {
              _handleMenuSelection(option.route);
            },
            itemBuilder: (BuildContext context) {
              return homeOptions.map((HomeOption option) {
                return PopupMenuItem<HomeOption>(
                  value: option,
                  child: Row(
                    children: [
                      Icon(
                        option.icon,
                        color:
                            option.route == "/cerrar_sesion"
                                ? Colors.red
                                : Colors.brown[700],
                      ),
                      const SizedBox(width: 10),
                      Text(option.title),
                    ],
                  ),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          _buildBody(user.uid),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
      floatingActionButton: _buildAddFarmButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildBody(String userId) {
    return Column(
      children: [
        const PriceCard(),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Mis fincas",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => setState(() {}),
              ),
            ],
          ),
        ),
        Expanded(child: _buildFarmsList(userId)),
      ],
    );
  }

  // Método modificado para manejar selecciones del menú
  void _handleMenuSelection(String route) {
    switch (route) {
      case "/registrar_kilos":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const RegistrarKilosScreen()),
        );
        break;
      case "/registrar_ventas":
        // Implementar navegación a ventas cuando exista
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Función en desarrollo")));
        break;
      case "/cerrar_sesion":
        final authController = Provider.of<AuthController>(
          context,
          listen: false,
        );
        _showLogoutConfirmation(context, authController);
        break;
      default:
        break;
    }
  }

  Widget _buildFarmsList(String userId) {
    return StreamBuilder<List<Farm>>(
      stream: _farmController.getFarms(userId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          debugPrint('Error en stream de fincas: ${snapshot.error}');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Error al cargar fincas: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  child: const Text("Reintentar"),
                ),
              ],
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final farms = snapshot.data ?? [];

        if (farms.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'lib/ui/screens/assets/images/logo.png',
                  height: 120,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.image_not_supported, size: 120);
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  "No tienes fincas registradas",
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                _buildAddFarmButton(mini: true),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => setState(() {}),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: farms.length,
            itemBuilder: (context, index) {
              return FarmCard(
                farm: farms[index],
                onTap: () => _navigateToFarmDetail(farms[index]),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildAddFarmButton({bool mini = false}) {
    return mini
        ? FloatingActionButton.small(
          backgroundColor: Colors.red,
          onPressed: _navigateToAddFarm,
          child: const Icon(Icons.add, color: Colors.white),
        )
        : FloatingActionButton.extended(
          backgroundColor: Colors.red,
          heroTag: "addFarmButton",
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            "Agregar Finca",
            style: TextStyle(color: Colors.white),
          ),
          onPressed: _navigateToAddFarm,
        );
  }

  BottomNavigationBar _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.brown[800],
      unselectedItemColor: Colors.brown[300],
      onTap: _handleBottomNavSelection,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Inicio"),
        BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: "Cursos"),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline),
          label: "ChatIA",
        ),
      ],
    );
  }

  void _handleBottomNavSelection(int index) {
    setState(() => _selectedIndex = index);
    // Implementar navegación según el índice
    switch (index) {
      case 0:
        break;
      case 1:
        // Navegar a cursos
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Sección de Cursos en desarrollo")),
        );
        break;
      case 2:
        // Navegar a chat IA
        Navigator.pushNamed(context, '/chat');
        break;
    }
  }

  // Mostrar diálogo de confirmación para cerrar sesión
  Future<void> _showLogoutConfirmation(
    BuildContext context,
    AuthController authController,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Cerrar sesión'),
          content: const Text('¿Estás seguro que deseas cerrar sesión?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Cerrar sesión'),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await _signOut(authController);
              },
            ),
          ],
        );
      },
    );
  }

  // Método para cerrar sesión
  Future<void> _signOut(AuthController authController) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await authController.signOut();

      if (!mounted) return;

      // Navegar a la pantalla de login y eliminar el historial de navegación
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      debugPrint('Error al cerrar sesión: $e');
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cerrar sesión: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _navigateToAddFarm() async {
    try {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AgregarFincaScreen()),
      );

      if (result != null && result is Farm) {
        setState(() => _isLoading = true);

        try {
          // Intentar guardar la finca
          final farmId = await _farmController.addFarm(result);
          debugPrint("Finca guardada con ID: $farmId");

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("¡Finca registrada con éxito!"),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          debugPrint("Error al guardar finca: $e");
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Error al guardar: ${e.toString()}"),
                backgroundColor: Colors.red,
              ),
            );
          }
        } finally {
          if (mounted) {
            setState(() => _isLoading = false);
          }
        }
      }
    } catch (e) {
      debugPrint("Error en navegación: $e");
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _navigateToFarmDetail(Farm farm) async {
    try {
      final updatedFarm = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => FincaDetalleScreen(farm: farm)),
      );

      if (updatedFarm != null && updatedFarm is Farm && mounted) {
        await _farmController.updateFarm(updatedFarm);
      }
    } catch (e) {
      debugPrint("Error al navegar a detalles de finca: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
