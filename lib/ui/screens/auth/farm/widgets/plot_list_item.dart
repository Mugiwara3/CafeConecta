import 'package:flutter/material.dart';
import 'package:miapp_cafeconecta/models/farm_model.dart';

class LoteItemWidget extends StatelessWidget {
  final FarmPlot plot;
  final int index;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const LoteItemWidget({
    super.key,
    required this.plot,
    required this.index,
    this.onDelete,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      child: ExpansionTile(
        leading: const Icon(Icons.grass, color: Colors.green),
        title: Text(
          plot.name.isNotEmpty ? plot.name : 'Lote ${index + 1}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "${plot.hectares.toStringAsFixed(1)} ha • ${plot.altitude.toString()} msnm",
          style: TextStyle(color: Colors.grey[600]),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                onEdit?.call();
                break;
              case 'delete':
                _mostrarConfirmacionEliminacion(context);
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
                  Text('Editar'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Eliminar'),
                ],
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow(Icons.landscape, "Área", "${plot.hectares.toStringAsFixed(2)} hectáreas"),
                const SizedBox(height: 8),
                _buildDetailRow(Icons.terrain, "Altitud", "${plot.altitude.toString()} msnm"),
                const SizedBox(height: 8),
                _buildDetailRow(Icons.local_florist, "Variedad", plot.variety.isNotEmpty ? plot.variety : "No especificada"),
                const SizedBox(height: 8),
                _buildDetailRow(Icons.format_list_numbered, "Plantas", "${plot.plants} matas"),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text("Editar"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _mostrarConfirmacionEliminacion(context),
                        icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                        label: const Text(
                          "Eliminar",
                          style: TextStyle(color: Colors.red),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.green[700]),
        const SizedBox(width: 12),
        Text(
          "$label: ",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }

  void _mostrarConfirmacionEliminacion(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmar eliminación"),
        content: Text("¿Estás seguro de que quieres eliminar el lote '${plot.name}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete?.call();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Eliminar"),
          ),
        ],
      ),
    );
  }
}