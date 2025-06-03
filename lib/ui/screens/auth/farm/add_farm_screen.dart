import 'package:flutter/material.dart';
import 'package:miapp_cafeconecta/controllers/auth_controller.dart';
import 'package:miapp_cafeconecta/ui/screens/auth/farm/widgets/colombia_data.dart';
import 'package:miapp_cafeconecta/models/farm_model.dart';
import 'package:provider/provider.dart';

class AgregarFincaScreen extends StatefulWidget {
  const AgregarFincaScreen({super.key});

  @override
  State<AgregarFincaScreen> createState() => _AgregarFincaScreenState();
}

class _AgregarFincaScreenState extends State<AgregarFincaScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _hectareasTotalesController =
      TextEditingController();
  final TextEditingController _hectareasCafeController =
      TextEditingController();
  final TextEditingController _alturaController = TextEditingController();
  final TextEditingController _veredaController = TextEditingController();

  String? _departamentoSeleccionado;
  String? _municipioSeleccionado;
  List<String> _municipiosDisponibles = [];

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

  Future<void> _guardarFinca() async {
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

        final farm = Farm(
          id: '',
          name: _nombreController.text,
          hectares: double.tryParse(_hectareasTotalesController.text) ?? 0,
          coffeeHectares: double.tryParse(_hectareasCafeController.text) ?? 0,
          altitude: double.tryParse(_alturaController.text) ?? 0,
          plots: [],
          ownerId: user.uid,
          createdAt: DateTime.now(),
          department: _departamentoSeleccionado ?? '',
          municipality: _municipioSeleccionado ?? '',
          village: _veredaController.text,
        );

        Navigator.pop(context, farm);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Agregar Finca"),
        backgroundColor: Colors.brown[700],
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
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _guardarFinca,
                    icon:
                        _isLoading
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                            : const Icon(Icons.save),
                    label: Text(_isLoading ? "Guardando..." : "Guardar Finca"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
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
          items:
              ColombiaData.departamentos.map<DropdownMenuItem<String>>((
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
          validator:
              (value) => value == null ? "Seleccione un departamento" : null,
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
          items:
              _municipiosDisponibles.map<DropdownMenuItem<String>>((
                String value,
              ) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
          onChanged:
              _departamentoSeleccionado == null
                  ? null
                  : (String? newValue) {
                    setState(() {
                      _municipioSeleccionado = newValue;
                    });
                  },
          validator:
              (value) =>
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
