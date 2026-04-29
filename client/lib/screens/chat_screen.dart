import 'package:flutter/material.dart';

/// Chat Screen for GlowStar
/// 
/// Real-time messaging with match suggestions and icebreakers
class ChatScreen extends StatefulWidget {
  final String matchId;
  final String matchName;
  final String matchAvatar;
  final List<String> commonInterests;

  ChatScreen({
    Key key,
    @required this.matchId,
    @required this.matchName,
    @required this.matchAvatar,
    @required this.commonInterests,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _textController = TextEditingController();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _addIcebreakerMessage();
  }

  void _addIcebreakerMessage() {
    if (widget.commonInterests.isNotEmpty) {
      setState(() {
        _messages.add({
          'type': 'system',
          'text': '💡 破冰建议：你们都喜欢 ${widget.commonInterests.join('、')}！',
        });
      });
    }
  }

  void _sendMessage() {
    if (_textController.text.trim().isEmpty) return;

    setState(() {
      _messages.add({
        'type': 'user',
        'text': _textController.text.trim(),
        'timestamp': DateTime.now(),
      });
      _textController.clear();
      _isTyping = true;
    });

    // Simulate match response
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _isTyping = false;
        _messages.add({
          'type': 'match',
          'text': _getRandomResponse(),
          'timestamp': DateTime.now(),
        });
      });
    });
  }

  String _getRandomResponse() {
    List<String> responses = [
      '嗨！很高兴认识你！',
      '看到你也喜欢${widget.commonInterests.isNotEmpty ? widget.commonInterests[0] : '这个'}，太巧了！',
      '你好呀！最近在忙什么？',
      '哈哈，是啊！一起出来学习/玩吗？',
    ];
    return responses[DateTime.now().millisecond % responses.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.matchAvatar),
              radius: 16,
            ),
            SizedBox(width: 8),
            Text(widget.matchName),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),
          if (_isTyping)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${widget.matchName} 正在输入...',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ),
            ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    if (message['type'] == 'system') {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Center(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              message['text'],
              style: TextStyle(fontSize: 12, color: Colors.grey[800]),
            ),
          ),
        ),
      );
    }

    bool isUser = message['type'] == 'user';
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              backgroundImage: NetworkImage(widget.matchAvatar),
              radius: 16,
            ),
            SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isUser ? Theme.of(context).primaryColor : Colors.grey[300],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                message['text'],
                style: TextStyle(
                  color: isUser ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ),
          if (isUser) ...[
            SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              radius: 16,
              child: Icon(Icons.person, size: 16, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: '输入消息...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Theme.of(context).primaryColor,
            child: IconButton(
              icon: Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
