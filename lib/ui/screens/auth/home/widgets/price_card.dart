import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
  onPressed: () async {
    final url = Uri.parse('https://federaciondecafeteros.org/app/uploads/2019/10/precio_cafe.pdf');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      // Puedes mostrar un mensaje de error si no se puede abrir el enlace
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se puede abrir el enlace')),
      );
    }
  },
),
          ],
        ),
      ),
    );
  }
}
