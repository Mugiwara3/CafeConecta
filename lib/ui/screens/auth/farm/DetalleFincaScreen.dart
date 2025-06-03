import 'package:flutter/material.dart';
import 'package:miapp_cafeconecta/models/farm_model.dart';
import 'package:miapp_cafeconecta/ui/screens/auth/farm/lotes_screen.dart';
import 'package:miapp_cafeconecta/ui/screens/auth/farm/edit_farm_screen.dart'; // Nueva importación
import 'package:miapp_cafeconecta/ui/screens/auth/farm/widgets/farm_info_card.dart';
import 'package:miapp_cafeconecta/ui/screens/auth/farm/widgets/service/farm_service.dart';

class FincaDetalleScreen extends StatefulWidget {
  final Farm farm;

  const FincaDetalleScreen({super.key, required this.farm});

  @override
  State<FincaDetalleScreen> createState() => _FincaDetalleScreenState();
}

class _FincaDetalleScreenState extends State<FincaDetalleScreen> {
  final FarmService _farmService = FarmService();
  late Stream<Farm?> _farmStream;

  @override
  void initState() {
    super.initState();
    _farmStream = _farmService.getFarm(widget.farm.id);
  }

  Future<void> _editarFinca(Farm farm) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditarFincaScreen(farm: farm)),
    );

    if (result != null) {
      if (result == 'delete') {
        // El usuario eligió eliminar la finca
        await _eliminarFinca(farm);
      } else if (result is Farm) {
        // El usuario actualizó la finca
        await _actualizarFinca(result);
      }
    }
  }

  Future<void> _actualizarFinca(Farm updatedFarm) async {
    try {
      await _farmService.updateFarm(updatedFarm);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Finca actualizada correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar finca: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _eliminarFinca(Farm farm) async {
    try {
      await _farmService.deleteFarm(farm.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Finca eliminada correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        // Volver a la pantalla anterior
        Navigator.pop(context, true); // true indica que se eliminó
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar finca: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.farm.name),
        backgroundColor: Colors.brown[700],
        actions: [
          StreamBuilder<Farm?>(
            stream: _farmStream,
            builder: (context, snapshot) {
              final farm = snapshot.data;
              return IconButton(
                icon: const Icon(Icons.edit),
                onPressed: farm != null ? () => _editarFinca(farm) : null,
                tooltip: 'Editar Finca',
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<Farm?>(
        stream: _farmStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    "Error al cargar la información: ${snapshot.error}",
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _farmStream = _farmService.getFarm(widget.farm.id);
                      });
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          final farm = snapshot.data;
          if (farm == null) {
            return const Center(child: Text("No se encontró la finca"));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Información de la finca
                FincaInfoWidget(
                  farm: farm,
                  finca: {
                    'nombre': farm.name,
                    'hectareas': farm.hectares,
                    'altura': farm.altitude,
                    'departamento': farm.department,
                    'municipio': farm.municipality,
                    'vereda': farm.village,
                  },
                ),

                const SizedBox(height: 24),

                // Tarjeta de lotes
                Card(
                  elevation: 4,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LotesScreen(farm: farm),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.grass,
                                size: 30,
                                color: Colors.green,
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                "Lotes",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                "${farm.plots.length} lotes",
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_forward_ios, size: 16),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "Administra los lotes de tu finca, registra variedades, alturas y cantidad de matas.",
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Tarjeta de estadísticas (opcional)
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.analytics,
                              size: 30,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              "Estadísticas",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildStatRow(
                          "Total de hectáreas:",
                          "${farm.hectares.toStringAsFixed(1)} ha",
                          Icons.square_foot,
                        ),
                        _buildStatRow(
                          "Hectáreas de café:",
                          "${farm.coffeeHectares.toStringAsFixed(1)} ha",
                          Icons.eco,
                        ),
                        _buildStatRow(
                          "Porcentaje de café:",
                          "${((farm.coffeeHectares / farm.hectares) * 100).toStringAsFixed(1)}%",
                          Icons.pie_chart,
                        ),
                        _buildStatRow(
                          "Altitud promedio:",
                          "${farm.altitude.toStringAsFixed(0)} msnm",
                          Icons.terrain,
                        ),
                        _buildStatRow(
                          "Total de lotes:",
                          "${farm.plots.length}",
                          Icons.grass,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Botón de editar finca (alternativo)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _editarFinca(farm),
                    icon: const Icon(Icons.edit),
                    label: const Text('Editar Información de la Finca'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 14)),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
