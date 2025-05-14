import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:miapp_cafeconecta/ui/screens/auth/home/chat/CafePrompt.dart';
import 'package:miapp_cafeconecta/ui/screens/auth/login/widgets/app_bar/custom_app_bar.dart';

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

  final String apiKey = 'AIzaSyCBzJEPxy9yc6ksSb_LAa0CEj26dJ3-UpE';
  GenerativeModel? _model;
  ChatSession? _chat;
  bool _isInitialized = false;
  String? _initError;

  @override
  void initState() {
    super.initState();
    _initializeGemini();
  }

  void _initializeGemini() {
    try {
      if (apiKey == 'AIzaSyCBzJEPxy9yc6ksSb_LAa0CEj26dJ3-UpE') {
        setState(() {
          _initError = 'Configura tu API Key de Gemini en la constante apiKey';
          _isInitialized = false;
        });
        return;
      }

      _model = GenerativeModel(
        model: 'gemini-pro',
        apiKey: apiKey,
      );
      
      // Inicializamos la sesión con el prompt especializado
      CafeCultivationPrompt.configureChat(_model!).then((configuredChat) {
        if (mounted) {
          setState(() {
            _chat = configuredChat;
            _isInitialized = true;
            // Mensaje inicial de bienvenida
            _messages.add(
              ChatMessage(
                text: '¡Hola! Soy tu asistente virtual de CafeConecta. ¿En qué puedo ayudarte con tu cultivo de café hoy?',
                isUser: false,
              ),
            );
          });
        }
      }).catchError((e) {
        debugPrint('Error al configurar el prompt: $e');
        // Si falla la configuración del prompt, continuamos con una sesión normal
        if (mounted) {
          setState(() {
            _chat = _model!.startChat();
            _isInitialized = true;
            _messages.add(
              ChatMessage(
                text: '¡Hola! Soy tu asistente virtual de CafeConecta. ¿En qué puedo ayudarte hoy?',
                isUser: false,
              ),
            );
          });
        }
      });
    } catch (e) {
      debugPrint('Error al inicializar Gemini: $e');
      setState(() {
        _initError = 'Error al inicializar Gemini: $e';
        _isInitialized = false;
      });
    }
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
      final response = await _chat!.sendMessage(Content.text(text));
      final responseText = response.text ?? 'No se pudo obtener una respuesta.';
      
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(text: responseText, isUser: false));
          _isTyping = false;
        });
        
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(ChatMessage(
            text: 'Ocurrió un error al procesar tu solicitud: $e',
            isUser: false,
            isError: true,
          ));
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
      appBar: const CustomAppBar(title: 'ChatIA - Asistente de café'),
      body: Column(
        children: [
          Expanded(
            child: _initError != null
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
              style: const TextStyle(
                fontSize: 16,
              ),
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
          Icon(Icons.chat_bubble_outline,
              size: 80, color: Colors.brown[300]),
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
              style: TextStyle(
                color: Colors.brown[600],
              ),
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
      "Mejores variedades para mi región",
      "Técnicas de fertilización orgánica",
      "¿Cómo enfrentar el cambio climático?",
    ];
    
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      children: suggestions.map((suggestion) {
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
      alignment: message.isUser
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: message.isUser
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
            color: message.isUser
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
                hintText: 'Escribe tu pregunta...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: (_isInitialized && !_isTyping) 
                    ? Colors.brown[50]
                    : Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
              onSubmitted: (_isInitialized && !_isTyping) 
                  ? _sendMessage 
                  : null,
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: (_isInitialized && !_isTyping) 
                ? Colors.brown
                : Colors.grey,
            borderRadius: BorderRadius.circular(24),
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: (_isInitialized && !_isTyping)
                  ? () => _sendMessage(_messageController.text)
                  : null,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Icon(
                  Icons.send,
                  color: (_isInitialized && !_isTyping) 
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

  ChatMessage({
    required this.text,
    required this.isUser,
    this.isError = false,
  });
}