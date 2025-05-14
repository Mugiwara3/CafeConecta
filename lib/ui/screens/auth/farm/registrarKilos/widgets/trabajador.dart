import 'package:flutter/material.dart';
import 'package:miapp_cafeconecta/ui/widgets/provider/recoleccion_provider.dart';
import 'package:provider/provider.dart';

class TrabajadorWidget extends StatelessWidget {
  final int recoleccionIndex;
  final String trabajador;
  final Map<String, dynamic>? datosTrabajador;
  final String loteId;

  const TrabajadorWidget({
    super.key,
    required this.recoleccionIndex,
    required this.trabajador,
    required this.datosTrabajador,
    required this.loteId,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RecoleccionProvider>(context);
    final isExpanded = provider.expandedTrabajadores['$loteId:$trabajador'] ?? false;
    
    // Valores por defecto si no existen
    final mananaValue = datosTrabajador?['manana'] ?? '';
    final tardeValue = datosTrabajador?['tarde'] ?? '';
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          // Encabezado expandible
          ListTile(
            title: Text(trabajador),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Total: ${datosTrabajador != null ? provider.calcularTotalTrabajador(datosTrabajador!) : "0.0"} kg',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
              ],
            ),
            onTap: () {
              provider.toggleExpandedTrabajador(loteId, trabajador);
            },
          ),
          
          // Panel expandible con los campos simplificados
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Campo para mañana
                  Row(
                    children: [
                      const Expanded(
                        flex: 2,
                        child: Text('Mañana:'),
                      ),
                      Expanded(
                        flex: 3,
                        child: _buildInputField(
                          context,
                          mananaValue,
                          (value) => provider.actualizarValor(recoleccionIndex, trabajador, 'manana', value),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Campo para tarde
                  Row(
                    children: [
                      const Expanded(
                        flex: 2,
                        child: Text('Tarde:'),
                      ),
                      Expanded(
                        flex: 3,
                        child: _buildInputField(
                          context,
                          tardeValue,
                          (value) => provider.actualizarValor(recoleccionIndex, trabajador, 'tarde', value),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // Widget para crear un campo de entrada numérico
  Widget _buildInputField(
    BuildContext context,
    String initialValue, 
    Function(String) onChanged,
    {String hintText = ''}
  ) {
    final controller = TextEditingController(text: initialValue);
    
    // Asegurarse de que el cursor se posicione al final del texto
    controller.selection = TextSelection.fromPosition(
      TextPosition(offset: controller.text.length),
    );
    
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        isDense: true,
        border: const OutlineInputBorder(),
      ),
      textAlign: TextAlign.center,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: onChanged,
    );
  }
}