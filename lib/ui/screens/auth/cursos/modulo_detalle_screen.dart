import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'modulo_model.dart';

class ModuloDetalleScreen extends StatefulWidget {
  final Modulo modulo;

  const ModuloDetalleScreen({super.key, required this.modulo});

  @override
  State<ModuloDetalleScreen> createState() => _ModuloDetalleScreenState();
}

class _ModuloDetalleScreenState extends State<ModuloDetalleScreen> {
  late PageController _pageController;
  int _currentPage = 0;
  late YoutubePlayerController _youtubeController;
  List<int?> respuestasQuiz = [];
  bool _quizCompletado = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _youtubeController = YoutubePlayerController(
      initialVideoId: '',
      flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
    );
    respuestasQuiz = List.filled(widget.modulo.quiz.length, null);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _youtubeController.dispose();
    super.dispose();
  }

  void _mostrarDialogoCompletado() {
    final esModuloFinal = widget.modulo.id == 6;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (esModuloFinal) ...[
                    // Imagen de felicitaciones con manejo de errores mejorado
                    Container(
                      height: 180,
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: Image.asset(
                        'lib/ui/screens/assets/images/felicidades.png',
                        height: 180,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          // Fallback con un ícono de celebración si la imagen falla
                          return Container(
                            height: 180,
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: Colors.green.shade200,
                                width: 2,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.celebration,
                                  size: 80,
                                  color: Colors.green.shade600,
                                ),
                                const SizedBox(height: 10),
                                Icon(
                                  Icons.emoji_events,
                                  size: 40,
                                  color: Colors.amber.shade600,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      '¡Felicidades!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Has completado con éxito todo el curso de caficultura',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.brown.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.brown.shade200),
                      ),
                      child: const Text(
                        'Comercialización y mercados',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ] else ...[
                    const Text(
                      '¡Módulo Completado!',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Icon(Icons.emoji_events, size: 60, color: Colors.amber),
                    const SizedBox(height: 20),
                    Text(
                      widget.modulo.titulo,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown[800],
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(); // Cierra el diálogo
                        Navigator.of(context).pop(true); // Retorna true
                      },
                      child: const Text(
                        'Aceptar',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Módulo ${widget.modulo.id}: ${widget.modulo.titulo}"),
        backgroundColor: Colors.brown[800],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentPage + 1) / (widget.modulo.diapositivas.length + 1),
            backgroundColor: Colors.brown[100],
            color: Colors.brown,
            minHeight: 4,
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
                if (_youtubeController.value.isPlaying) {
                  _youtubeController.pause();
                }
              },
              itemCount: widget.modulo.diapositivas.length + 1,
              itemBuilder: (context, index) {
                if (index < widget.modulo.diapositivas.length) {
                  final diapositiva = widget.modulo.diapositivas[index];
                  return _DiapositivaItem(diapositiva: diapositiva);
                } else {
                  return _QuizPage(
                    preguntas: widget.modulo.quiz,
                    respuestas: respuestasQuiz,
                    onRespuestaSeleccionada: (preguntaIndex, respuestaIndex) {
                      setState(() {
                        respuestasQuiz[preguntaIndex] = respuestaIndex;
                      });
                    },
                  );
                }
              },
            ),
          ),
          _buildNavigationControls(),
        ],
      ),
    );
  }

  Widget _buildNavigationControls() {
    final esUltimaDiapositiva =
        _currentPage == widget.modulo.diapositivas.length - 1;
    final esQuizPage = _currentPage == widget.modulo.diapositivas.length;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      color: Colors.brown[50],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed:
                _currentPage > 0
                    ? () => _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    )
                    : null,
          ),
          Text(
            esQuizPage
                ? 'Quiz'
                : 'Diapositiva ${_currentPage + 1}/${widget.modulo.diapositivas.length}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: Icon(
              esUltimaDiapositiva
                  ? Icons.quiz
                  : esQuizPage
                  ? Icons.check_circle_outline
                  : Icons.arrow_forward,
            ),
            onPressed: () {
              if (esUltimaDiapositiva) {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              } else if (esQuizPage) {
                final todasCorrectas = widget.modulo.quiz.asMap().entries.every(
                  (entry) =>
                      respuestasQuiz[entry.key] ==
                      entry.value.respuestaCorrecta,
                );

                if (todasCorrectas) {
                  _quizCompletado = true;
                  _mostrarDialogoCompletado();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('¡Debes responder todas correctamente!'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } else {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class _DiapositivaItem extends StatelessWidget {
  final Diapositiva diapositiva;

  const _DiapositivaItem({required this.diapositiva});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            diapositiva.titulo,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.brown,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          if (diapositiva.imagen != null) _buildImage(),
          if (diapositiva.videoUrl != null) _buildVideoPlayer(),
          Text(
            diapositiva.contenido,
            style: const TextStyle(fontSize: 16, height: 1.5),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return Container(
      height: 200,
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          diapositiva.imagen!,
          fit: BoxFit.cover,
          errorBuilder:
              (_, __, ___) => Container(
                color: Colors.grey[200],
                child: const Center(
                  child: Icon(Icons.image_not_supported, size: 50),
                ),
              ),
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return Container(
      height: 200,
      margin: const EdgeInsets.only(bottom: 20),
      child: YoutubePlayer(
        controller: YoutubePlayerController(
          initialVideoId: YoutubePlayer.convertUrlToId(diapositiva.videoUrl!)!,
          flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
        ),
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.brown,
      ),
    );
  }
}

class _QuizPage extends StatelessWidget {
  final List<QuizPregunta> preguntas;
  final List<int?> respuestas;
  final Function(int, int) onRespuestaSeleccionada;

  const _QuizPage({
    required this.preguntas,
    required this.respuestas,
    required this.onRespuestaSeleccionada,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Evaluación del Módulo',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.brown,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Responde correctamente las siguientes preguntas para continuar:',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          ...preguntas.asMap().entries.map((entry) {
            final index = entry.key;
            final pregunta = entry.value;
            return Card(
              margin: const EdgeInsets.only(bottom: 20),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${index + 1}. ${pregunta.pregunta}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...pregunta.opciones.asMap().entries.map((opcion) {
                      return RadioListTile<int>(
                        title: Text(opcion.value),
                        value: opcion.key,
                        groupValue: respuestas[index],
                        onChanged: (value) {
                          onRespuestaSeleccionada(index, value!);
                        },
                      );
                    }),
                    if (respuestas[index] != null)
                      Text(
                        respuestas[index] == pregunta.respuestaCorrecta
                            ? '¡Correcto!'
                            : 'Incorrecto',
                        style: TextStyle(
                          color:
                              respuestas[index] == pregunta.respuestaCorrecta
                                  ? Colors.green
                                  : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
