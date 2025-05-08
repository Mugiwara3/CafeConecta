import 'package:flutter/material.dart';
import 'package:miapp_cafeconecta/controllers/auth_controller.dart';
import 'package:miapp_cafeconecta/models/farm_model.dart';
import 'package:miapp_cafeconecta/ui/screens/auth/farm/DetalleFincaScreen.dart';
import 'package:miapp_cafeconecta/ui/screens/auth/farm/add_farm_screen.dart';
import 'package:miapp_cafeconecta/ui/screens/auth/farm/widgets/farm_service.dart';
import 'package:provider/provider.dart';

class HomeOption {
  final String title;
  final IconData icon;
  final String route;

  HomeOption(this.title, this.icon, this.route);
}

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
  final FarmService _farmService = FarmService();
  Stream<List<Farm>>? _farmsStream;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    final authController = Provider.of<AuthController>(context, listen: false);
    final user = authController.currentUser;
    
    if (user != null) {
      setState(() {
        _farmsStream = _farmService.getFarmsForUser(user.uid);
      });
    }
  }

  Future<void> _agregarFinca() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AgregarFincaScreen()),
    );

    if (result != null && result is Farm) {
      try {
        // Guardar la finca en Firestore
        final farmId = await _farmService.createFarm(result);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Finca guardada correctamente"),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error al guardar la finca: ${e.toString()}"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _eliminarFinca(String farmId) async {
    // Mostrar diálogo de confirmación
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmar eliminación"),
        content: const Text("¿Estás seguro de que quieres eliminar esta finca?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Eliminar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        await _farmService.deleteFarm(farmId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Finca eliminada correctamente"),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error al eliminar la finca: ${e.toString()}"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _cerrarSesion() async {
    try {
      final authController = Provider.of<AuthController>(context, listen: false);
      await authController.signOut();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al cerrar sesión: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _navigateToRoute(String route) {
    if (route == "/cerrar_sesion") {
      _cerrarSesion();
    } else {
      Navigator.pushNamed(context, route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mis Fincas"),
        backgroundColor: Colors.brown[700],
        actions: [
          PopupMenuButton<HomeOption>(
            icon: const Icon(Icons.more_vert),
            onSelected: (HomeOption option) {
              _navigateToRoute(option.route);
            },
            itemBuilder: (BuildContext context) {
              return homeOptions.map((HomeOption option) {
                return PopupMenuItem<HomeOption>(
                  value: option,
                  child: Row(
                    children: [
                      Icon(option.icon, color: Colors.brown[700]),
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
      body: _farmsStream == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<List<Farm>>(
              stream: _farmsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Error al cargar las fincas: ${snapshot.error}",
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
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
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "No tienes fincas registradas",
                          style: TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: _agregarFinca,
                          icon: const Icon(Icons.add),
                          label: const Text("Agregar Finca"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.brown[700],
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: farms.length,
                  itemBuilder: (context, index) {
                    final farm = farms[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 4,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FincaDetalleScreen(farm: farm),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.park, size: 32, color: const Color.fromARGB(255, 59, 172, 65)),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      farm.name,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Color.fromARGB(255, 227, 38, 25)),
                                    onPressed: () => _eliminarFinca(farm.id),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.location_on, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    "${farm.municipality}, ${farm.department}",
                                    style: TextStyle(color: const Color.fromARGB(255, 197, 68, 68)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.grass, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    "${farm.plots.length} lotes",
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                  const Spacer(),
                                  Text(
                                    "${farm.hectares} hectáreas",
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _agregarFinca,
        backgroundColor: Colors.brown[700],
        child: const Icon(Icons.add),
      ),
    );
  }
}