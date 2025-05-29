import 'package:flutter/material.dart';
import 'package:miapp_cafeconecta/ui/screens/auth/price/precio_consulta_screen.dart';

class PriceCard extends StatelessWidget {
  const PriceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(30),
        ),
        width: double.infinity,
        child: Column(
          children: [
            const Text(
              "Consultar Precio del Café",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
              icon: const Icon(Icons.coffee, color: Colors.red),
              label: const Text(
                "Consultar",
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                // Navegar a la pantalla de consulta de precios
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PrecioConsultaScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
