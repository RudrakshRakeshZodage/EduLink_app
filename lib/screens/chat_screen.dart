import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> messages = [
    {'text': 'Hi! I am your AI Tutor. Ask me anything 😊', 'isMe': false, 'time': '10:30 AM'},
  ];
  bool loading = false;

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    final text = _controller.text;
    setState(() {
      messages.add({
        'text': text,
        'isMe': true,
        'time': TimeOfDay.now().format(context),
      });
      _controller.clear();
      loading = true;
    });

    // Simulate AI response
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          messages.add({
            'text': 'That is a great question! Let me explain...',
            'isMe': false,
            'time': TimeOfDay.now().format(context),
          });
          loading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => appState.setScreen('home'),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFFC084FC), Color(0xFF2DD4BF)]),
                shape: BoxShape.circle,
              ),
              child: const Text('AI', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 8),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI Tutor', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('Online', style: TextStyle(fontSize: 12, color: Colors.green)),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                return Align(
                  alignment: msg['isMe'] ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: msg['isMe'] ? const Color(0xFFC084FC) : Colors.white,
                      gradient: msg['isMe'] ? const LinearGradient(colors: [Color(0xFFC084FC), Color(0xFF60A5FA)]) : null,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(msg['isMe'] ? 16 : 4),
                        bottomRight: Radius.circular(msg['isMe'] ? 4 : 16),
                      ),
                      boxShadow: [
                         BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 2, offset: const Offset(0, 1)),
                      ]
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          msg['text'],
                          style: TextStyle(color: msg['isMe'] ? Colors.white : Colors.black87),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          msg['time'],
                          style: TextStyle(fontSize: 10, color: msg['isMe'] ? Colors.white70 : Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (loading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('AI is typing...', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
            ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Ask your doubt...',
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send),
                  color: Colors.white,
                  style: IconButton.styleFrom(backgroundColor: const Color(0xFFC084FC)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
