import 'package:flutter/material.dart';
import 'package:miapp_cafeconecta/controllers/farm_controller.dart';
import 'package:miapp_cafeconecta/models/farm_model.dart';
import 'package:miapp_cafeconecta/ui/screens/auth/farm/registrarlote.dart';
import 'package:miapp_cafeconecta/ui/screens/auth/farm/widgets/farm_info_card.dart';
import 'package:miapp_cafeconecta/ui/screens/auth/farm/widgets/plot_list_item.dart';

class DetalleFincaScreen extends StatefulWidget {
  final Farm farm;

  const DetalleFincaScreen({super.key, required this.farm});

  @override
  State<DetalleFincaScreen> createState() => _DetalleFincaScreenState();
}

class _DetalleFincaScreenState extends State<DetalleFincaScreen> {
  late Farm _farm;
  final FarmController _farmController = FarmController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _farm = widget.farm;
  }

  Future<void> _addPlot(BuildContext context) async {
    final newPlot = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegistrarLoteScreen()),
    );

    if (newPlot != null && newPlot is Map<String, dynamic>) {
      setState(() => _isLoading = true);
      try {
        final updatedFarm = Farm(
          id: _farm.id,
          name: _farm.name,
          hectares: _farm.hectares,
          altitude: _farm.altitude,
          plots: [..._farm.plots, FarmPlot.fromMap(newPlot)],
          ownerId: _farm.ownerId,
          createdAt: _farm.createdAt,
          department: _farm.department,
          municipality: _farm.municipality,
          village: _farm.village,
        );

        await _farmController.updateFarm(updatedFarm);
        setState(() => _farm = updatedFarm);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al agregar lote: ${e.toString()}')),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deletePlot(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar Lote'),
        content: const Text('¿Estás seguro de eliminar este lote?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        final updatedPlots = List<Map<String, dynamic>>.from(_farm.plots)
          ..removeAt(index);
        final updatedFarm = Farm(
          id: _farm.id,
          name: _farm.name,
          hectares: _farm.hectares,
          altitude: _farm.altitude,
          plots: updatedPlots.map((plot) => FarmPlot.fromMap(plot)).toList(),
          ownerId: _farm.ownerId,
          createdAt: _farm.createdAt,
          department: _farm.department,
          municipality: _farm.municipality,
          village: _farm.village,
        );

        await _farmController.updateFarm(updatedFarm);
        setState(() => _farm = updatedFarm);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar lote: ${e.toString()}')),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalle de la Finca"),
        backgroundColor: Colors.brown[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _navigateToEditFarm(context),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FincaInfoWidget(finca: {
                    'nombre': _farm.name,
                    'hectareas': _farm.hectares,
                    'altura': _farm.altitude,
                    'departamento': _farm.department,
                    'municipio': _farm.municipality,
                    'vereda': _farm.village,
                  }, farm: _farm,),
                  const SizedBox(height: 24),
                  const Text(
                    "Lotes registrados:",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_farm.plots.isEmpty)
                    const Center(
                      child: Text(
                        "No hay lotes registrados.",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _farm.plots.length,
                      itemBuilder: (context, index) {
                        return LoteItemWidget(
                          lote: _farm.plots[index].toMap(),
                          onDelete: () => _deletePlot(index),
                        );
                      },
                    ),
                  const SizedBox(height: 24),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () => _addPlot(context),
                      icon: const Icon(Icons.add),
                      label: const Text("Añadir lote"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _navigateToEditFarm(BuildContext context) async {
    // Puedes implementar esto cuando tengas EditFarmScreen listo
  }
}
