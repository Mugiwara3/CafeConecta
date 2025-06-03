import 'package:flutter/material.dart';
import 'package:miapp_cafeconecta/models/farm_model.dart';
import 'package:miapp_cafeconecta/ui/screens/auth/cursos/modulo_detalle_screen.dart';
import 'package:miapp_cafeconecta/ui/screens/auth/farm/DetalleFincaScreen.dart';
import 'package:miapp_cafeconecta/ui/screens/auth/farm/registrarKilos/registrar_kilos.dart';
import 'package:miapp_cafeconecta/ui/screens/auth/home/widgets/app_bar/home_app_bar.dart';
import 'package:miapp_cafeconecta/ui/screens/auth/home/widgets/farm_card.dart';
import 'package:miapp_cafeconecta/ui/screens/auth/home/widgets/price_card.dart';
import 'package:miapp_cafeconecta/controllers/auth_controller.dart';
import 'package:miapp_cafeconecta/controllers/farm_controller.dart';
import 'package:miapp_cafeconecta/ui/screens/auth/farm/add_farm_screen.dart';
import 'package:miapp_cafeconecta/ui/screens/auth/login/login_screen.dart';
import 'package:miapp_cafeconecta/ui/screens/auth/cursos/cursos_screen.dart';
import 'package:miapp_cafeconecta/ui/screens/auth/ventas/registrar_ventas_screen.dart';
import 'package:miapp_cafeconecta/ui/screens/auth/ventas/historial_venta_screen.dart';
import 'package:miapp_cafeconecta/ui/screens/auth/ventas/venta_controller.dart'
    as controllers;
import 'package:provider/provider.dart';

// Nueva clase para las opciones del menú con colores personalizados
class HomeOption {
  final String title;
  final IconData icon;
  final String route;
  final Color? iconColor;
  final Color? backgroundColor;
  final String? description;

  HomeOption(
    this.title,
    this.icon,
    this.route, {
    this.iconColor,
    this.backgroundColor,
    this.description,
  });
}

// Lista de opciones del menú con mejor diseño
final List<HomeOption> homeOptions = [
  HomeOption(
    "Registrar Kilos",
    Icons.scale_outlined,
    "/registrar_kilos",
    iconColor: Colors.blue[600],
    backgroundColor: Colors.blue[50],
    description: "Registra la producción de café",
  ),
  HomeOption(
    "Registrar Ventas",
    Icons.point_of_sale_outlined,
    "/registrar_ventas",
    iconColor: Colors.green[600],
    backgroundColor: Colors.green[50],
    description: "Registra tus ventas de café",
  ),
  HomeOption(
    "Historial Ventas",
    Icons.analytics_outlined,
    "/historial_ventas",
    iconColor: Colors.orange[600],
    backgroundColor: Colors.orange[50],
    description: "Consulta tu historial de ventas",
  ),
  HomeOption(
    "Cerrar Sesión",
    Icons.logout_outlined,
    "/cerrar_sesion",
    iconColor: Colors.red[600],
    backgroundColor: Colors.red[50],
    description: "Salir de la aplicación",
  ),
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
          // Menú desplegable mejorado
          PopupMenuButton<HomeOption>(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.more_vert_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            elevation: 12,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            offset: const Offset(-8, 8),
            color: Colors.white,
            surfaceTintColor: Colors.white,
            shadowColor: Colors.black.withOpacity(0.2),
            onSelected: (HomeOption option) {
              _handleMenuSelection(option.route);
            },
            itemBuilder: (BuildContext context) {
              return homeOptions.map((HomeOption option) {
                final isLogout = option.route == "/cerrar_sesion";

                return PopupMenuItem<HomeOption>(
                  value: option,
                  padding: EdgeInsets.zero,
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: option.backgroundColor ?? Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: (option.iconColor ?? Colors.grey).withOpacity(
                          0.2,
                        ),
                        width: 1,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: (option.iconColor ?? Colors.grey)
                                  .withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          option.icon,
                          color: option.iconColor ?? Colors.brown[700],
                          size: 20,
                        ),
                      ),
                      title: Text(
                        option.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: isLogout ? Colors.red[700] : Colors.grey[800],
                        ),
                      ),
                      subtitle:
                          option.description != null
                              ? Text(
                                option.description!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              )
                              : null,
                      trailing: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: Colors.grey[400],
                      ),
                    ),
                  ),
                );
              }).toList();
            },
          ),
          const SizedBox(width: 8),
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

  void _navigateWithVentaController(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ChangeNotifierProvider.value(
              value: controllers.VentaController(), // Usa .value constructor
              child: screen,
            ),
      ),
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
        _navigateWithVentaController(context, const RegistrarVentasScreen());
        break;

      case "/historial_ventas":
        _navigateWithVentaController(context, const HistorialVentasScreen());
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
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CursosScreen()),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.logout_outlined,
                  color: Colors.red[600],
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Cerrar sesión',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          content: const Text(
            '¿Estás seguro que deseas cerrar sesión?',
            style: TextStyle(fontSize: 16),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              child: Text(
                'Cancelar',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Cerrar sesión',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
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
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => FincaDetalleScreen(farm: farm)),
      );

      if (result != null) {
        if (result == true) {
          // La finca fue eliminada, mostramos mensaje y refrescamos la lista
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Finca eliminada correctamente'),
                backgroundColor: Colors.green,
              ),
            );
            setState(() {}); // Refrescar la lista
          }
        } else if (result is Farm) {
          // La finca fue actualizada
          await _farmController.updateFarm(result);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Finca actualizada correctamente'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
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
