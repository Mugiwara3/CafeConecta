import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:miapp_cafeconecta/ui/widgets/provider/recoleccion_provider.dart';
import 'package:provider/provider.dart';

class TrabajadorWidget extends StatelessWidget {
  final int recoleccionIndex;
  final String trabajador;
  final Map<String, dynamic>? datosTrabajador;
  final String loteld;

  const TrabajadorWidget({
    super.key,
    required this.recoleccionIndex,
    required this.trabajador,
    required this.datosTrabajador,
    required this.loteld, required String loteId,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RecoleccionProvider>(context);
    final isExpanded = provider.expandedTrabajadores["$loteld:$trabajador"] ?? false;
    
    final historial = provider.filtrarHistorial(
      provider.selectedFarmId, 
      loteld, 
      trabajador
    );
    final totalHistorico = historial.fold<double>(0, (sum, recoleccion) {
      final kilos = double.tryParse(recoleccion.data[trabajador]?['kilos'] ?? '0') ?? 0;
      return sum + kilos;
    });

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          ListTile(
            title: Text(trabajador),
            subtitle: Text('Total histórico: ${totalHistorico.toStringAsFixed(1)} kg'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Hoy: ${datosTrabajador != null ? 
                      provider.calcularTotalTrabajador(datosTrabajador!) : "0.0"} kg',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
              ],
            ),
            onTap: () {
              provider.toggleExpandedTrabajador(loteld, trabajador);
            },
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
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
                          datosTrabajador?['manana'] ?? '',
                          (value) => provider.actualizarValor(recoleccionIndex, trabajador, 'manana', value),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
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
                          datosTrabajador?['tarde'] ?? '',
                          (value) => provider.actualizarValor(recoleccionIndex, trabajador, 'tarde', value),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Historial reciente:', 
                    style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...historial.take(3).map((recoleccion) {
                    final kilos = recoleccion.data[trabajador]?['kilos'] ?? '0';
                    final fecha = DateFormat('MMM dd', 'es_ES').format(
                      DateFormat('yyyy-MM-dd').parse(recoleccion.fecha)
                    );
                    
                    return ListTile(
                      title: Text('$kilos kg'),
                      trailing: Text(fecha),
                      dense: true,
                    );
                  }).toList(),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInputField(
    BuildContext context,
    String initialValue,
    Function(String) onChanged, {
    String hintText = '',
  }) {
    final controller = TextEditingController(text: initialValue);
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