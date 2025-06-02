import 'package:flutter/material.dart';
import 'package:miapp_cafeconecta/models/farm_model.dart';
import 'package:miapp_cafeconecta/ui/screens/auth/farm/widgets/service/farm_service.dart';

class EditarLoteScreen extends StatefulWidget {
  final Farm farm;
  final int plotIndex;
  final FarmPlot plot;

  const EditarLoteScreen({
    super.key,
    required this.farm,
    required this.plotIndex,
    required this.plot,
  });

  @override
  State<EditarLoteScreen> createState() => _EditarLoteScreenState();
}

class _EditarLoteScreenState extends State<EditarLoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final FarmService _farmService = FarmService();
  bool _isLoading = false;

  late final TextEditingController _nombreController;
  late final TextEditingController _alturaController;
  late final TextEditingController _variedadController;
  late final TextEditingController _hectareasController;
  late final TextEditingController _matasController;

  // Lista de variedades de café comunes en Colombia
  final List<String> _variedadesCafe = [
    'Castillo',
    'Colombia',
    'Caturra',
    'Typica',
    'Bourbon',
    'Geisha',
    'Maragogipe',
    'Tabi',
    'Cenicafé 1',
    'Otra',
  ];

  String? _variedadSeleccionada;

  @override
  void initState() {
    super.initState();
    _inicializarControladores();
  }

  void _inicializarControladores() {
    _nombreController = TextEditingController(text: widget.plot.name);
    _alturaController = TextEditingController(text: widget.plot.altitude.toString());
    _variedadController = TextEditingController(text: widget.plot.variety);
    _hectareasController = TextEditingController(text: widget.plot.hectares.toString());
    _matasController = TextEditingController(text: widget.plot.plants.toString());

    // Verificar si la variedad está en la lista predefinida
    if (_variedadesCafe.contains(widget.plot.variety)) {
      _variedadSeleccionada = widget.plot.variety;
    } else if (widget.plot.variety.isNotEmpty) {
      _variedadSeleccionada = 'Otra';
      _variedadController.text = widget.plot.variety;
    }
  }

  Future<void> _guardarCambios() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final loteActualizado = FarmPlot(
          name: _nombreController.text.trim(),
          hectares: double.tryParse(_hectareasController.text) ?? 0,
          altitude: double.tryParse(_alturaController.text) ?? 0,
          variety: _variedadSeleccionada == 'Otra' 
              ? _variedadController.text.trim() 
              : _variedadSeleccionada ?? '',
          plants: int.tryParse(_matasController.text) ?? 0,
        );

        // Crear nueva lista de lotes con la actualización
        final lotesActualizados = List<FarmPlot>.from(widget.farm.plots);
        lotesActualizados[widget.plotIndex] = loteActualizado;

        // Crear finca actualizada
        final farmActualizada = Farm(
          id: widget.farm.id,
          name: widget.farm.name,
          hectares: widget.farm.hectares,
          altitude: widget.farm.altitude,
          plots: lotesActualizados,
          ownerId: widget.farm.ownerId,
          createdAt: widget.farm.createdAt,
          department: widget.farm.department,
          municipality: widget.farm.municipality,
          village: widget.farm.village,
        );

        await _farmService.updateFarm(farmActualizada);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("¡Lote actualizado con éxito!"),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, loteActualizado);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error al actualizar: ${e.toString()}"),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _confirmarEliminacion() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmar eliminación"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("¿Estás seguro de que quieres eliminar el lote '${widget.plot.name}'?"),
            const SizedBox(height: 8),
            const Text(
              "Esta acción también eliminará:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text("• Todos los registros de recolección de este lote"),
            const Text("• Todos los trabajadores asociados a este lote"),
            const SizedBox(height: 8),
            const Text(
              "Esta acción no se puede deshacer.",
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Eliminar"),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await _eliminarLote();
    }
  }

  Future<void> _eliminarLote() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _farmService.removePlotFromFarm(widget.farm.id, widget.plotIndex);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Lote eliminado correctamente"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, 'deleted');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al eliminar lote: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _alturaController.dispose();
    _variedadController.dispose();
    _hectareasController.dispose();
    _matasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar Lote"),
        backgroundColor: Colors.green[800],
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _isLoading ? null : _confirmarEliminacion,
            tooltip: "Eliminar lote",
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Información del lote
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Información del Lote",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _nombreController,
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
                            controller: _hectareasController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: "Hectáreas",
                              prefixIcon: Icon(Icons.landscape),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) =>
                                value!.isEmpty ? "Ingrese las hectáreas" : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _alturaController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: "Altura (msnm)",
                              prefixIcon: Icon(Icons.terrain),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) =>
                                value!.isEmpty ? "Ingrese la altura" : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _matasController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: "Número de matas",
                              prefixIcon: Icon(Icons.format_list_numbered),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) =>
                                value!.isEmpty ? "Ingrese el número de matas" : null,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Variedad de café
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Variedad de Café",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _variedadSeleccionada,
                            decoration: const InputDecoration(
                              labelText: "Variedad de café",
                              prefixIcon: Icon(Icons.local_florist),
                              border: OutlineInputBorder(),
                            ),
                            items: _variedadesCafe.map((String variedad) {
                              return DropdownMenuItem<String>(
                                value: variedad,
                                child: Text(variedad),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _variedadSeleccionada = newValue;
                                if (newValue != 'Otra') {
                                  _variedadController.clear();
                                }
                              });
                            },
                            validator: (value) =>
                                value == null ? "Seleccione una variedad" : null,
                          ),
                          if (_variedadSeleccionada == 'Otra') ...[
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _variedadController,
                              decoration: const InputDecoration(
                                labelText: "Especifique la variedad",
                                prefixIcon: Icon(Icons.edit),
                                border: OutlineInputBorder(),
                                hintText: "Escriba el nombre de la variedad",
                              ),
                              validator: (value) => _variedadSeleccionada == 'Otra' &&
                                      (value == null || value.isEmpty)
                                  ? "Especifique la variedad"
                                  : null,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Botones de acción
                  Row(
                    children: [
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
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Botón de eliminar
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _isLoading ? null : _confirmarEliminacion,
                      icon: const Icon(Icons.delete_forever, color: Colors.red),
                      label: const Text(
                        "Eliminar Lote",
                        style: TextStyle(color: Colors.red),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 15),
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