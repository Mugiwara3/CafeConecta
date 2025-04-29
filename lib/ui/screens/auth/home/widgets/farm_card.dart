import 'package:flutter/material.dart';
import 'package:miapp_cafeconecta/models/farm_model.dart';


class FarmCard extends StatelessWidget {
  final Farm farm;
  final VoidCallback onTap;

  const FarmCard({
    super.key,
    required this.farm,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Verificación segura de plots
    final plots = farm.plots;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado de la finca
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.agriculture, color: Colors.green),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          farm.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${farm.hectares.toStringAsFixed(1)} hectáreas • ${farm.altitude.toString()} msnm",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              
              // Sección de lotes
              const Text(
                "Lotes:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              
              if (plots.isEmpty)
                const Text(
                  "No hay lotes registrados",
                  style: TextStyle(color: Colors.grey),
                )
              else
                ..._buildPlotsList(plots),
            ],
          ),
        ),
      ),
    );
  }

  // Método para construir la lista de lotes de manera segura
  List<Widget> _buildPlotsList(List<dynamic> plots) {
    return plots.map((plot) {
      // Verificación segura de los campos del plot
      final plotName = plot['name']?.toString() ?? 'Lote sin nombre';
      final plotHectares = plot['hectares']?.toString() ?? '0';
      
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            const Icon(Icons.crop_square, size: 16, color: Colors.green),
            const SizedBox(width: 8),
            Text(
              "$plotName ($plotHectares ha)",
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      );
    }).toList();
  }
}