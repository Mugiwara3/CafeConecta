import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:miapp_cafeconecta/ui/screens/auth/ventas/venta_controller.dart';
import 'package:miapp_cafeconecta/ui/screens/auth/ventas/venta_model.dart';
import 'package:provider/provider.dart';

class RegistrarVentasScreen extends StatefulWidget {
  final Venta? ventaParaEditar;

  const RegistrarVentasScreen({super.key, this.ventaParaEditar});

  @override
  _RegistrarVentasScreenState createState() => _RegistrarVentasScreenState();
}

class _RegistrarVentasScreenState extends State<RegistrarVentasScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _vendedorController = TextEditingController();
  final TextEditingController _fechaController = TextEditingController();
  final List<CafeVendido> _cafesVendidos = [];
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.ventaParaEditar != null;

    if (_isEditing) {
      _vendedorController.text = widget.ventaParaEditar!.vendedor;
      _fechaController.text = widget.ventaParaEditar!.fecha;

      _cafesVendidos.addAll(
        widget.ventaParaEditar!.cafes
            .map(
              (cafe) =>
                  CafeVendido()
                    ..tipo = cafe['tipo']
                    ..cantidad =
                        cafe['cantidad'] is int
                            ? cafe['cantidad']
                            : int.parse(cafe['cantidad'].toString())
                    ..precio =
                        cafe['precio'] is double
                            ? cafe['precio']
                            : double.parse(cafe['precio'].toString()),
            )
            .toList(),
      );
    } else {
      _fechaController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
      _cafesVendidos.add(CafeVendido());
    }
  }

  @override
  void dispose() {
    _vendedorController.dispose();
    _fechaController.dispose();
    super.dispose();
  }

  void _agregarTipoCafe() {
    setState(() {
      _cafesVendidos.add(CafeVendido());
    });
  }

  void _eliminarTipoCafe(int index) {
    if (_cafesVendidos.length > 1) {
      setState(() {
        _cafesVendidos.removeAt(index);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe haber al menos un tipo de café'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _guardarVenta() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final ventaController = Provider.of<VentaController>(
          context,
          listen: false,
        );
        final totalVenta = _cafesVendidos.fold(
          0.0,
          (sum, cafe) => sum + (cafe.cantidad * cafe.precio),
        );

        final venta = Venta(
          id:
              _isEditing
                  ? widget.ventaParaEditar!.id
                  : DateTime.now().millisecondsSinceEpoch.toString(),
          vendedor: _vendedorController.text,
          fecha: _fechaController.text,
          cafes: _cafesVendidos.map((cafe) => cafe.toMap()).toList(),
          total: totalVenta,
        );

        if (_isEditing) {
          await ventaController.actualizarVenta(venta);
        } else {
          await ventaController.agregarVenta(venta);
        }

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? 'Venta actualizada con éxito'
                  : 'Venta registrada con éxito',
            ),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context, true);
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
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
    final totalVenta = _cafesVendidos.fold(
      0.0,
      (sum, cafe) => sum + (cafe.cantidad * cafe.precio),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Venta' : 'Registrar Venta'),
        backgroundColor: Colors.brown[800],
        elevation: 2,
        actions:
            _isEditing
                ? [
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: const Text('Eliminar venta'),
                              content: const Text(
                                '¿Estás seguro de que quieres eliminar esta venta?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed:
                                      () => Navigator.pop(context, false),
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text(
                                    'Eliminar',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                      );

                      if (confirm == true) {
                        final ventaController = Provider.of<VentaController>(
                          context,
                          listen: false,
                        );
                        await ventaController.eliminarVenta(
                          widget.ventaParaEditar!.id,
                        );

                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Venta eliminada con éxito'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.pop(context, true);
                      }
                    },
                  ),
                ]
                : null,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _vendedorController,
                                decoration: const InputDecoration(
                                  labelText: 'Nombre del vendedor',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.person),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor ingrese el nombre';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _fechaController,
                                decoration: const InputDecoration(
                                  labelText: 'Fecha de venta',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.calendar_today),
                                ),
                                readOnly: true,
                                onTap: () async {
                                  final DateTime? picked = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2100),
                                  );
                                  if (picked != null) {
                                    setState(() {
                                      _fechaController.text = DateFormat(
                                        'yyyy-MM-dd',
                                      ).format(picked);
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Detalle de cafés vendidos:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ..._cafesVendidos.asMap().entries.map((entry) {
                        final index = entry.key;
                        final cafe = entry.value;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Tipo de café ${index + 1}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () => _eliminarTipoCafe(index),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                DropdownButtonFormField<String>(
                                  value: cafe.tipo,
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'Buena calidad',
                                      child: Text('Café de buena calidad'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'Pasilla',
                                      child: Text('Pasilla'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'Raspa',
                                      child: Text('Raspa'),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      cafe.tipo = value;
                                    });
                                  },
                                  decoration: const InputDecoration(
                                    labelText: 'Tipo de café',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value == null) {
                                      return 'Seleccione el tipo';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        initialValue:
                                            cafe.cantidad > 0
                                                ? cafe.cantidad.toString()
                                                : '',
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                          labelText: 'Cantidad (latas)',
                                          border: OutlineInputBorder(),
                                        ),
                                        onChanged: (value) {
                                          setState(() {
                                            cafe.cantidad =
                                                int.tryParse(value) ?? 0;
                                          });
                                        },
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Ingrese cantidad';
                                          }
                                          if (int.tryParse(value) == null) {
                                            return 'Número inválido';
                                          }
                                          if (int.parse(value) <= 0) {
                                            return 'Debe ser mayor a 0';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: TextFormField(
                                        initialValue:
                                            cafe.precio > 0
                                                ? cafe.precio.toString()
                                                : '',
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                          labelText: 'Precio por lata (\$)',
                                          border: OutlineInputBorder(),
                                          prefixText: '\$',
                                        ),
                                        onChanged: (value) {
                                          setState(() {
                                            cafe.precio =
                                                double.tryParse(value) ?? 0.0;
                                          });
                                        },
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Ingrese precio';
                                          }
                                          if (double.tryParse(value) == null) {
                                            return 'Número inválido';
                                          }
                                          if (double.parse(value) <= 0) {
                                            return 'Debe ser mayor a 0';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    'Subtotal: \$${(cafe.cantidad * cafe.precio).toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                      OutlinedButton.icon(
                        onPressed: _agregarTipoCafe,
                        icon: const Icon(Icons.add_circle_outline),
                        label: const Text('Agregar otro tipo de café'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _guardarVenta,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown[800],
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child:
                            _isLoading
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                : Text(
                                  _isEditing
                                      ? 'ACTUALIZAR VENTA'
                                      : 'GUARDAR VENTA',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Total Venta: \$${totalVenta.toStringAsFixed(2)}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}

class CafeVendido {
  String? tipo;
  int cantidad;
  double precio;

  CafeVendido({this.tipo, this.cantidad = 0, this.precio = 0.0});

  Map<String, dynamic> toMap() {
    return {
      'tipo': tipo,
      'cantidad': cantidad,
      'precio': precio,
      'total': (cantidad * precio).toStringAsFixed(2),
    };
  }
}
