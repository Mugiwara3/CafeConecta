import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:miapp_cafeconecta/ui/screens/auth/ventas/venta_controller.dart';
import 'package:miapp_cafeconecta/ui/screens/auth/ventas/venta_model.dart';

class RegistrarVentasScreen extends StatefulWidget {
  const RegistrarVentasScreen({super.key});

  @override
  _RegistrarVentasScreenState createState() => _RegistrarVentasScreenState();
}

class _RegistrarVentasScreenState extends State<RegistrarVentasScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _vendedorController = TextEditingController();
  final TextEditingController _fechaController = TextEditingController();
  final List<CafeVendido> _cafesVendidos = [CafeVendido()];
  final VentaController _ventaController = VentaController();

  @override
  void initState() {
    super.initState();
    _fechaController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
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
    }
  }

  Future<void> _guardarVenta() async {
    if (_formKey.currentState!.validate()) {
      try {
        final totalVenta = _cafesVendidos.fold(
          0.0,
          (sum, cafe) => sum + (cafe.cantidad * cafe.precio),
        );

        final venta = Venta(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          vendedor: _vendedorController.text,
          fecha: _fechaController.text,
          cafes: _cafesVendidos.map((cafe) => cafe.toMap()).toList(),
          total: totalVenta,
        );

        await _ventaController.agregarVenta(venta);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Venta registrada con éxito'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: Colors.red,
          ),
        );
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
        title: const Text('Registrar Ventas'),
        backgroundColor: Colors.brown[800],
        elevation: 2,
      ),
      body: SingleChildScrollView(
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Tipo de café ${index + 1}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            if (_cafesVendidos.length > 1)
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
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Cantidad (latas)',
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    cafe.cantidad = int.tryParse(value) ?? 0;
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Ingrese cantidad';
                                  }
                                  if (int.tryParse(value) == null) {
                                    return 'Número inválido';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Precio por lata (\$)',
                                  border: OutlineInputBorder(),
                                  prefixText: '\$',
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    cafe.precio = double.tryParse(value) ?? 0.0;
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Ingrese precio';
                                  }
                                  if (double.tryParse(value) == null) {
                                    return 'Número inválido';
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
                onPressed: _guardarVenta,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown[800],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'GUARDAR VENTA',
                  style: TextStyle(
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
  int cantidad = 0;
  double precio = 0.0;

  Map<String, dynamic> toMap() {
    return {
      'tipo': tipo,
      'cantidad': cantidad,
      'precio': precio,
      'total': (cantidad * precio).toStringAsFixed(2),
    };
  }
}
