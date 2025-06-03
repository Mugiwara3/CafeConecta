import 'package:flutter/material.dart';

class LoteItemWidget extends StatelessWidget {
  final Map<String, dynamic> lote;
  final VoidCallback onDelete;

  const LoteItemWidget({super.key, required this.lote, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.grass, color: Colors.green),
        title: Text(lote['nombre'] ?? 'Sin nombre'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (lote['altura'] != null) Text("Altura: ${lote['altura']}"),
            if (lote['variedad'] != null) Text("Variedad: ${lote['variedad']}"),
            if (lote['matas'] != null) Text("Matas: ${lote['matas']}"),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
