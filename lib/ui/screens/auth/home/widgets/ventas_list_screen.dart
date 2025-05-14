/*import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:miapp_cafeconecta/controllers/auth_controller.dart';
import 'package:miapp_cafeconecta/controllers/venta_controller.dart';
import 'package:miapp_cafeconecta/models/venta_model.dart';
import 'package:miapp_cafeconecta/ui/screens/auth/ventas/venta_detail_screen.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart';

class VentasListScreen extends StatefulWidget {
  const VentasListScreen({super.key});

  @override
  State<VentasListScreen> createState() => _VentasListScreenState();
}

class _VentasListScreenState extends State<VentasListScreen> {
  late final VentaController _ventaController;
  bool _isLoading = false;
  
  // Filtros
  DateTime? _startDate;
  DateTime? _endDate;
  final TextEditingController _clienteFilterController = TextEditingController();
  
  // Estadísticas
  double _totalVentas = 0;
  double _totalKilos = 0;

  @override
  void initState() {
    super.initState();
    _ventaController = VentaController();
    _loadEstadisticas();
  }

  @override
  void dispose() {
    _clienteFilterController.dispose();
    super.dispose();
  }

  Future<void> _loadEstadisticas() async {
    final authController = Provider.of<AuthController>(context, listen: false);
    final user = authController.currentUser;
    
    if (user != null) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        final totalVentas = await _ventaController.getTotalVentas(user.uid);
        final totalKilos = await _ventaController.getTotalKilos(user.uid);
        
        setState(() {
          _totalVentas = totalVentas;
          _totalKilos = totalKilos;
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error al cargar estadísticas: ${e.toString()}"),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtrar Ventas'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Filtro por cliente
              TextField(
                controller: _clienteFilterController,
                decoration: const InputDecoration(
                  labelText: 'Cliente',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              
              // Filtro por fecha inicial
              ListTile(
                title: Text(_startDate == null 
                  ? 'Fecha inicial' 
                  : 'Desde: ${DateFormat('dd/MM/yyyy').format(_startDate!)}'),
                leading: const Icon(Icons.calendar_today),
                onTap: () async {
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _startDate ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _startDate = pickedDate;
                    });
                    Navigator.pop(context);
                    _showFilterDialog();
                  }
                },
                trailing: _startDate != null 
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          _startDate = null;
                        });
                        Navigator.pop(context);
                        _showFilterDialog();
                      },
                    )
                  : null,
              ),
              
              // Filtro por fecha final
              ListTile(
                title: Text(_endDate == null 
                  ? 'Fecha final' 
                  : 'Hasta: ${DateFormat('dd/MM/yyyy').format(_endDate!)}'),
                leading: const Icon(Icons.calendar_today),
                onTap: () async {
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _endDate ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _endDate = pickedDate;
                    });
                    Navigator.pop(context);
                    _showFilterDialog();
                  }
                },
                trailing: _endDate != null 
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          _endDate = null;
                        });
                        Navigator.pop(context);
                        _showFilterDialog();
                      },
                    )
                  : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _startDate = null;
                _endDate = null;
                _clienteFilterController.clear();
              });
              Navigator.pop(context);
            },
            child: const Text('Limpiar Filtros'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Aplicar'),
          ),
        ],
      ),
    );
  }

  bool _matchesFilters(Venta venta) {
    // Filtrar por cliente
    if (_clienteFilterController.text.isNotEmpty) {
      final clienteFilter = _clienteFilterController.text.toLowerCase();
      if (!venta.cliente.toLowerCase().contains(clienteFilter)) {
        return false;
      }
    }
    
    // Filtrar por fecha inicial
    if (_startDate != null) {
      if (venta.fecha.isBefore(_startDate!)) {
        return false;
      }
    }
    
    // Filtrar por fecha final
    if (_endDate != null) {
      // Añadir un día completo para incluir el día final
      final endDatePlusOne = _endDate!.add(const Duration(days: 1));
      if (venta.fecha.isAfter(endDatePlusOne)) {
        return false;
      }
    }
    
    return true;
  }

  Future<void> _deleteVenta(String ventaId) async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      await _ventaController.deleteVenta(ventaId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Venta eliminada con éxito"),
            backgroundColor: Colors.green,
          ),
        );
      }
      _loadEstadisticas();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al eliminar la venta: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _generarReporteVentas(List<Venta> ventas) async {
    final pdf = pw.Document();
    
    // Cargar la imagen del logo
    final ByteData logoData = await rootBundle.load('lib/ui/screens/assets/images/logo.png');
    final Uint8List logoBytes = logoData.buffer.asUint8List();
    final logoImage = pw.MemoryImage(logoBytes);

    // Formato de moneda y fecha
    final formatoMoneda = NumberFormat.currency(locale: 'es_MX', symbol: '\$');
    final formatoFecha = DateFormat('dd/MM/yyyy');

    // Calcular totales para el reporte
    double totalKilos = 0;
    double totalVentas = 0;
    for (var venta in ventas) {
      totalKilos += venta.kilos;
      totalVentas += venta.total;
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Encabezado con logo
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Image(logoImage, width: 100, height: 100),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'REPORTE DE VENTAS',
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        'Fecha: ${formatoFecha.format(DateTime.now())}',
                        style: const pw.TextStyle(fontSize: 14),
                      ),
                      pw.Text(
                        'Periodo: ${_startDate != null ? formatoFecha.format(_startDate!) : 'Todo'} - ${_endDate != null ? formatoFecha.format(_endDate!) : 'Todo'}',
                        style: const pw.TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              
              // Resumen
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(),
                  color: PdfColors.grey200,
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    pw.Column(
                      children: [
                        pw.Text(
                          'Total Ventas',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                        pw.Text(formatoMoneda.format(totalVentas)),
                      ],
                    ),
                    pw.Column(
                      children: [
                        pw.Text(
                          'Total Kilos',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                        pw.Text('${totalKilos.toStringAsFixed(2)} kg'),
                      ],
                    ),
                    pw.Column(
                      children: [
                        pw.Text(
                          'Núm. Ventas',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                        pw.Text('${ventas.length}'),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              
              // Tabla de ventas
              pw.Table(
                border: pw.TableBorder.all(),
                columnWidths: {
                  0: const pw.FlexColumnWidth(2),
                  1: const pw.FlexColumnWidth(3),
                  2: const pw.FlexColumnWidth(2),
                  3: const pw.FlexColumnWidth(2),
                  4: const pw.FlexColumnWidth(2),
                },
                children: [
                  // Encabezado de la tabla
                  pw.TableRow(
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey300,
                    ),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(
                          'Fecha',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(
                          'Cliente',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(
                          'Kilos',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(
                          'Precio/kg',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(
                          'Total',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  
                  // Filas de ventas
                  ...ventas.map((venta) => pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(formatoFecha.format(venta.fecha)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(venta.cliente),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(venta.kilos.toStringAsFixed(2)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(formatoMoneda.format(venta.precio)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(formatoMoneda.format(venta.total)),
                      ),
                    ],
                  )),
                ],
              ),
              
              pw.SizedBox(height: 20),
              
              // Total
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Container(
                  width: 200,
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(),
                    color: PdfColors.grey100,
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'TOTAL:',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      pw.Text(
                        formatoMoneda.format(totalVentas),
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              pw.Spacer(),
              
              // Pie de página
              pw.Center(
                child: pw.Text(
                  'Cafeconecta - Reporte generado el ${formatoFecha.format(DateTime.now())}',
                  style: const pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.grey700,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    final user = authController.currentUser;
    
    if (user == null) {
      // Si no hay usuario autenticado, redirigimos al login
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/login');
      });
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Formato para mostrar moneda en la interfaz
    final formatoMoneda = NumberFormat.currency(locale: 'es_MX', symbol: '\$');
    final formatoFecha = DateFormat('dd/MM/yyyy');
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Ventas'),
        backgroundColor: Colors.brown[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'report') {
                // Acción para generar reporte
                _generarReporteVentas([]);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'report',
                child: Row(
                  children: [
                    Icon(Icons.summarize, color: Colors.brown),
                    SizedBox(width: 8),
                    Text('Generar Reporte'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Tarjetas de estadísticas
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Card(
                        elevation: 4,
                        color: Colors.brown[50],
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Total Ventas',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                formatoMoneda.format(_totalVentas),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.brown[800],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Card(
                        elevation: 4,
                        color: Colors.brown[50],
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Total Kilos',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${_totalKilos.toStringAsFixed(2)} kg',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.brown[800],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Filtros activos
              if (_clienteFilterController.text.isNotEmpty || _startDate != null || _endDate != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.brown[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Filtros activos:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 8,
                          children: [
                            if (_clienteFilterController.text.isNotEmpty)
                              Chip(
                                label: Text('Cliente: ${_clienteFilterController.text}'),
                                deleteIcon: const Icon(Icons.close, size: 16),
                                onDeleted: () {
                                  setState(() {
                                    _clienteFilterController.clear();
                                  });
                                },
                              ),
                            if (_startDate != null)
                              Chip(
                                label: Text('Desde: ${formatoFecha.format(_startDate!)}'),
                                deleteIcon: const Icon(Icons.close, size: 16),
                                onDeleted: () {
                                  setState(() {
                                    _startDate = null;
                                  });
                                },
                              ),
                            if (_endDate != null)
                              Chip(
                                label: Text('Hasta: ${formatoFecha.format(_endDate!)}'),
                                deleteIcon: const Icon(Icons.close, size: 16),
                                onDeleted: () {
                                  setState(() {
                                    _endDate = null;
                                  });
                                },
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              
              // Lista de ventas
              Expanded(
                child: StreamBuilder<List<Venta>>(
                  stream: _ventaController.getVentas(user.uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error al cargar ventas: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }
                    
                    final ventas = snapshot.data ?? [];
                    
                    // Aplicar filtros
                    final ventasFiltradas = ventas.where(_matchesFilters).toList();
                    
                    // Generar reporte solo con ventas filtradas
                    if (ventas.isNotEmpty && ventasFiltradas.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No se encontraron ventas con los filtros aplicados',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _startDate = null;
                                  _endDate = null;
                                  _clienteFilterController.clear();
                                });
                              },
                              child: const Text('Limpiar Filtros'),
                            ),
                          ],
                        ),
                      );
                    }
                    
                    if (ventas.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.shopping_cart_outlined,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No hay ventas registradas',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.brown[700],
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                Navigator.pushNamed(context, '/registrar_ventas');
                              },
                              child: const Text('Registrar Venta'),
                            ),
                          ],
                        ),
                      );
                    }
                    
                    return RefreshIndicator(
                      onRefresh: _loadEstadisticas,
                      child: ListView.builder(
                        itemCount: ventasFiltradas.length,
                        itemBuilder: (context, index) {
                          final venta = ventasFiltradas[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            elevation: 2,
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              title: Text(
                                venta.cliente,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.calendar_today, size: 14, color: Colors.brown[700]),
                                      const SizedBox(width: 4),
                                      Text(formatoFecha.format(venta.fecha)),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.scale, size: 14, color: Colors.brown[700]),
                                      const SizedBox(width: 4),
                                      Text('${venta.kilos.toStringAsFixed(2)} kg a ${formatoMoneda.format(venta.precio)}/kg'),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    formatoMoneda.format(venta.total),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.brown[800],
                                    ),
                                  ),
                                  PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert),
                                    onSelected: (value) {
                                      if (value == 'detail') {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => VentaDetailScreen(ventaId: venta.id),
                                          ),
                                        );
                                      } else if (value == 'delete') {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Eliminar Venta'),
                                            content: const Text('¿Está seguro que desea eliminar esta venta? Esta acción no se puede deshacer.'),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context),
                                                child: const Text('Cancelar'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  _deleteVenta(venta.id);
                                                },
                                                child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'detail',
                                        child: Row(
                                          children: [
                                            Icon(Icons.visibility, color: Colors.blue),
                                            SizedBox(width: 8),
                                            Text('Ver Detalles'),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(Icons.delete, color: Colors.red),
                                            SizedBox(width: 8),
                                            Text('Eliminar'),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => VentaDetailScreen(ventaId: venta.id),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
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
        onPressed: () {
          Navigator.pushNamed(context, '/registrar_ventas');
        },
        backgroundColor: Colors.brown[700],
        icon: const Icon(Icons.add),
        label: const Text('Nueva Venta'),
      ),
    );
  }
}*/