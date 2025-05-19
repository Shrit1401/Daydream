import 'package:daydream/components/common/instrument_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:daydream/utils/types/types.dart';
import 'package:daydream/utils/utils.dart';
import 'package:daydream/utils/ai/ai_story.dart';

class ChatPage extends StatefulWidget {
  final Note? note;
  const ChatPage({super.key, this.note});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage>
    with SingleTickerProviderStateMixin {
  final List<ChatMessage> _messages = [];
  final List<Map<String, String>> _conversationHistory = [];
  final TextEditingController _textController = TextEditingController();
  bool _isLoading = false;
  AnimationController? _typingAnimationController;
  Animation<double>? _typingAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();

    // Add initial AI greeting
    if (widget.note != null) {
      final initialMessage =
          "I've read your journal entry from ${widget.note!.date.day} ${getMonthName(widget.note!.date.month)}. How can I help you with it?";
      _messages.add(ChatMessage(text: initialMessage, isUser: false));
      // Add the initial AI message to conversation history
      _conversationHistory.add({
        'role': 'assistant',
        'content': initialMessage,
      });
    } else {
      final initialMessage =
          "Hello! I'm your AI assistant. How can I help you today?";
      _messages.add(ChatMessage(text: initialMessage, isUser: false));
      // Add the initial AI message to conversation history
      _conversationHistory.add({
        'role': 'assistant',
        'content': initialMessage,
      });
    }
  }

  void _initializeAnimations() {
    _typingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _typingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _typingAnimationController!,
        curve: Curves.easeInOut,
      ),
    );

    _typingAnimationController!.repeat(reverse: true);
  }

  @override
  void dispose() {
    _textController.dispose();
    _typingAnimationController?.dispose();
    super.dispose();
  }

  Widget _buildTypingIndicator() {
    if (_typingAnimationController == null || _typingAnimation == null) {
      _initializeAnimations();
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: Colors.black,
            child: Text(
              'AI',
              style: GoogleFonts.dmSans(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: _typingAnimation!,
                    builder: (context, child) {
                      return Row(
                        children: [
                          _buildDot(0),
                          const SizedBox(width: 4),
                          _buildDot(1),
                          const SizedBox(width: 4),
                          _buildDot(2),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: Colors.black.withValues(
          alpha: 0.3 + (_typingAnimation!.value * 0.4),
        ),
        shape: BoxShape.circle,
      ),
    );
  }

  Future<void> _sendMessage() async {
    if (_textController.text.trim().isEmpty) return;

    final userMessage = _textController.text;
    _textController.clear();

    setState(() {
      _messages.add(ChatMessage(text: userMessage, isUser: true));
      _isLoading = true;
    });

    // Add user message to conversation history
    _conversationHistory.add({'role': 'user', 'content': userMessage});

    try {
      String response;
      if (widget.note != null) {
        // Get the journal content as plain text
        final journalContent = widget.note!.content
            .map((item) => item['insert'] as String)
            .join('');

        response = await StoryGenerator.chatAboutJournal(
          journalContent,
          userMessage,
          _conversationHistory,
        );
      } else {
        response = await StoryGenerator.generateContent(userMessage);
      }

      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(text: response, isUser: false));
          // Add AI response to conversation history
          _conversationHistory.add({'role': 'assistant', 'content': response});
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          final errorMessage =
              "I'm sorry, I encountered an error. Please try again.";
          _messages.add(ChatMessage(text: errorMessage, isUser: false));
          // Add error message to conversation history
          _conversationHistory.add({
            'role': 'assistant',
            'content': errorMessage,
          });
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        title: InstrumentText(
          widget.note != null ? 'Chat With Journal' : 'Chat Assistant',
          fontSize: 32,
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) {
                  return _buildTypingIndicator();
                }
                return _messages[index];
              },
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                        enabled: !_isLoading,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _isLoading ? null : _sendMessage,
                      icon: const Icon(Icons.send),
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage extends StatelessWidget {
  final String text;
  final bool isUser;

  const ChatMessage({super.key, required this.text, required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              backgroundColor: Colors.black,
              child: Text(
                'AI',
                style: GoogleFonts.dmSans(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? Colors.black : Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                text,
                style: GoogleFonts.dmSans(
                  color: isUser ? Colors.white : Colors.black,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Colors.grey[200],
              child: const Icon(Icons.person, color: Colors.black54),
            ),
          ],
        ],
      ),
    );
  }
}
