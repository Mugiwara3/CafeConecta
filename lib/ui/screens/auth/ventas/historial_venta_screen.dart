import 'package:flutter/material.dart';
import 'package:miapp_cafeconecta/ui/screens/auth/ventas/venta_controller.dart';
import 'package:miapp_cafeconecta/ui/screens/auth/ventas/venta_model.dart';
import 'package:provider/provider.dart';

class HistorialVentasScreen extends StatelessWidget {
  const HistorialVentasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ventaController = Provider.of<VentaController>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Ventas'),
        backgroundColor: Colors.brown[800],
      ),
      body: StreamBuilder<List<Venta>>(
        stream: ventaController.obtenerVentas(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final ventas = snapshot.data ?? [];

          if (ventas.isEmpty) {
            return const Center(child: Text('No hay ventas registradas'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: ventas.length,
            itemBuilder: (context, index) {
              final venta = ventas[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            venta.vendedor,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            venta.fecha,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Detalle:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      ...venta.cafes.map(
                        (cafe) => Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '- ${cafe['tipo']}: ${cafe['cantidad']} latas x \$${cafe['precio']} = \$${cafe['total']}',
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'Total: \$${venta.total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
