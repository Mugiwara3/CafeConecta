import 'package:flutter/material.dart';
import 'package:miapp_cafeconecta/controllers/auth_controller.dart';
import 'package:miapp_cafeconecta/ui/screens/auth/farm/widgets/colombia_data.dart';
import 'package:miapp_cafeconecta/models/farm_model.dart';
import 'package:provider/provider.dart';

class EditarFincaScreen extends StatefulWidget {
  final Farm farm;

  const EditarFincaScreen({super.key, required this.farm});

  @override
  State<EditarFincaScreen> createState() => _EditarFincaScreenState();
}

class _EditarFincaScreenState extends State<EditarFincaScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late TextEditingController _nombreController;
  late TextEditingController _hectareasTotalesController;
  late TextEditingController _hectareasCafeController;
  late TextEditingController _alturaController;
  late TextEditingController _veredaController;

  String? _departamentoSeleccionado;
  String? _municipioSeleccionado;
  List<String> _municipiosDisponibles = [];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadInitialData();
  }

  void _initializeControllers() {
    _nombreController = TextEditingController(text: widget.farm.name);
    _hectareasTotalesController = TextEditingController(text: widget.farm.hectares.toString());
    _hectareasCafeController = TextEditingController(text: widget.farm.coffeeHectares.toString());
    _alturaController = TextEditingController(text: widget.farm.altitude.toString());
    _veredaController = TextEditingController(text: widget.farm.village);
  }

  void _loadInitialData() {
    _departamentoSeleccionado = widget.farm.department.isNotEmpty ? widget.farm.department : null;
    _municipioSeleccionado = widget.farm.municipality.isNotEmpty ? widget.farm.municipality : null;
    
    if (_departamentoSeleccionado != null) {
      _municipiosDisponibles = ColombiaData.getMunicipios(_departamentoSeleccionado!);
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _hectareasTotalesController.dispose();
    _hectareasCafeController.dispose();
    _alturaController.dispose();
    _veredaController.dispose();
    super.dispose();
  }

  void _actualizarMunicipios(String? departamento) {
    if (departamento != null) {
      setState(() {
        _municipiosDisponibles = ColombiaData.getMunicipios(departamento);
        _municipioSeleccionado = null;
      });
    }
  }

  // Validación para solo letras y espacios
  bool _soloLetras(String value) {
    return RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$').hasMatch(value);
  }

  // Validación para números enteros positivos
  bool _esEnteroPositivo(String value) {
    try {
      return int.parse(value) > 0;
    } catch (e) {
      return false;
    }
  }

  // Validación para números positivos (enteros o decimales)
  bool _esNumeroPositivo(String value) {
    try {
      return double.parse(value) > 0;
    } catch (e) {
      return false;
    }
  }

  Future<void> _guardarCambios() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final authController = Provider.of<AuthController>(
          context,
          listen: false,
        );
        final user = authController.currentUser;

        if (user == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Error: Usuario no autenticado"),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        final updatedFarm = Farm(
          id: widget.farm.id,
          name: _nombreController.text,
          hectares: double.tryParse(_hectareasTotalesController.text) ?? 0,
          coffeeHectares: double.tryParse(_hectareasCafeController.text) ?? 0,
          altitude: double.tryParse(_alturaController.text) ?? 0,
          plots: widget.farm.plots, // Mantenemos los lotes existentes
          ownerId: user.uid,
          createdAt: widget.farm.createdAt, // Mantenemos la fecha original
          department: _departamentoSeleccionado ?? '',
          municipality: _municipioSeleccionado ?? '',
          village: _veredaController.text,
        );

        Navigator.pop(context, updatedFarm);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error al guardar: ${e.toString()}"),
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
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red[600]),
            const SizedBox(width: 8),
            const Text('Eliminar Finca'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¿Estás seguro de que deseas eliminar la finca "${widget.farm.name}"?',
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
                '• Todos los datos de la finca\n'
                '• Todos los lotes asociados\n'
                '• Todos los registros de recolección\n'
                '• Todos los trabajadores asignados\n\n'
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
            child: const Text('Eliminar Finca'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      Navigator.pop(context, 'delete');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar Finca"),
        backgroundColor: Colors.brown[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: _confirmarEliminacion,
            tooltip: 'Eliminar Finca',
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
                  _buildInputField(
                    controller: _nombreController,
                    label: "Nombre de la finca",
                    icon: Icons.park,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Este campo es obligatorio';
                      }
                      if (!_soloLetras(value)) {
                        return 'Solo se permiten letras y espacios';
                      }
                      return null;
                    },
                  ),
                  _buildInputField(
                    controller: _hectareasTotalesController,
                    label: "Hectáreas totales",
                    icon: Icons.square_foot,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Este campo es obligatorio';
                      }
                      if (!_esEnteroPositivo(value)) {
                        return 'Ingrese un número entero positivo';
                      }
                      return null;
                    },
                  ),
                  _buildInputField(
                    controller: _hectareasCafeController,
                    label: "Hectáreas de café",
                    icon: Icons.eco_outlined,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Este campo es obligatorio';
                      }
                      if (!_esEnteroPositivo(value)) {
                        return 'Ingrese un número entero positivo';
                      }
                      return null;
                    },
                  ),
                  _buildInputField(
                    controller: _alturaController,
                    label: "Altura (msnm)",
                    icon: Icons.height,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Este campo es obligatorio';
                      }
                      if (!_esNumeroPositivo(value)) {
                        return 'Ingrese un número positivo';
                      }
                      return null;
                    },
                  ),
                  _buildDepartamentoDropdown(),
                  _buildMunicipioDropdown(),
                  _buildInputField(
                    controller: _veredaController,
                    label: "Vereda",
                    icon: Icons.map,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Este campo es obligatorio';
                      }
                      if (!_soloLetras(value)) {
                        return 'Solo se permiten letras y espacios';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isLoading ? null : () => Navigator.pop(context),
                          icon: const Icon(Icons.cancel),
                          label: const Text("Cancelar"),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
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
                            backgroundColor: Colors.brown[700],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                    ],
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

  Widget _buildDepartamentoDropdown() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
          icon: const Icon(Icons.arrow_drop_down),
          items: ColombiaData.departamentos.map<DropdownMenuItem<String>>((
            String value,
          ) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _departamentoSeleccionado = newValue;
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
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
          icon: const Icon(Icons.arrow_drop_down),
          items: _municipiosDisponibles.map<DropdownMenuItem<String>>((
            String value,
          ) {
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
          hint: Text(
            _departamentoSeleccionado == null
                ? "Primero seleccione un departamento"
                : "Seleccione un municipio",
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            icon: Icon(icon, color: Colors.brown[400]),
            labelText: label,
            border: InputBorder.none,
          ),
          validator: validator,
        ),
      ),
    );
  }
}