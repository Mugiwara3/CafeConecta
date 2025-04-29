import 'package:flutter/material.dart';
import 'package:miapp_cafeconecta/controllers/auth_controller.dart';
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
  final TextEditingController _hectareasTotalesController = TextEditingController();
  final TextEditingController _hectareasCafeController = TextEditingController();
  final TextEditingController _alturaController = TextEditingController();
  final TextEditingController _departamentoController = TextEditingController();
  final TextEditingController _municipioController = TextEditingController();
  final TextEditingController _veredaController = TextEditingController();

  Future<void> _guardarFinca() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Obtener el usuario actual
        final authController = Provider.of<AuthController>(context, listen: false);
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
        
        // Crear objeto Farm basado en el modelo
        final farm = Farm(
          id: '', // El ID será asignado por Firestore
          name: _nombreController.text,
          hectares: double.tryParse(_hectareasTotalesController.text) ?? 0,
          altitude: double.tryParse(_alturaController.text) ?? 0,
          plots: [], // Inicialmente sin lotes
          ownerId: user.uid,
          createdAt: DateTime.now(),
          department: _departamentoController.text,
          municipality: _municipioController.text,
          village: _veredaController.text,
        );

        // Devolver el objeto Farm a HomeScreen
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
                  ),
                  _buildInputField(
                    controller: _hectareasTotalesController,
                    label: "Hectáreas totales",
                    icon: Icons.square_foot,
                    keyboardType: TextInputType.number,
                  ),
                  _buildInputField(
                    controller: _hectareasCafeController,
                    label: "Hectáreas de café",
                    icon: Icons.eco_outlined,
                    keyboardType: TextInputType.number,
                  ),
                  _buildInputField(
                    controller: _alturaController,
                    label: "Altura (msnm)",
                    icon: Icons.height,
                    keyboardType: TextInputType.number,
                  ),
                  _buildInputField(
                    controller: _departamentoController,
                    label: "Departamento",
                    icon: Icons.location_city,
                  ),
                  _buildInputField(
                    controller: _municipioController,
                    label: "Municipio",
                    icon: Icons.location_on,
                  ),
                  _buildInputField(
                    controller: _veredaController,
                    label: "Vereda",
                    icon: Icons.map,
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _guardarFinca,
                    icon: _isLoading 
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Icon(Icons.save),
                    label: Text(_isLoading ? "Guardando..." : "Guardar Finca"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
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
              child: const Center(
                child: CircularProgressIndicator(),
              ),
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
          validator: (value) => value == null || value.isEmpty
              ? "Este campo es obligatorio"
              : null,
        ),
      ),
    );
  }
}