import 'package:flutter/material.dart';
import 'package:miapp_cafeconecta/models/farm_model.dart';
import 'package:miapp_cafeconecta/ui/screens/auth/farm/registrarlote.dart';
import 'package:miapp_cafeconecta/ui/screens/auth/farm/editar_lote_screen.dart';
import 'package:miapp_cafeconecta/ui/screens/auth/farm/widgets/service/farm_service.dart';
import 'package:miapp_cafeconecta/ui/screens/auth/farm/widgets/plot_list_item.dart';

class LotesScreen extends StatefulWidget {
  final Farm farm;

  const LotesScreen({super.key, required this.farm});

  @override
  State<LotesScreen> createState() => _LotesScreenState();
}

class _LotesScreenState extends State<LotesScreen> {
  final FarmService _farmService = FarmService();
  late Stream<Farm?> _farmStream;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _farmStream = _farmService.getFarm(widget.farm.id);
  }

  Future<void> _agregarLote() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegistrarLoteScreen()),
    );

    if (result != null && result is FarmPlot) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _farmService.addPlotToFarm(widget.farm.id, result);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Lote agregado correctamente"),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error al agregar lote: ${e.toString()}"),
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

  Future<void> _editarLote(Farm farm, int index, FarmPlot plot) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditarLoteScreen(
          farm: farm,
          plotIndex: index,
          plot: plot,
        ),
      ),
    );

    if (result == 'deleted') {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Lote eliminado correctamente"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else if (result != null && result is FarmPlot) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Lote actualizado correctamente"),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _eliminarLote(int index) async {
    // Mostrar diálogo de confirmación
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmar eliminación"),
        content: const Text("¿Estás seguro de que quieres eliminar este lote?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Eliminar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _farmService.removePlotFromFarm(widget.farm.id, index);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Lote eliminado correctamente"),
              backgroundColor: Colors.green,
            ),
          );
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lotes de ${widget.farm.name}"),
        backgroundColor: Colors.green[800],
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              _mostrarInformacionLotes();
            },
            tooltip: "Información sobre lotes",
          ),
        ],
      ),
      body: Stack(
        children: [
          StreamBuilder<Farm?>(
            stream: _farmStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        "Error al cargar los lotes: ${snapshot.error}",
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _farmStream = _farmService.getFarm(widget.farm.id);
                          });
                        },
                        child: const Text("Reintentar"),
                      ),
                    ],
                  ),
                );
              }

              final farm = snapshot.data;
              if (farm == null) {
                return const Center(
                  child: Text("No se encontró la finca"),
                );
              }

              final plots = farm.plots;

              if (plots.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'lib/ui/screens/assets/images/logo.png',
                        height: 100,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.grass, size: 100, color: Colors.green);
                        },
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "No hay lotes registrados",
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Agrega el primer lote de tu finca",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _agregarLote,
                        icon: const Icon(Icons.add),
                        label: const Text("Agregar Lote"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  setState(() {
                    _farmStream = _farmService.getFarm(widget.farm.id);
                  });
                },
                child: Column(
                  children: [
                    // Header con estadísticas
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        border: Border(
                          bottom: BorderSide(color: Colors.green[200]!),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Lotes Registrados",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _buildStatChip("${plots.length}", "Lotes"),
                              const SizedBox(width: 12),
                              _buildStatChip(
                                "${plots.fold<double>(0, (sum, plot) => sum + plot.hectares).toStringAsFixed(1)} ha",
                                "Área Total",
                              ),
                              const SizedBox(width: 12),
                              _buildStatChip(
                                "${plots.fold<int>(0, (sum, plot) => sum + plot.plants)}",
                                "Plantas",
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Lista de lotes
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: plots.length,
                        itemBuilder: (context, index) {
                          final plot = plots[index];
                          return LoteItemWidget(
                            plot: plot,
                            index: index,
                            onEdit: () => _editarLote(farm, index, plot),
                            onDelete: () => _eliminarLote(index),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _agregarLote,
        backgroundColor: Colors.green[700],
        icon: const Icon(Icons.add),
        label: const Text('Agregar Lote'),
      ),
    );
  }

  Widget _buildStatChip(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green[300]!),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.green[800],
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.green[700],
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarInformacionLotes() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Información sobre Lotes"),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Gestión de Lotes:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text("• Puedes agregar múltiples lotes a tu finca"),
            Text("• Cada lote puede tener diferentes variedades de café"),
            Text("• Registra la información específica de cada área"),
            Text("• Edita o elimina lotes según sea necesario"),
            SizedBox(height: 12),
            Text(
              "Datos importantes:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text("• Hectáreas: Área del lote"),
            Text("• Altitud: Altura sobre el nivel del mar"),
            Text("• Variedad: Tipo de café cultivado"),
            Text("• Plantas: Número total de matas"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Entendido"),
          ),
        ],
      ),
    );
  }
}