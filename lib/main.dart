import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shimmer/shimmer.dart';
import 'fraud_detection_service.dart';
import 'message_model.dart';
import 'additional_features_screen.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(const FraudGuardApp());
}

class FraudGuardApp extends StatelessWidget {
  const FraudGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fraud Guard - Cyber Awareness Bot',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2196F3),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FraudDetectionService _fraudService = FraudDetectionService();
  
  List<Message> _messages = [];
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _initializeChat();
  }
  
  Future<void> _initializeChat() async {
    final dailyTip = await _fraudService.getDailyTip();
    setState(() {
      _messages.add(Message.bot(
        "Hello! Staying safe online starts with awareness. Daily Tip: $dailyTip"
      ));
    });
  }
  
  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    
    final userMessage = _messageController.text.trim();
    _messageController.clear();
    
    setState(() {
      _messages.add(Message.user(userMessage));
      _isLoading = true;
    });
    
    _scrollToBottom();
    
    try {
      final botResponse = await _fraudService.analyzeFraudRisk(userMessage);
      
      setState(() {
        _messages.add(Message.bot(botResponse));
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(Message.bot(
          "I apologize, but I encountered an error. Please try again."
        ));
        _isLoading = false;
      });
    }
    
    _scrollToBottom();
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.arrow_back),
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Fraud Guard - Cyber Awareness Bot',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdditionalFeaturesScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.more_vert),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          if (_isLoading)
            Container(
              padding: const EdgeInsets.all(16),
              child: _buildTypingIndicator(),
            ),
          _buildMessageInput(),
        ],
      ),
    );
  }
  
  Widget _buildMessageBubble(Message message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: message.isUser 
            ? MainAxisAlignment.end 
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF2196F3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.security,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser 
                    ? const Color(0xFF2196F3) 
                    : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser ? Colors.white : Colors.black87,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: message.isUser 
                          ? Colors.white70 
                          : Colors.grey[600],
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.person,
                color: Colors.grey[600],
                size: 18,
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildTypingIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFF2196F3),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.security,
            color: Colors.white,
            size: 18,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(),
                const SizedBox(width: 4),
                _buildDot(),
                const SizedBox(width: 4),
                _buildDot(),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildDot() {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: Colors.grey[400],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
  
  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Ask about a threat or report suspicious activity...',
                hintStyle: TextStyle(color: Colors.grey[500]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(color: Color(0xFF2196F3)),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2196F3),
              borderRadius: BorderRadius.circular(25),
            ),
            child: IconButton(
              onPressed: _sendMessage,
              icon: const Icon(
                Icons.send,
                color: Colors.white,
              ),
            ),
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
      return '${difference.inDays}d ago';
    }
  }
}
