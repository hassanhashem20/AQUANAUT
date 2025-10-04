import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:nasa2/core/constants/app_colors.dart';
import 'package:nasa2/core/constants/app_text_styles.dart';
import 'package:nasa2/core/debug/debug_utils.dart';

class AIChatPage extends StatefulWidget {
  @override
  _AIChatPageState createState() => _AIChatPageState();
}

class _AIChatPageState extends State<AIChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  late GenerativeModel _model;
  bool _isLoading = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeAI();
    _addWelcomeMessage();
  }

  Future<void> _initializeAI() async {
    try {
      _model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: 'AIzaSyBa1K5S5nBddw8g8ZCAePwU1BS7bdrkavE',
      );
      setState(() {
        _isInitialized = true;
      });
      DebugUtils.log('AI initialized successfully');
    } catch (e) {
      DebugUtils.logError('Error initializing AI', error: e);
      _addSystemMessage('Failed to initialize AI. Please check your connection and try again.');
    }
  }

  void _addWelcomeMessage() {
    _messages.add(ChatMessage(
      text: "Hello! I'm your NASA AI assistant. I can help you learn about space, the International Space Station, astronaut training, and answer questions about space exploration. What would you like to know?",
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  void _addSystemMessage(String text) {
    _messages.add(ChatMessage(
      text: text,
      isUser: false,
      timestamp: DateTime.now(),
      isSystem: true,
    ));
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _isLoading) return;

    if (!_isInitialized) {
      _addSystemMessage('AI is not initialized yet. Please wait a moment and try again.');
      return;
    }

    final userMessage = _messageController.text.trim();
    _messageController.clear();

    // Add user message
    _messages.add(ChatMessage(
      text: userMessage,
      isUser: true,
      timestamp: DateTime.now(),
    ));

    setState(() {
      _isLoading = true;
    });

    _scrollToBottom();

    try {
      DebugUtils.log('Sending message to AI: $userMessage');
      
      // Create a space-focused prompt
      final spacePrompt = '''
You are a NASA AI assistant for the AQUANAUT astronaut training app. 
Answer this space-related question: $userMessage

Keep responses concise, educational, and inspiring for future astronauts.
Focus on space exploration, astronaut training, and NASA missions.
''';

      final content = [Content.text(spacePrompt)];
      final response = await _model.generateContent(content);
      
      final aiResponse = response.text ?? 'Sorry, I couldn\'t generate a response. Please try again.';
      
      _messages.add(ChatMessage(
        text: aiResponse,
        isUser: false,
        timestamp: DateTime.now(),
      ));
      
      DebugUtils.log('AI response received successfully');
    } catch (e) {
      DebugUtils.logError('Error generating AI response', error: e);
      _addSystemMessage('Failed to get a response from AI. Please check your connection and try again.');
    }

    setState(() {
      _isLoading = false;
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _clearChat() {
    setState(() {
      _messages.clear();
    });
    _addWelcomeMessage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepSpace,
      appBar: AppBar(
        title: Text('NASA AI Assistant'),
        backgroundColor: AppColors.darkSpace,
        actions: [
          IconButton(
            icon: Icon(Icons.clear_all),
            onPressed: _clearChat,
            tooltip: 'Clear Chat',
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: _messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.all(16),
                    itemCount: _messages.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length) {
                        return _buildLoadingIndicator();
                      }
                      return _buildMessageBubble(_messages[index]);
                    },
                  ),
          ),
          
          // Input area
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.psychology,
            size: 64,
            color: AppColors.neonCyan,
          ),
          SizedBox(height: 16),
          Text(
            'NASA AI Assistant',
            style: AppTextStyles.heading2.copyWith(
              color: AppColors.neonCyan,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Ask me anything about space exploration!',
            style: AppTextStyles.bodyLarge.copyWith(
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isUser 
            ? MainAxisAlignment.end 
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: message.isSystem 
                  ? AppColors.errorRed 
                  : AppColors.neonCyan,
              child: Icon(
                message.isSystem ? Icons.error : Icons.psychology,
                size: 16,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: message.isUser 
                    ? AppColors.spaceBlue
                    : message.isSystem
                        ? AppColors.errorRed.withOpacity(0.2)
                        : AppColors.darkSpace,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: message.isUser 
                      ? AppColors.spaceBlue
                      : message.isSystem
                          ? AppColors.errorRed
                          : AppColors.neonCyan.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isUser) ...[
            SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.spaceBlue,
              child: Icon(
                Icons.person,
                size: 16,
                color: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.neonCyan,
            child: Icon(
              Icons.psychology,
              size: 16,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 8),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.darkSpace,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.neonCyan.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.neonCyan,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  'Thinking...',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkSpace,
        border: Border(
          top: BorderSide(
            color: AppColors.neonCyan.withOpacity(0.3),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Ask about space exploration...',
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white54,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(
                    color: AppColors.neonCyan.withOpacity(0.3),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(
                    color: AppColors.neonCyan.withOpacity(0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(
                    color: AppColors.neonCyan,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: AppColors.midSpace,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              style: AppTextStyles.bodyLarge.copyWith(
                color: Colors.white,
              ),
              maxLines: null,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          SizedBox(width: 12),
          FloatingActionButton(
            onPressed: _isLoading ? null : _sendMessage,
            backgroundColor: AppColors.neonCyan,
            foregroundColor: Colors.black,
            child: Icon(Icons.send),
            mini: true,
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isSystem;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isSystem = false,
  });
}
