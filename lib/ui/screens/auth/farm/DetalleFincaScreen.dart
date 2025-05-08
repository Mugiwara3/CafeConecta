import 'package:flutter/material.dart';
import 'package:miapp_cafeconecta/models/farm_model.dart';
import 'package:miapp_cafeconecta/ui/screens/auth/farm/lotes_screen.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.farm.name),
        backgroundColor: Colors.brown[700],
      ),
      body: StreamBuilder<Farm?>(
        stream: _farmStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error al cargar la información: ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final farm = snapshot.data;
          if (farm == null) {
            return const Center(
              child: Text("No se encontró la finca"),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                              const Icon(Icons.grass, size: 30, color: Colors.green),
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
                // Aquí puedes agregar más tarjetas para otras funcionalidades
              ],
            ),
          );
        },
      ),
    );
  }
}