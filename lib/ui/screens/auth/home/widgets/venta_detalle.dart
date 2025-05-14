/*import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:miapp_cafeconecta/controllers/auth_controller.dart';
import 'package:miapp_cafeconecta/controllers/venta_controller.dart';
import 'package:miapp_cafeconecta/models/venta_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart';

class VentaDetailScreen extends StatefulWidget {
  final String ventaId;
  
  const VentaDetailScreen({
    Key? key,
    required this.ventaId,
  }) : super(key: key);

  @override
  State<VentaDetailScreen> createState() => _VentaDetailScreenState();
}

class _VentaDetailScreenState extends State<VentaDetailScreen> {
  late final VentaController _ventaController;
  bool _isLoading = true;
  Venta? _venta;
  bool _isEditing = false;
  
  // Controllers para edición
  final _clienteController = TextEditingController();
  final _precioController = TextEditingController();
  final _kilosController = TextEditingController();
  
  DateTime _fechaVenta = DateTime.now();
  double _total = 0.0;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _ventaController = VentaController();
    _loadVentaData();
  }

  @override
  void dispose() {
    _clienteController.dispose();
    _precioController.dispose();
    _kilosController.dispose();
    super.dispose();
  }

  Future<void> _loadVentaData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final venta = await _ventaController.getVenta(widget.ventaId);
      
      if (venta != null) {
        setState(() {
          _venta = venta;
          // Inicializar controladores con datos actuales
          _clienteController.text = venta.cliente;
          _precioController.text = venta.precio.toString();
          _kilosController.text = venta.kilos.toString();
          _fechaVenta = venta.fecha;
          _total = venta.total;
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("No se encontró la venta"),
              backgroundColor: Colors.red,
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al cargar la venta: ${e.toString()}"),
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

  void _calcularTotal() {
    if (_precioController.text.isNotEmpty && _kilosController.text.isNotEmpty) {
      try {
        final precio = double.parse(_precioController.text);
        final kilos = double.parse(_kilosController.text);
        setState(() {
          _total = precio * kilos;
        });
      } catch (e) {
        setState(() {
          _total = 0.0;
        });
      }
    } else {
      setState(() {
        _total = 0.0;
      });
    }
  }

  Future<void> _updateVenta() async {
    if (!_formKey.currentState!.validate() || _venta == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedVenta = Venta(
        id: _venta!.id,
        userId: _venta!.userId,
        fecha: _fechaVenta,
        cliente: _clienteController.text.trim(),
        precio: double.parse(_precioController.text),
        kilos: double.parse(_kilosController.text),
        total: _total,
        createdAt: _venta!.createdAt,
      );

      await _ventaController.updateVenta(updatedVenta);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Venta actualizada con éxito"),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _venta = updatedVenta;
          _isEditing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al actualizar la venta: ${e.toString()}"),
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

  Future<void> _deleteVenta() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      await _ventaController.deleteVenta(widget.ventaId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Venta eliminada con éxito"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
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

  Future<void> _generarRecibo() async {
    if (_venta == null) return;
    
    final pdf = pw.Document();
    
    // Cargar la imagen del logo
    final ByteData logoData = await rootBundle.load('lib/ui/screens/assets/images/logo.png');
    final Uint8List logoBytes = logoData.buffer.asUint8List();
    final logoImage = pw.MemoryImage(logoBytes);

    // Formato de moneda y fecha
    final formatoMoneda = NumberFormat.currency(locale: 'es_MX', symbol: '\$');
    final formatoFecha = DateFormat('dd/MM/yyyy');

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
                        'RECIBO DE VENTA',
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        'Folio: ${_venta!.id.substring(0, 8).toUpperCase()}',
                        style: const pw.TextStyle(fontSize: 14),
                      ),
                      pw.Text(
                        'Fecha: ${formatoFecha.format(_venta!.fecha)}',
                        style: const pw.TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              
              // Información del cliente
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'INFORMACIÓN DEL CLIENTE',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text('Cliente: ${_venta!.cliente}'),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              
              // Detalles de la venta
              pw.Table(
                border: pw.TableBorder.all(),
                columnWidths: {
                  0: const pw.FlexColumnWidth(1),
                  1: const pw.FlexColumnWidth(1),
                  2: const pw.FlexColumnWidth(1),
                  3: const pw.FlexColumnWidth(1),
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
                          'Descripción',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(
                          'Cantidad (kg)',
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
                          'Importe',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  // Datos de la venta
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text('Café'),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text('${_venta!.kilos}'),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(formatoMoneda.format(_venta!.precio)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(formatoMoneda.format(_venta!.total)),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 10),
              
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
                        formatoMoneda.format(_venta!.total),
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              pw.SizedBox(height: 30),
              
              // Firmas
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    children: [
                      pw.Container(
                        width: 150,
                        height: 1,
                        color: PdfColors.black,
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text('Firma del Comprador'),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Container(
                        width: 150,
                        height: 1,
                        color: PdfColors.black,
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text('Firma del Vendedor'),
                    ],
                  ),
                ],
              ),
              
              pw.Spacer(),
              
              // Pie de página
              pw.Center(
                child: pw.Text(
                  'Cafeconecta - Gracias por su compra',
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
    final formatoMoneda = NumberFormat.currency(locale: 'es_MX', symbol: '\$');
    final formatoFecha = DateFormat('dd/MM/yyyy');
    
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Detalle de Venta'),
          backgroundColor: Colors.brown[700],
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    if (_venta == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Detalle de Venta'),
          backgroundColor: Colors.brown[700],
        ),
        body: const Center(
          child: Text('No se encontró la venta'),
        ),
      );
    }
    
    // Vista de detalles
    if (!_isEditing) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Detalle de Venta'),
          backgroundColor: Colors.brown[700],
          actions: [
            IconButton(
              icon: const Icon(Icons.print),
              onPressed: _generarRecibo,
              tooltip: 'Imprimir Recibo',
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                  // Reiniciar controladores con datos actuales
                  _clienteController.text = _venta!.cliente;
                  _precioController.text = _venta!.precio.toString();
                  _kilosController.text = _venta!.kilos.toString();
                  _fechaVenta = _venta!.fecha;
                  _total = _venta!.total;
                });
              },
              tooltip: 'Editar Venta',
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
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
                          _deleteVenta();
                        },
                        child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
              tooltip: 'Eliminar Venta',
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tarjeta de información general
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Folio
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Folio:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            _venta!.id.substring(0, 8).toUpperCase(),
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.brown[800],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      
                      // Fecha de venta
                      Row(
                        children: [
                          Icon(Icons.calendar_today, color: Colors.brown[700]),
                          const SizedBox(width: 8),
                          const Text(
                            'Fecha de Venta:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            formatoFecha.format(_venta!.fecha),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      // Cliente
                      Row(
                        children: [
                          Icon(Icons.person, color: Colors.brown[700]),
                          const SizedBox(width: 8),
                          const Text(
                            'Cliente:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            _venta!.cliente,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      // Fecha de registro
                      Row(
                        children: [
                          Icon(Icons.access_time, color: Colors.brown[700]),
                          const SizedBox(width: 8),
                          const Text(
                            'Registrado el:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            formatoFecha.format(_venta!.createdAt),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Detalles de la venta
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Detalles de la Venta',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Tabla de detalles
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            // Encabezados
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.brown[100],
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  topRight: Radius.circular(8),
                                ),
                              ),
                              child: const Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'Producto',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Kilos',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Precio/kg',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Importe',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Datos
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: const BoxDecoration(
                                border: Border(
                                  top: BorderSide(color: Colors.grey),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Expanded(
                                    flex: 2,
                                    child: Text('Café'),
                                  ),
                                  Expanded(
                                    child: Text(
                                      '${_venta!.kilos.toStringAsFixed(2)}',
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      formatoMoneda.format(_venta!.precio),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      formatoMoneda.format(_venta!.total),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Total
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.brown[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.brown.shade200),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'TOTAL:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              formatoMoneda.format(_venta!.total),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                color: Colors.brown[800],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Botones de acción
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.print),
                      label: const Text('IMPRIMIR RECIBO'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: _generarRecibo,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.edit),
                      label: const Text('EDITAR'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        setState(() {
                          _isEditing = true;
                          // Reiniciar controladores con datos actuales
                          _clienteController.text = _venta!.cliente;
                          _precioController.text = _venta!.precio.toString();
                          _kilosController.text = _venta!.kilos.toString();
                          _fechaVenta = _venta!.fecha;
                          _total = _venta!.total;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
    
    // Vista de edición
    else {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Editar Venta'),
          backgroundColor: Colors.brown[700],
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              setState(() {
                _isEditing = false;
              });
            },
          ),
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Folio (no editable)
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            const Text(
                              'Folio:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              _venta!.id.substring(0, 8).toUpperCase(),
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.brown[800],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Fecha de venta
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Fecha de Venta',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  formatoFecha.format(_fechaVenta),
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const Spacer(),
                                IconButton(
                                  icon: const Icon(Icons.calendar_today),
                                  onPressed: () async {
                                    final DateTime? pickedDate = await showDatePicker(
                                      context: context,
                                      initialDate: _fechaVenta,
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime.now(),
                                    );
                                    if (pickedDate != null && pickedDate != _fechaVenta) {
                                      setState(() {
                                        _fechaVenta = pickedDate;
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Cliente
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Información del Cliente',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _clienteController,
                              decoration: InputDecoration(
                                labelText: 'Nombre del Cliente',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                prefixIcon: const Icon(Icons.person),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingrese el nombre del cliente';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Detalles de la venta
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.*/