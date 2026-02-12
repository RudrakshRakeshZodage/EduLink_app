import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/chatgpt_service.dart';
import '../services/did_service.dart';

class AiTutorScreen extends StatefulWidget {
  const AiTutorScreen({super.key});

  @override
  State<AiTutorScreen> createState() => _AiTutorScreenState();
}

class _AiTutorScreenState extends State<AiTutorScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatGPTService _chatGPTService = ChatGPTService();
  final DidService _didService = DidService();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _currentVideoUrl;
  bool _isGeneratingVideo = false;
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    // Initial greeting
    _messages.add(ChatMessage(
      text: "Hi! I'm your AI Tutor powered by ChatGPT. Ask me anything about your studies!",
      isUser: false,
    ));
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _videoController?.dispose();
    super.dispose();
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

  // Quick reply keywords
  String? _getQuickReply(String text) {
    final lowerText = text.toLowerCase().trim();
    
    final keywords = {
      'cpr': 'CPR (Cardiopulmonary Resuscitation) is an emergency lifesaving procedure performed when the heart stops beating.\nImmediate CPR can double or triple chances of survival after cardiac arrest. 🚑',
      'ai': 'Artificial Intelligence (AI) mimics human intelligence to perform complex tasks and learn from data independently.\nIt is the future of technology across almost all industries today. 🤖',
      'ml': 'Machine Learning (ML) uses mathematical models to help computers learn patterns from data without explicit programming.\nIt is a core subset of Artificial Intelligence used for predictions. 📊',
      'gate': 'The Graduate Aptitude Test in Engineering (GATE) is a prestigious national-level exam primarily in India.\nIt opens doors to prestigious masters programs and high-paying PSU job opportunities. 🎓',
      'database': 'A database is an organized collection of structured information or data stored electronically in a computer system.\nIt is typically controlled by a Database Management System (DBMS) for efficient storage. 🗄️',
      'blockchain': 'Blockchain is a decentralized, distributed ledger technology that records transactions across many computers securely.\nIt ensures data integrity and absolute transparency without the need for a central authority. ⛓️',
      'math': 'Mathematics is the science of numbers, patterns, and logical reasoning. 📐',
      'maths': 'Mathematics is the science of numbers, patterns, and logical reasoning. 📐',
      'python': 'Python is a versatile programming language known for simplicity and powerful libraries. 🐍',
      'java': 'Java is an object-oriented programming language used for enterprise applications. ☕',
      'hello': 'Hello! I\'m your AI tutor. Ask me anything about your studies! 👋',
      'hi': 'Hi there! Ready to learn? Ask me any question! 😊',
    };

    // Check for exact matches first
    if (keywords.containsKey(lowerText)) {
      return keywords[lowerText];
    }

    // Check if any keyword is contained in the text
    for (var entry in keywords.entries) {
      if (lowerText.contains(entry.key)) {
        return entry.value;
      }
    }

    return null;
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _isLoading = true;
    });
    _messageController.clear();
    _scrollToBottom();

    // Check for quick reply first
    String? response;
    final quickReply = _getQuickReply(text);
    if (quickReply != null) {
      response = quickReply;
    } else {
      // Call ChatGPT API
      response = await _chatGPTService.chat(text);
    }
    
    setState(() {
      _messages.add(ChatMessage(text: response!, isUser: false));
      _isLoading = false;
      _isGeneratingVideo = true;
    });
    _scrollToBottom();

    // Generate video avatar (in background)
    final videoUrl = await _didService.createTalk(response);
    
    if (videoUrl != null) {
      // Initialize video player
      _videoController = VideoPlayerController.networkUrl(Uri.parse(videoUrl))
        ..initialize().then((_) {
          setState(() {
            _currentVideoUrl = videoUrl;
            _isGeneratingVideo = false;
          });
          _videoController?.play();
        });
    } else {
      setState(() {
        _isGeneratingVideo = false;
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Color(0xFF7C3AED),
              child: Icon(Icons.smart_toy, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI Tutor', style: GoogleFonts.poppins(fontSize: 18)),
                Text(
                  'Powered by ChatGPT',
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Video Avatar Area
          if (_currentVideoUrl != null || _isGeneratingVideo)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.grey.shade900, Colors.purple.shade900],
                ),
              ),
              child: _isGeneratingVideo
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(color: Colors.white),
                          const SizedBox(height: 16),
                          Text(
                            'Generating video avatar...',
                            style: GoogleFonts.inter(color: Colors.white70, fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'This may take 20-30 seconds',
                            style: GoogleFonts.inter(color: Colors.white54, fontSize: 12),
                          ),
                        ],
                      ).animate().fadeIn(),
                    )
                  : _videoController != null && _videoController!.value.isInitialized
                      ? Stack(
                          children: [
                            Center(
                              child: AspectRatio(
                                aspectRatio: _videoController!.value.aspectRatio,
                                child: VideoPlayer(_videoController!),
                              ),
                            ),
                            Positioned(
                              bottom: 16,
                              right: 16,
                              child: FloatingActionButton.small(
                                backgroundColor: Colors.white.withOpacity(0.2),
                                onPressed: () {
                                  setState(() {
                                    _videoController!.value.isPlaying
                                        ? _videoController!.pause()
                                        : _videoController!.play();
                                  });
                                },
                                child: Icon(
                                  _videoController!.value.isPlaying
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                  color: Colors.white,
                                ),
                              ).animate().scale(delay: 300.ms),
                            ),
                            Positioned(
                              top: 16,
                              left: 16,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.fiber_manual_record, color: Colors.white, size: 12),
                                    const SizedBox(width: 6),
                                    Text(
                                      'AI Avatar Speaking',
                                      style: GoogleFonts.inter(color: Colors.white, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ).animate().slideX(begin: -1, duration: 300.ms),
                            ),
                          ],
                        ).animate().fadeIn(duration: 500.ms)
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.video_library, size: 64, color: Colors.white54),
                              const SizedBox(height: 12),
                              Text(
                                'Video Ready',
                                style: GoogleFonts.inter(color: Colors.white70, fontSize: 16),
                              ),
                            ],
                          ),
                        ),
            ).animate().slideY(begin: -0.5, duration: 400.ms),

          // Messages List
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

          // Loading Indicator
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  const CircularProgressIndicator(),
                  const SizedBox(width: 12),
                  Text('AI is thinking...', style: GoogleFonts.inter(color: Colors.grey)),
                ],
              ),
            ),

          // Input Area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
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
                      hintText: 'Ask me anything...',
                      hintStyle: GoogleFonts.inter(color: Colors.grey.shade400),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    onSubmitted: (text) {
                      if (text.trim().isNotEmpty) {
                        _sendMessage(text.trim());
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFC084FC), Color(0xFF6366F1)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: () {
                      final text = _messageController.text.trim();
                      if (text.isNotEmpty) {
                        _sendMessage(text);
                      }
                    },
                    icon: const Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: message.isUser
              ? const Color(0xFF7C3AED)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message.text,
          style: GoogleFonts.inter(
            color: message.isUser ? Colors.white : Colors.black87,
            fontSize: 14,
          ),
        ),
      ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}
