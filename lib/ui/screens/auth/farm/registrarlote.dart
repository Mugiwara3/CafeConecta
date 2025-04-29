import 'package:flutter/material.dart';
import 'package:miapp_cafeconecta/models/farm_model.dart';

class RegistrarLoteScreen extends StatefulWidget {
  const RegistrarLoteScreen({super.key});

  @override
  State<RegistrarLoteScreen> createState() => _RegistrarLoteScreenState();
}

class _RegistrarLoteScreenState extends State<RegistrarLoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController alturaController = TextEditingController();
  final TextEditingController variedadController = TextEditingController();
  final TextEditingController matasController = TextEditingController();

  void _guardarLote() {
  if (_formKey.currentState!.validate()) {
    final nuevoLote = FarmPlot(
      name: nombreController.text,
      hectares: double.tryParse(matasController.text) ?? 0,
      altitude: double.tryParse(alturaController.text) ?? 0,
      variety: variedadController.text,
      plants: int.tryParse(matasController.text) ?? 0,
    );
    Navigator.pop(context, nuevoLote);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Registrar Lote"),
        backgroundColor: Colors.green[800],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Image.asset('lib/ui/screens/assets/images/logo.png',
                  height: 100), // Asegúrate que exista
              const SizedBox(height: 20),
              TextFormField(
                controller: nombreController,
                decoration: const InputDecoration(
                  labelText: "Nombre del lote",
                  prefixIcon: Icon(Icons.grass),
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? "Ingrese el nombre del lote" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: alturaController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Altura",
                  prefixIcon: Icon(Icons.terrain),
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? "Ingrese la altura" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: variedadController,
                decoration: const InputDecoration(
                  labelText: "Variedad de café",
                  prefixIcon: Icon(Icons.local_florist),
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? "Ingrese la variedad" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: matasController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Número de matas",
                  prefixIcon: Icon(Icons.format_list_numbered),
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? "Ingrese el número de matas" : null,
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _guardarLote,
                icon: const Icon(Icons.save),
                label: const Text("Guardar Lote"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
