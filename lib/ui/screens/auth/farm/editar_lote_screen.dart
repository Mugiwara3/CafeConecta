import 'package:flutter/material.dart';
import 'package:miapp_cafeconecta/models/farm_model.dart';

class EditarLoteScreen extends StatefulWidget {
  final FarmPlot plot;
  final int plotIndex;

  const EditarLoteScreen({
    super.key, 
    required this.plot,
    required this.plotIndex,
  });

  @override
  State<EditarLoteScreen> createState() => _EditarLoteScreenState();
}

class _EditarLoteScreenState extends State<EditarLoteScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late TextEditingController nombreController;
  late TextEditingController alturaController;
  late TextEditingController variedadController;
  late TextEditingController hectareasController;
  late TextEditingController matasController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    nombreController = TextEditingController(text: widget.plot.name);
    alturaController = TextEditingController(text: widget.plot.altitude.toString());
    variedadController = TextEditingController(text: widget.plot.variety);
    hectareasController = TextEditingController(text: widget.plot.hectares.toString());
    matasController = TextEditingController(text: widget.plot.plants.toString());
  }

  @override
  void dispose() {
    nombreController.dispose();
    alturaController.dispose();
    variedadController.dispose();
    hectareasController.dispose();
    matasController.dispose();
    super.dispose();
  }

  void _guardarCambios() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final loteActualizado = FarmPlot(
        name: nombreController.text,
        hectares: double.tryParse(hectareasController.text) ?? 0,
        altitude: double.tryParse(alturaController.text) ?? 0,
        variety: variedadController.text,
        plants: int.tryParse(matasController.text) ?? 0,
      );

      Navigator.pop(context, {
        'action': 'update',
        'plot': loteActualizado,
        'index': widget.plotIndex,
      });
    }
  }

  Future<void> _confirmarEliminacion() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red[600]),
            const SizedBox(width: 8),
            const Text('Eliminar Lote'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¿Estás seguro de que deseas eliminar el lote "${widget.plot.name}"?',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: const Text(
                '⚠️ ADVERTENCIA: Esta acción eliminará permanentemente:\n\n'
                '• Todos los datos del lote\n'
                '• Todos los registros de recolección asociados\n'
                '• Todos los trabajadores asignados a este lote\n\n'
                'Esta acción NO se puede deshacer.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar Lote'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      Navigator.pop(context, {
        'action': 'delete',
        'index': widget.plotIndex,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar Lote"),
        backgroundColor: Colors.green[800],
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: _confirmarEliminacion,
            tooltip: 'Eliminar Lote',
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  // Logo de la app
                  Center(
                    child: Image.asset(
                      'lib/ui/screens/assets/images/logo.png',
                      height: 100,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                            color: Colors.green[100],
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Icon(
                            Icons.grass,
                            size: 50,
                            color: Colors.green[800],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Información del lote actual
                  Card(
                    color: Colors.green[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Editando: ${widget.plot.name}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[800],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Puedes modificar cualquier campo o eliminar este lote',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),

                  // Campos del formulario
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
                      labelText: "Altura (msnm)",
                      prefixIcon: Icon(Icons.terrain),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) return "Ingrese la altura";
                      if (double.tryParse(value) == null || double.parse(value) <= 0) {
                        return "Ingrese una altura válida";
                      }
                      return null;
                    },
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
                    controller: hectareasController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: "Hectáreas",
                      prefixIcon: Icon(Icons.landscape),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) return "Ingrese las hectáreas";
                      if (double.tryParse(value) == null || double.parse(value) <= 0) {
                        return "Ingrese un número válido mayor a 0";
                      }
                      return null;
                    },
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
                    validator: (value) {
                      if (value!.isEmpty) return "Ingrese el número de matas";
                      if (int.tryParse(value) == null || int.parse(value) <= 0) {
                        return "Ingrese un número entero mayor a 0";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),

                  // Botones de acción
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isLoading ? null : () => Navigator.pop(context),
                          icon: const Icon(Icons.cancel),
                          label: const Text("Cancelar"),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _guardarCambios,
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.save),
                          label: Text(_isLoading ? "Guardando..." : "Guardar Cambios"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Botón de eliminar como alternativa
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _confirmarEliminacion,
                      icon: const Icon(Icons.delete_forever, color: Colors.red),
                      label: const Text(
                        "Eliminar este lote",
                        style: TextStyle(color: Colors.red),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}