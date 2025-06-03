import 'package:flutter/material.dart';
import 'package:miapp_cafeconecta/ui/widgets/provider/recoleccion_provider.dart';
import 'package:provider/provider.dart';

class TrabajadorDialog extends StatefulWidget {
  final String? nombreTrabajador;
  final bool isEditing;

  const TrabajadorDialog({
    super.key,
    this.nombreTrabajador,
    this.isEditing = false,
  });

  @override
  State<TrabajadorDialog> createState() => _TrabajadorDialogState();
}

class _TrabajadorDialogState extends State<TrabajadorDialog> {
  late TextEditingController _nombreController;
  final _formKey = GlobalKey<FormState>();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.nombreTrabajador ?? '');
  }

  @override
  void dispose() {
    _nombreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RecoleccionProvider>(context);
    final title = widget.isEditing ? 'Editar Trabajador' : 'Agregar Trabajador';
    final buttonText = widget.isEditing ? 'Guardar Cambios' : 'Agregar';

    return AlertDialog(
      title: Text(title),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre del Trabajador',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Por favor ingrese un nombre';
                }
                return null;
              },
              enabled: !_isProcessing,
            ),
          ],
        ),
      ),
      actions: [
        if (widget.isEditing && !_isProcessing)
          TextButton.icon(
            icon: const Icon(Icons.delete_forever, color: Colors.red),
            label: const Text('Eliminar', style: TextStyle(color: Colors.red)),
            onPressed: () {
              _confirmarEliminar(context, provider);
            },
          ),
        TextButton(
          onPressed: _isProcessing ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isProcessing
              ? null
              : () async {
                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      _isProcessing = true;
                    });
                    try {
                      final nuevoNombre = _nombreController.text.trim();
                      
                      if (widget.isEditing && widget.nombreTrabajador != null) {
                        if (nuevoNombre != widget.nombreTrabajador) {
                          await provider.eliminarTrabajador(widget.nombreTrabajador!);
                          await provider.agregarTrabajador(nuevoNombre);
                        }
                      } else {
                        await provider.agregarTrabajador(nuevoNombre);
                      }

                      if (mounted) {
                        Navigator.of(context).pop();
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: ${e.toString()}')),
                        );
                        setState(() {
                          _isProcessing = false;
                        });
                      }
                    }
                  }
                },
          child: _isProcessing
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(buttonText),
        ),
      ],
    );
  }

  void _confirmarEliminar(BuildContext context, RecoleccionProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: Text(
          '¿Está seguro que desea eliminar al trabajador "${widget.nombreTrabajador}"?\n\n'
          'Esta acción eliminará todos los datos de recolección asociados a este trabajador y no puede deshacerse.',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.of(ctx).pop();
              setState(() {
                _isProcessing = true;
              });
              try {
                await provider.eliminarTrabajador(widget.nombreTrabajador!);
                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Trabajador "${widget.nombreTrabajador}" eliminado correctamente'),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  setState(() {
                    _isProcessing = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error al eliminar: ${e.toString()}")),
                  );
                }
              }
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}