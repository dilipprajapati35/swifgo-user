import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RideChatScreen extends StatefulWidget {
  const RideChatScreen({super.key});

  @override
  State<RideChatScreen> createState() => _RideChatScreenState();
}

class _RideChatScreenState extends State<RideChatScreen> {
  final List<Map<String, dynamic>> _messages = [
    {'isMe': false, 'text': 'Good Evening!', 'time': '8:29 pm'},
    {'isMe': false, 'text': 'Welcome to Car2go Customer Service', 'time': '8:29 pm'},
    {'isMe': true, 'text': 'Welcome to Car2go Customer Service', 'time': '8:29 pm'},
    {'isMe': false, 'text': 'Welcome to Car2go Customer Service', 'time': '8:29 pm'},
    {'isMe': true, 'text': 'Welcome to Car2go Customer Service', 'time': 'Just now'},
  ];
  final TextEditingController _controller = TextEditingController();

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    setState(() {
      _messages.add({'isMe': true, 'text': _controller.text.trim(), 'time': 'Just now'});
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Chat', style: GoogleFonts.nunito(color: Colors.black, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isMe = msg['isMe'] as bool;
                return Column(
                  crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (!isMe)
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.grey.shade200,
                            child: Icon(Icons.person, color: Colors.blue, size: 20),
                          ),
                        if (!isMe) SizedBox(width: 8),
                        Flexible(
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 2),
                            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: isMe ? Colors.white : Color(0xffF2F2F2),
                              border: isMe ? Border.all(color: Color(0xff3E57B4)) : null,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              msg['text'],
                              style: GoogleFonts.nunito(fontSize: 15, color: Colors.black),
                            ),
                          ),
                        ),
                        if (isMe) SizedBox(width: 8),
                        if (isMe)
                          SizedBox(width: 32),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        left: isMe ? 0 : 48,
                        right: isMe ? 0 : 0,
                        top: 2,
                        bottom: 8,
                      ),
                      child: Text(
                        msg['time'],
                        style: GoogleFonts.nunito(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.add, color: Colors.grey),
                  onPressed: () {},
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xffF2F2F2),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Type your message',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Color(0xff3E57B4)),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 