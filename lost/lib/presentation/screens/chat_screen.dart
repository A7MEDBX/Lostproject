import 'package:flutter/material.dart';

/// Chat Screen
class ChatScreen extends StatefulWidget {
  final String? userName;
  final String? userId;
  final bool? isOnline;

  const ChatScreen({super.key, this.userName, this.userId, this.isOnline});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  bool _hasText = false;
  final List<ChatMessage> _messages = [
    ChatMessage(
      message: 'Hi! I found your lost item. Is it still available?',
      isSentByMe: false,
      time: '10:30 AM',
    ),
    ChatMessage(
      message: 'Yes! Where did you find it?',
      isSentByMe: true,
      time: '10:32 AM',
    ),
    ChatMessage(
      message: 'I found it near the campus library',
      isSentByMe: false,
      time: '10:33 AM',
    ),
    ChatMessage(
      message: 'Great! Can we meet today?',
      isSentByMe: true,
      time: '10:35 AM',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _messageController.addListener(() {
      setState(() {
        _hasText = _messageController.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      setState(() {
        _messages.add(
          ChatMessage(
            message: _messageController.text.trim(),
            isSentByMe: true,
            time: 'Now',
          ),
        );
        _messageController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0A3D91),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
              onPressed: () => Navigator.pop(context),
            ),
            title: Row(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person,
                        size: 24,
                        color: Colors.grey[700],
                      ),
                    ),
                    if (widget.isOnline ?? false)
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.userName ?? 'Ahmed Ragab',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        (widget.isOnline ?? false) ? 'Online' : 'Offline',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.more_vert,
                  color: Colors.white,
                  size: 24,
                ),
                onPressed: () {
                  // TODO: Show menu options
                },
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // Date Badge
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 16),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF0A3D91),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Today',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          // Chat Messages List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),

          // Message Input Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Message Input Label
                Padding(padding: const EdgeInsets.only(left: 4, bottom: 8)),

                // Message Input Field
                Row(
                  children: [
                    // Emoji Button
                    IconButton(
                      icon: Icon(
                        Icons.emoji_emotions_outlined,
                        color: Colors.grey[600],
                        size: 35,
                      ),
                      onPressed: () {
                        // TODO: Show emoji picker
                      },
                    ),
                    const SizedBox(width: 8),

                    // Message Input Field
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            hintStyle: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[400],
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                Icons.attach_file,
                                color: Colors.grey[600],
                                size: 22,
                              ),
                              onPressed: () {
                                // TODO: Attach file
                              },
                            ),
                          ),
                          maxLines: null,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Camera/Send Button
                    Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        color: Color(0xFF0A3D91),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          _hasText ? Icons.send : Icons.camera_alt,
                          color: Colors.white,
                          size: 22,
                        ),
                        onPressed: () {
                          if (_hasText) {
                            _sendMessage();
                          } else {
                            // TODO: Open camera
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isSentByMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!message.isSentByMe)
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.person, size: 16, color: Colors.grey[600]),
            ),
          Flexible(
            child: Column(
              crossAxisAlignment: message.isSentByMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: message.isSentByMe
                        ? const Color(0xFF0A3D91)
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    message.message,
                    style: TextStyle(
                      fontSize: 14,
                      color: message.isSentByMe ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message.time,
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          if (message.isSentByMe)
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(left: 8),
              decoration: const BoxDecoration(
                color: Color(0xFF0A3D91),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, size: 16, color: Colors.white),
            ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String message;
  final bool isSentByMe;
  final String time;

  ChatMessage({
    required this.message,
    required this.isSentByMe,
    required this.time,
  });
}
