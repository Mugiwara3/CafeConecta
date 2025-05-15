import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/date_symbol_data_local.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  final String apiKey = 'AIzaSyDBCFgmuu9DQFvMYHokAFVDcopqXda4gbM';
  GenerativeModel? _model;
  ChatSession? _chat;
  bool _isInitialized = false;
  String? _initError;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es_ES', null).then((_) {
      _initializeGemini();
    });
  }

  void _initializeGemini() {
    try {
      if (apiKey.isEmpty) {
        setState(() {
          _initError = 'La API key no puede estar vacía';
          _isInitialized = false;
        });
        return;
      }

      _model = GenerativeModel(
        model: 'gemini-1.5-pro',
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.7,
          topK: 40,
          topP: 0.95,
          maxOutputTokens: 1024,
        ),
      );

      // Iniciar la sesión de chat
      _chat = _model!.startChat();

      // Como no podemos pasar el role, enviamos un mensaje inicial para establecer el contexto
      _sendSystemPrompt();

      setState(() {
        _isInitialized = true;
        _messages.add(
          ChatMessage(
            text:
                '¡Hola! Soy tu asistente virtual de CafeConecta. ¿En qué puedo ayudarte con tu cultivo de café hoy?',
            isUser: false,
          ),
        );
      });
    } catch (e) {
      debugPrint('Error al inicializar Gemini: $e');
      setState(() {
        _initError = 'Error al inicializar Gemini: $e';
        _isInitialized = false;
      });
    }
  }

  Future<void> _sendSystemPrompt() async {
    if (_chat == null) return;

    try {
      // Definir el prompt del sistema
      final systemPrompt = '''
      Eres un asistente especializado en cultivo de café para la app CafeConecta. 
      Tu objetivo es brindar información precisa, actualizada y útil a caficultores.
      
      CONOCIMIENTOS ESPECIALIZADOS:
      - Variedades de café y sus características (Arábica, Robusta, Bourbon, Geisha, Caturra, etc.)
      - Etapas de cultivo, desde la siembra hasta la cosecha
      - Manejo de plagas y enfermedades comunes (broca, roya, ojo de gallo, antracnosis)
      - Prácticas sostenibles y certificaciones (orgánico, comercio justo, Rainforest Alliance)
      - Técnicas de procesamiento (lavado, honey, natural, fermentación)
      - Adaptación al cambio climático en caficultura
      - Mejores prácticas para calidad y productividad
      - Análisis de suelos y fertilización adecuada
      - Sistemas agroforestales y sombrío
      - Comercialización y mercado del café
      
      PAUTAS DE RESPUESTA:
      1. Adapta tus respuestas al contexto colombiano/latinoamericano de caficultura
      2. Prioriza técnicas sostenibles y respetuosas con el medio ambiente
      3. Ofrece recomendaciones prácticas y aplicables para pequeños y medianos productores
      4. Usa terminología técnica pero explícala de forma clara
      5. Cuando sea relevante, menciona los beneficios económicos de las prácticas recomendadas
      6. Si una consulta está fuera de tu ámbito, indícalo y sugiere fuentes confiables
      7. Estructura tus respuestas de manera clara y concisa
      8. SIEMPRE responde en español, sin importar el idioma en que te pregunten
      
      INFORMACIÓN REGIONAL:
      - Colombia: Alta calidad de arábica, cultivos entre 1200-2000 m, variedades como Castillo, Colombia, Caturra, Cenicafé 1
      - México: Producción en Chiapas, Veracruz y Oaxaca, principalmente varietales como Typica y Bourbon
      - Brasil: Mayor productor mundial, mecanización, cultivo a pleno sol, procesamiento natural
      - Centroamérica: Conocido por sus cafés de altura, sistemas agroforestales tradicionales
      
      PROBLEMAS COMUNES Y SOLUCIONES:
      - Broca: Control cultural (recolección oportuna), control biológico (Beauveria bassiana), trampas con alcoholes
      - Roya: Variedades resistentes (Castillo, Colombia), fungicidas cúpricos, manejo de sombra
      - Fertilización deficiente: Análisis de suelo, abonos orgánicos, compostaje de pulpa
      - Cambio climático: Aumentar sombrío, sistemas agroforestales, reservorios de agua, variedades resistentes

      EJEMPLOS DE INTERACCIÓN:

      Pregunta: ¿Cómo estás?
      Respuesta: Estoy muy bien, gracias por preguntar. Estoy listo para ayudarte con cualquier duda sobre tu cultivo de café. ¿Tienes alguna consulta específica sobre variedades, control de plagas, procesamiento o cualquier otro aspecto del cultivo?

      Pregunta: Hola, tengo problemas con la broca en mi cultivo
      Respuesta: La broca del café (Hypothenemus hampei) es una de las plagas más destructivas para los cafetales. Para controlarla efectivamente, te recomiendo una estrategia integrada: 1) Control cultural: mantén una cosecha sanitaria recogiendo todos los frutos, incluso los caídos. 2) Control biológico: utiliza el hongo Beauveria bassiana que parasita a la broca. 3) Trampas con alcoholes: coloca trampas con una mezcla de metanol y etanol para atraer y capturar adultos. 4) Monitoreo constante: revisa regularmente tus plantas para detectar infestaciones tempranas. Es importante aplicar estas medidas de manera preventiva y no esperar a que la infestación sea severa. ¿En qué etapa se encuentra tu problema con la broca?

      Recuerda que tus consejos pueden impactar directamente en los medios de vida de los caficultores.
      
      IMPORTANTE: Eres un asistente de café. Todas tus respuestas deben estar relacionadas con el café, incluso a preguntas generales como "¿cómo estás?".
      ''';

      // Enviamos el prompt como un mensaje del usuario, pero no lo mostramos en la UI
      await _chat!.sendMessage(
        Content.text("Instrucciones del sistema: " + systemPrompt),
      );

      // También enviamos una instrucción para que el modelo responda que entiende
      final response = await _chat!.sendMessage(
        Content.text(
          "Ahora responde solamente con: 'Entendido. Estoy listo para ayudar con temas de café.'",
        ),
      );

      debugPrint('Prompt del sistema enviado: ${response.text}');
    } catch (e) {
      debugPrint('Error al enviar prompt del sistema: $e');
    }
  }

  bool _isGreeting(String text) {
    text = text.toLowerCase();
    final greetings = [
      'hola',
      'buenos días',
      'buenas tardes',
      'buenas noches',
      'saludos',
      'qué tal',
      'como estas',
      'cómo vas',
      'qué hay',
    ];

    return greetings.any((greeting) => text.contains(greeting));
  }

  bool _isRelatedToCoffee(String text) {
    final coffeeTerms = [
      'café',
      'cafeto',
      'cultivo',
      'arábica',
      'robusta',
      'broca',
      'roya',
      'variedad',
      'cosecha',
      'fermentación',
      'beneficio',
      'pergamino',
      'cereza',
    ];

    return coffeeTerms.any((term) => text.toLowerCase().contains(term));
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    if (!_isInitialized || _chat == null) {
      _showErrorSnackbar('El chat no está inicializado correctamente');
      return;
    }

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _isTyping = true;
      _messageController.clear();
    });

    _scrollToBottom();

    try {
      // Si es un saludo o pregunta sobre cómo está, reforzamos el contexto
      String enhancedText = text;
      if (_isGreeting(text)) {
        enhancedText =
            "El usuario dice: '$text'. Recuerda que eres un asistente especializado en café. Responde de forma amable pero relacionando tu respuesta con el café.";
      }

      final response = await _chat!.sendMessage(Content.text(enhancedText));
      var responseText = response.text ?? 'No se pudo obtener una respuesta.';

      // Si la respuesta no está relacionada con el café y no es una respuesta a un saludo
      if (!_isRelatedToCoffee(responseText) && !_isGreeting(text)) {
        // Intentamos reforzar la respuesta para que se oriente al café
        try {
          final enhancedPrompt =
              "Tu última respuesta no estaba relacionada con el café. Recuerda que eres un asistente especializado en cultivo de café. "
              "El usuario ha preguntado: '$text'. "
              "Por favor, proporciona una nueva respuesta orientada al café. "
              "Si la pregunta no está relacionada con el café, responde de manera amable "
              "pero orienta la conversación hacia temas de café.";

          final newResponse = await _chat!.sendMessage(
            Content.text(enhancedPrompt),
          );
          if (newResponse.text != null && newResponse.text!.isNotEmpty) {
            responseText = newResponse.text!;
          }
        } catch (e) {
          debugPrint('Error al regenerar respuesta: $e');
          // Si hay error, mantenemos la respuesta original
        }
      }

      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(text: responseText, isUser: false));
          _isTyping = false;
        });

        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Ocurrió un error al procesar tu solicitud';

        // Comprueba si el error está relacionado con la API key
        if (e.toString().contains('API key') || e.toString().contains('400')) {
          errorMessage =
              'Error de API: La clave API no es válida o ha vencido. Por favor, contacta al administrador de la aplicación.';
        } else if (e.toString().contains('network')) {
          errorMessage =
              'Error de conexión: Verifica tu conexión a internet e intenta nuevamente.';
        } else {
          errorMessage = 'Error: ${e.toString()}';
        }

        setState(() {
          _isTyping = false;
          _messages.add(
            ChatMessage(text: errorMessage, isUser: false, isError: true),
          );
        });

        _scrollToBottom();
      }
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ChatIA - Asistente de café'),
        backgroundColor: Colors.brown[700],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child:
                _initError != null
                    ? _buildErrorMessage()
                    : _messages.isEmpty
                    ? _buildEmptyChat()
                    : _buildChatMessages(),
          ),
          if (_isTyping)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.brown,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Pensando...',
                    style: TextStyle(
                      color: Colors.brown,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text(
              'Error de configuración',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _initError ?? 'Error desconocido',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _initializeGemini,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown,
                foregroundColor: Colors.white,
              ),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyChat() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 80, color: Colors.brown[300]),
          const SizedBox(height: 16),
          Text(
            'Pregúntame sobre tu cultivo de café',
            style: TextStyle(
              fontSize: 18,
              color: Colors.brown[800],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Puedes preguntar sobre técnicas de cultivo, enfermedades, clima, suelos y más.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.brown[600]),
            ),
          ),
          const SizedBox(height: 24),
          _buildSuggestionChips(),
        ],
      ),
    );
  }

  Widget _buildSuggestionChips() {
    final suggestions = [
      "¿Cómo controlar la broca?",
      "Mejores variedades para Colombia",
      "Técnicas de fertilización orgánica",
      "¿Cómo enfrentar el cambio climático?",
    ];

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      children:
          suggestions.map((suggestion) {
            return ActionChip(
              backgroundColor: Colors.brown[100],
              label: Text(suggestion),
              onPressed: () {
                _messageController.text = suggestion;
                _sendMessage(suggestion);
              },
            );
          }).toList(),
    );
  }

  Widget _buildChatMessages() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return _buildMessageBubble(message);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color:
              message.isUser
                  ? Colors.brown[800]
                  : message.isError
                  ? Colors.red[100]
                  : Colors.brown[100],
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color:
                message.isUser
                    ? Colors.white
                    : message.isError
                    ? Colors.red[900]
                    : Colors.brown[900],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              textCapitalization: TextCapitalization.sentences,
              enabled: _isInitialized && !_isTyping,
              decoration: InputDecoration(
                hintText: 'Escribe tu pregunta sobre café...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor:
                    (_isInitialized && !_isTyping)
                        ? Colors.brown[50]
                        : Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
              onSubmitted: (_isInitialized && !_isTyping) ? _sendMessage : null,
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: (_isInitialized && !_isTyping) ? Colors.brown : Colors.grey,
            borderRadius: BorderRadius.circular(24),
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap:
                  (_isInitialized && !_isTyping)
                      ? () => _sendMessage(_messageController.text)
                      : null,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Icon(
                  Icons.send,
                  color:
                      (_isInitialized && !_isTyping)
                          ? Colors.white
                          : Colors.grey[300],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final bool isError;

  ChatMessage({required this.text, required this.isUser, this.isError = false});
}
