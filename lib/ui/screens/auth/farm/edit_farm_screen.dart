import 'package:flutter/material.dart';
import 'package:miapp_cafeconecta/ui/screens/auth/farm/widgets/colombia_data.dart';
import 'package:miapp_cafeconecta/models/farm_model.dart';
import 'package:miapp_cafeconecta/ui/screens/auth/farm/widgets/service/farm_service.dart';

class EditarFincaScreen extends StatefulWidget {
  final Farm farm;

  const EditarFincaScreen({super.key, required this.farm});

  @override
  State<EditarFincaScreen> createState() => _EditarFincaScreenState();
}

class _EditarFincaScreenState extends State<EditarFincaScreen> {
  final _formKey = GlobalKey<FormState>();
  final FarmService _farmService = FarmService();
  bool _isLoading = false;

  late final TextEditingController _nombreController;
  late final TextEditingController _hectareasController;
  late final TextEditingController _alturaController;
  late final TextEditingController _veredaController;

  String? _departamentoSeleccionado;
  String? _municipioSeleccionado;
  List<String> _municipiosDisponibles = [];

  @override
  void initState() {
    super.initState();
    _inicializarControladores();
    _inicializarUbicacion();
  }

  void _inicializarControladores() {
    _nombreController = TextEditingController(text: widget.farm.name);
    _hectareasController = TextEditingController(text: widget.farm.hectares.toString());
    _alturaController = TextEditingController(text: widget.farm.altitude.toString());
    _veredaController = TextEditingController(text: widget.farm.village);
  }

  void _inicializarUbicacion() {
    // Debug: verificar datos de entrada
    debugPrint("=== INICIALIZAR UBICACIÓN ===");
    debugPrint("Department from farm: '${widget.farm.department}'");
    debugPrint("Municipality from farm: '${widget.farm.municipality}'");
    
    // Normalizar departamento
    if (widget.farm.department.isNotEmpty) {
      _departamentoSeleccionado = _encontrarDepartamentoCoincidente(widget.farm.department);
      debugPrint("Departamento encontrado: '$_departamentoSeleccionado'");
    }

    // Si se encontró departamento, cargar municipios
    if (_departamentoSeleccionado != null) {
      _municipiosDisponibles = ColombiaData.getMunicipios(_departamentoSeleccionado!);
      
      // Normalizar municipio
      if (widget.farm.municipality.isNotEmpty) {
        _municipioSeleccionado = _encontrarMunicipioCoincidente(widget.farm.municipality);
        debugPrint("Municipio encontrado: '$_municipioSeleccionado'");
      }
    }
    
    debugPrint("==============================");
  }

  String? _encontrarDepartamentoCoincidente(String departamentoBuscado) {
    // Buscar departamento ignorando mayúsculas/minúsculas
    for (String dept in ColombiaData.departamentos) {
      if (dept.toLowerCase().trim() == departamentoBuscado.toLowerCase().trim()) {
        return dept;
      }
    }
    
    // Si no se encuentra exacto, buscar por similitud
    for (String dept in ColombiaData.departamentos) {
      if (dept.toLowerCase().contains(departamentoBuscado.toLowerCase()) ||
          departamentoBuscado.toLowerCase().contains(dept.toLowerCase())) {
        return dept;
      }
    }
    
    return null;
  }

  String? _encontrarMunicipioCoincidente(String municipioBuscado) {
    if (_departamentoSeleccionado == null) return null;
    
    for (String municipio in _municipiosDisponibles) {
      if (municipio.toLowerCase().trim() == municipioBuscado.toLowerCase().trim()) {
        return municipio;
      }
    }
    
    // Si no se encuentra exacto, buscar por similitud
    for (String municipio in _municipiosDisponibles) {
      if (municipio.toLowerCase().contains(municipioBuscado.toLowerCase()) ||
          municipioBuscado.toLowerCase().contains(municipio.toLowerCase())) {
        return municipio;
      }
    }
    
    return null;
  }

  void _actualizarMunicipios(String? departamento) {
    if (departamento != null) {
      setState(() {
        _municipiosDisponibles = ColombiaData.getMunicipios(departamento);
        _municipioSeleccionado = null; // Reset municipio cuando cambia departamento
      });
    }
  }

  Future<void> _guardarCambios() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final farmActualizada = Farm(
          id: widget.farm.id,
          name: _nombreController.text.trim(),
          hectares: double.tryParse(_hectareasController.text) ?? widget.farm.hectares,
          altitude: double.tryParse(_alturaController.text) ?? widget.farm.altitude,
          plots: widget.farm.plots, // Mantener los lotes existentes
          ownerId: widget.farm.ownerId,
          createdAt: widget.farm.createdAt,
          department: _departamentoSeleccionado ?? widget.farm.department,
          municipality: _municipioSeleccionado ?? widget.farm.municipality,
          village: _veredaController.text.trim(),
        );

        debugPrint("Actualizando finca con datos:");
        debugPrint("- Department: '${farmActualizada.department}'");
        debugPrint("- Municipality: '${farmActualizada.municipality}'");

        await _farmService.updateFarm(farmActualizada);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("¡Finca actualizada con éxito!"),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          
          await Future.delayed(const Duration(milliseconds: 500));
          Navigator.pop(context, farmActualizada);
        }
      } catch (e) {
        debugPrint("Error al actualizar finca: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error al actualizar: ${e.toString()}"),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
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
            const Text("¿Estás seguro de que quieres eliminar esta finca?"),
            const SizedBox(height: 8),
            const Text(
              "Esta acción también eliminará:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text("• Todos los lotes (${widget.farm.plots.length})"),
            const Text("• Todos los registros de recolección"),
            const Text("• Todos los trabajadores asociados"),
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
      await _eliminarFinca();
    }
  }

  Future<void> _eliminarFinca() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _farmService.deleteFarm(widget.farm.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Finca eliminada correctamente"),
            backgroundColor: Colors.green,
          ),
        );
        
        Navigator.pop(context, 'deleted');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al eliminar finca: ${e.toString()}"),
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
    _hectareasController.dispose();
    _alturaController.dispose();
    _veredaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar Finca"),
        backgroundColor: Colors.brown[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _isLoading ? null : _confirmarEliminacion,
            tooltip: "Eliminar finca",
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Información básica
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Información Básica",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildInputField(
                            controller: _nombreController,
                            label: "Nombre de la finca",
                            icon: Icons.park,
                          ),
                          _buildInputField(
                            controller: _hectareasController,
                            label: "Hectáreas totales",
                            icon: Icons.square_foot,
                            keyboardType: TextInputType.number,
                          ),
                          _buildInputField(
                            controller: _alturaController,
                            label: "Altura (msnm)",
                            icon: Icons.height,
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Ubicación
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Ubicación",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildDepartamentoDropdown(),
                          _buildMunicipioDropdown(),
                          _buildInputField(
                            controller: _veredaController,
                            label: "Vereda",
                            icon: Icons.map,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Información de lotes
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Lotes Registrados",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Total: ${widget.farm.plots.length} lotes",
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Para modificar lotes, ve a la sección de detalles de la finca.",
                            style: TextStyle(
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
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
                            backgroundColor: Colors.brown[700],
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
                        "Eliminar Finca",
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

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            icon: Icon(icon, color: Colors.brown[400]),
            labelText: label,
            border: InputBorder.none,
          ),
          validator: (value) =>
              value == null || value.isEmpty ? "Este campo es obligatorio" : null,
        ),
      ),
    );
  }

  Widget _buildDepartamentoDropdown() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: DropdownButtonFormField<String>(
          decoration: InputDecoration(
            icon: Icon(Icons.location_city, color: Colors.brown[400]),
            labelText: "Departamento",
            border: InputBorder.none,
          ),
          isExpanded: true,
          value: _departamentoSeleccionado,
          hint: const Text("Seleccione un departamento"),
          items: ColombiaData.departamentos.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _departamentoSeleccionado = newValue;
              _municipioSeleccionado = null;
              _actualizarMunicipios(newValue);
            });
          },
          validator: (value) => value == null ? "Seleccione un departamento" : null,
        ),
      ),
    );
  }

  Widget _buildMunicipioDropdown() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: DropdownButtonFormField<String>(
          decoration: InputDecoration(
            icon: Icon(Icons.location_on, color: Colors.brown[400]),
            labelText: "Municipio",
            border: InputBorder.none,
          ),
          isExpanded: true,
          value: _municipioSeleccionado,
          hint: Text(
            _departamentoSeleccionado == null
                ? "Primero seleccione un departamento"
                : "Seleccione un municipio",
          ),
          items: _municipiosDisponibles.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: _departamentoSeleccionado == null
              ? null
              : (String? newValue) {
                  setState(() {
                    _municipioSeleccionado = newValue;
                  });
                },
          validator: (value) =>
              _departamentoSeleccionado != null && value == null
                  ? "Seleccione un municipio"
                  : null,
          disabledHint: const Text("Seleccione primero un departamento"),
        ),
      ),
    );
  }
}