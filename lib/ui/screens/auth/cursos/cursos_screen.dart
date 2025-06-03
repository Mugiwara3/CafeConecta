import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'modulo_detalle_screen.dart';
import 'modulo_model.dart';

class CursosScreen extends StatefulWidget {
  const CursosScreen({super.key});

  @override
  State<CursosScreen> createState() => _CursosScreenState();
}

class _CursosScreenState extends State<CursosScreen> {
  List<bool> modulosCompletados = List.filled(modulos.length, false);
  int moduloActual = 0;
  bool cursoCompletado = false;

  @override
  void initState() {
    super.initState();
    _cargarProgreso();
  }

  Future<void> _cargarProgreso() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      for (int i = 0; i < modulos.length; i++) {
        modulosCompletados[i] = prefs.getBool('modulo_${i}_completado') ?? false;
      }
      moduloActual = prefs.getInt('modulo_actual') ?? 0;
      cursoCompletado = modulosCompletados.last;
    });
  }

  Future<void> _guardarProgreso(int moduloIndex, bool completado) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('modulo_${moduloIndex}_completado', completado);
    await prefs.setInt('modulo_actual', moduloIndex);
    setState(() {
      modulosCompletados[moduloIndex] = completado;
      moduloActual = completado ? moduloIndex + 1 : moduloIndex;
      cursoCompletado = modulosCompletados.last;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cursos de Caficultura'),
        backgroundColor: Colors.brown[800],
      ),
      body: Column(
        children: [
          if (cursoCompletado)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green),
                ),
                padding: const EdgeInsets.all(12),
                child: const Text(
                  '¡Curso completado! Ahora puedes acceder a cualquier módulo.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: modulos.length,
              itemBuilder: (context, index) {
                final modulo = modulos[index];
                final moduloDisponible = index == 0 || 
                    modulosCompletados[index - 1] || 
                    cursoCompletado;
                final esModuloActual = index == moduloActual;

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: moduloDisponible
                        ? () async {
                            final completado = await Navigator.push<bool>(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ModuloDetalleScreen(modulo: modulo),
                              ),
                            );

                            if (completado ?? false) {
                              await _guardarProgreso(index, true);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('¡Módulo ${modulo.id} completado!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          }
                        : null,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: esModuloActual && moduloDisponible
                            ? Border.all(color: Colors.brown, width: 2)
                            : null,
                      ),
                      child: Opacity(
                        opacity: moduloDisponible ? 1.0 : 0.6,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    image: AssetImage(modulo.imagenPortada),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Módulo ${modulo.id}: ${modulo.titulo}",
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      modulo.descripcion,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.library_books,
                                          size: 16,
                                          color: Colors.brown[400],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${modulo.diapositivas.length} lecciones',
                                          style: TextStyle(color: Colors.brown[400]),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  if (modulosCompletados[index])
                                    const Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Icon(
                                          Icons.check_circle,
                                          color: Colors.green,
                                          size: 30,
                                        ),
                                        Icon(
                                          Icons.star,
                                          color: Colors.yellow,
                                          size: 15,
                                        ),
                                      ],
                                    )
                                  else
                                    Icon(
                                      moduloDisponible
                                          ? Icons.arrow_forward_ios
                                          : Icons.lock,
                                      color: moduloDisponible
                                          ? Colors.brown
                                          : Colors.grey,
                                    ),
                                  if (esModuloActual && moduloDisponible)
                                    const Text(
                                      'Continuar',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.brown,
                                      ),
                                    ),
                                  if (modulosCompletados[index])
                                    const Text(
                                      'Completado',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.green,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown[800],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Volver',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}