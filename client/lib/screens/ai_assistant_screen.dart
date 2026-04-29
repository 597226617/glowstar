import 'package:flutter/material.dart';

/// AI Assistant Screen for GlowStar
/// 
/// Provides AI-powered tutoring and study help
class AIAssistantScreen extends StatefulWidget {
  @override
  _AIAssistantScreenState createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _textController = TextEditingController();
  bool _isTyping = false;

  final List<Map<String, dynamic>> _quickQuestions = [
    {'question': '帮我解这道数学题', 'icon': '📐'},
    {'question': '英语作文怎么写？', 'icon': '✍️'},
    {'question': '物理实验步骤', 'icon': '🔬'},
    {'question': '历史事件时间线', 'icon': '📜'},
    {'question': '化学方程式配平', 'icon': '⚗️'},
    {'question': '学习计划建议', 'icon': '📅'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.smart_toy, color: Colors.white),
            SizedBox(width: 8),
            Text('AI 学习助手'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? _buildWelcomeScreen()
                : ListView.builder(
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
                  'AI 正在思考...',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ),
            ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildWelcomeScreen() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.smart_toy, size: 80, color: Theme.of(context).primaryColor),
            SizedBox(height: 16),
            Text(
              '你好！我是 AI 学习助手',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '有什么学习问题可以问我',
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 32),
            Text(
              '快捷问题：',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _quickQuestions.map((q) => ElevatedButton.icon(
                onPressed: () => _sendQuickQuestion(q['question']),
                icon: Text(q['icon'], style: TextStyle(fontSize: 20)),
                label: Text(q['question']),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    bool isUser = message['type'] == 'user';
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              child: Icon(Icons.smart_toy, color: Colors.white),
              radius: 16,
            ),
            SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? Theme.of(context).primaryColor : Colors.grey[200],
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
              child: Icon(Icons.person, color: Colors.white, size: 16),
              radius: 16,
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
                hintText: '输入学习问题...',
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

    // Simulate AI response
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _isTyping = false;
        _messages.add({
          'type': 'ai',
          'text': _getAIResponse(),
          'timestamp': DateTime.now(),
        });
      });
    });
  }

  void _sendQuickQuestion(String question) {
    _textController.text = question;
    _sendMessage();
  }

  String _getAIResponse() {
    List<String> responses = [
      '这是一个好问题！让我来帮你解答...',
      '根据我的理解，这个问题可以从以下几个方面分析...',
      '首先，我们需要明确题目的关键点...',
      '让我用简单的方式解释这个概念...',
      '这是一个常见的学习难点，我来帮你理清思路...',
    ];
    return responses[DateTime.now().millisecond % responses.length];
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
