import 'package:flutter/material.dart';
import 'package:miapp_cafeconecta/models/farm_model.dart';
import 'package:miapp_cafeconecta/ui/screens/auth/farm/lotes_screen.dart';
import 'package:miapp_cafeconecta/ui/screens/auth/farm/widgets/farm_info_card.dart';
import 'package:miapp_cafeconecta/ui/screens/auth/farm/widgets/service/farm_service.dart';
import 'package:miapp_cafeconecta/ui/screens/auth/farm/edit_farm_screen.dart';

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

  void _navegarAEditarFinca(Farm farm) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditarFincaScreen(farm: farm),
      ),
    );

    if (result == 'deleted') {
      // Si se eliminó la finca, regresar al home
      if (mounted) {
        Navigator.pop(context, 'deleted');
      }
    } else if (result != null && result is Farm) {
      // Si se editó la finca, actualizar el stream
      setState(() {
        _farmStream = _farmService.getFarm(widget.farm.id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Farm?>(
      stream: _farmStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: Text(widget.farm.name),
              backgroundColor: Colors.brown[700],
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: Text(widget.farm.name),
              backgroundColor: Colors.brown[700],
            ),
            body: Center(
              child: Text(
                "Error al cargar la información: ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        }

        final farm = snapshot.data;
        if (farm == null) {
          return Scaffold(
            appBar: AppBar(
              title: Text(widget.farm.name),
              backgroundColor: Colors.brown[700],
            ),
            body: const Center(
              child: Text("No se encontró la finca"),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(farm.name),
            backgroundColor: Colors.brown[700],
            actions: [
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      _navegarAEditarFinca(farm);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('Editar Finca'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Información básica de la finca
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
                
                const SizedBox(height: 16),

                // Botón de editar finca
                Card(
                  elevation: 2,
                  child: InkWell(
                    onTap: () => _navegarAEditarFinca(farm),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.edit, color: Colors.blue),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Editar Información",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "Modificar datos básicos de la finca",
                                  style: TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 16),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Sección de lotes
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
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.grass, color: Colors.green),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Lotes",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "${farm.plots.length} lotes registrados",
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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

                // Estadísticas rápidas
                if (farm.plots.isNotEmpty) ...[
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Resumen de Lotes",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildEstadisticaRow(
                            "Total de hectáreas en lotes:",
                            "${farm.plots.fold<double>(0, (sum, plot) => sum + plot.hectares).toStringAsFixed(2)} ha",
                          ),
                          _buildEstadisticaRow(
                            "Total de plantas:",
                            "${farm.plots.fold<int>(0, (sum, plot) => sum + plot.plants)} matas",
                          ),
                          _buildEstadisticaRow(
                            "Variedades cultivadas:",
                            farm.plots.map((plot) => plot.variety).where((v) => v.isNotEmpty).toSet().join(", "),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEstadisticaRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              value,
              style: TextStyle(
                color: Colors.brown[700],
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}