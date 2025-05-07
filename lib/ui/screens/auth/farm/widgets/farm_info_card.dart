import 'package:flutter/material.dart';
import 'package:miapp_cafeconecta/models/farm_model.dart';

class FincaInfoWidget extends StatelessWidget {
  final Map<String, dynamic> finca;
  final Farm farm;

  const FincaInfoWidget({
    super.key, 
    required this.finca, 
    required this.farm
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.park, size: 40, color: Colors.green),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    finca['nombre'],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.square_foot, "Hectáreas: ${finca['hectareas']}"),
            _buildInfoRow(Icons.terrain, "Altura: ${finca['altura']} msnm"),
            if (finca['departamento'] != null) 
              _buildInfoRow(Icons.location_city, "Departamento: ${finca['departamento']}"),
            if (finca['municipio'] != null)
              _buildInfoRow(Icons.location_on, "Municipio: ${finca['municipio']}"),
            if (finca['vereda'] != null)
              _buildInfoRow(Icons.map, "Vereda: ${finca['vereda']}"),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }
}