import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:miapp_cafeconecta/ui/screens/auth/farm/registrarKilos/registrar_kilos.dart';
import 'package:miapp_cafeconecta/ui/screens/auth/farm/registrarKilos/widgets/trabajador.dart';
import 'package:miapp_cafeconecta/ui/widgets/provider/recoleccion_provider.dart';
import 'package:provider/provider.dart';
import 'package:miapp_cafeconecta/models/recoleccion_model.dart';

class RecoleccionPanel extends StatelessWidget {
  final int index;
  final Recoleccion recoleccion;

  const RecoleccionPanel({
    super.key,
    required this.index,
    required this.recoleccion,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RecoleccionProvider>(context);
    final isExpanded = provider.expandedPanels[index] ?? false;
    final totalGeneral = provider.calcularTotalGeneral(recoleccion.data, recoleccion.loteId);
    
    // Obtener el nombre del día de la semana en español
    final fecha = DateFormat('yyyy-MM-dd').parse(recoleccion.fecha);
    final diaSemana = DateFormat('EEEE', 'es_ES').format(fecha).capitalize();
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          // Encabezado del panel
          ListTile(
            title: Text('${recoleccion.loteId} - ${recoleccion.fecha} ($diaSemana)'),
            subtitle: Text('Total recolectado: ${totalGeneral.toStringAsFixed(1)} kg'),
            trailing: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
            onTap: () {
              provider.toggleExpandedPanel(index);
            },
          ),
          
          // Contenido expandible
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: provider.filtrarTrabajadores(recoleccion.loteId).map((trabajador) {
                  return TrabajadorWidget(
                    recoleccionIndex: index,
                    trabajador: trabajador,
                    datosTrabajador: recoleccion.data[trabajador],
                    loteId: recoleccion.loteId,
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}