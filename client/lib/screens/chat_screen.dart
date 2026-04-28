import 'package:flutter/material.dart';
import 'package:glowstar/model/interest_tag.dart';

/// Chat Screen with AI Icebreaker Suggestions
/// 
/// Features:
/// - AI-generated icebreaker suggestions at the top
/// - 3 recommended opening messages
/// - Free messaging (no paywall)
/// - Safety tips for first meetings
/// - Shared interests highlight
class ChatScreen extends StatefulWidget {
  final String userId;
  final String targetUserId;
  final String targetNickname;
  final List<InterestTag> sharedInterests;
  final String? matchReason;

  const ChatScreen({
    Key? key,
    required this.userId,
    required this.targetUserId,
    required this.targetNickname,
    this.sharedInterests = const [],
    this.matchReason,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<_ChatMessage> _messages = [];
  bool _showIcebreakers = true;
  List<String> _icebreakers = [];

  @override
  void initState() {
    super.initState();
    _generateIcebreakers();
  }

  void _generateIcebreakers() {
    if (widget.sharedInterests.isNotEmpty) {
      for (var interest in widget.sharedInterests.take(3)) {
        String category = interest.category;
        String name = interest.name;
        
        switch (category) {
          case '音乐':
            _icebreakers.add('${widget.targetNickname}，你也喜欢$name！最近有听什么好听的吗？');
            break;
          case '运动':
            _icebreakers.add('嗨～看到你也喜欢$name，最近有在运动吗？');
            break;
          case '学习':
            _icebreakers.add('看到你也对$name感兴趣，一起学习怎么样？📚');
            break;
          case '美食':
            _icebreakers.add('吃货认证！你也喜欢$name，附近有什么好吃的推荐吗？');
            break;
          default:
            _icebreakers.add('看到你也喜欢$name，很高兴遇到同好！✨');
        }
      }
    } else {
      _icebreakers = [
        '嗨 ${widget.targetNickname}，在发光星球认识你很高兴！',
        '你好呀～看到你就在附近，想认识一下～',
        'Hi！有什么有趣的兴趣可以分享吗？😄',
      ];
    }
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
      appBar: AppBar(
        title: Column(
          children: [
            Text(widget.targetNickname, style: const TextStyle(fontSize: 16)),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6, height: 6,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 4),
                Text('在线', style: TextStyle(fontSize: 11, color: Colors.white70)),
              ],
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showChatOptions(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Shared interests bar
          if (widget.sharedInterests.isNotEmpty)
            _buildSharedInterestsBar(),
          
          // Icebreaker suggestions (show at start)
          if (_showIcebreakers && _messages.isEmpty)
            _buildIcebreakerPanel(),
          
          // Safety tip (show once)
          if (_messages.isEmpty)
            _buildSafetyTip(),
          
          // Messages
          Expanded(
            child: _messages.isEmpty
                ? _buildEmptyChatState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
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

  Widget _buildSharedInterestsBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.08),
        border: Border(bottom: BorderSide(color: Colors.purple.withOpacity(0.15))),
      ),
      child: Row(
        children: [
          const Icon(Icons.favorite, size: 14, color: Colors.purple),
          const SizedBox(width: 6),
          Text(
            '共同兴趣: ${widget.sharedInterests.map((i) => '${i.icon} ${i.name}').join(' · ')}',
            style: const TextStyle(color: Colors.purple, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildIcebreakerPanel() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.auto_awesome, size: 16, color: Colors.purple),
              SizedBox(width: 6),
              Text(
                'AI 破冰建议',
                style: TextStyle(
                  color: Colors.purple,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ..._icebreakers.map((icebreaker) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: InkWell(
              onTap: () => _sendIcebreaker(icebreaker),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.purple.withOpacity(0.1)),
                ),
                child: Text(
                  icebreaker,
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildSafetyTip() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: const [
          Icon(Icons.shield_outlined, size: 14, color: Colors.orange),
          SizedBox(width: 6),
          Expanded(
            child: Text(
              '💡 安全提示：第一次见面建议选择公共场所哦～',
              style: TextStyle(color: Colors.orange, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyChatState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(
            '和 ${widget.targetNickname} 开始聊天',
            style: TextStyle(color: Colors.grey[500], fontSize: 15),
          ),
          const SizedBox(height: 4),
          Text(
            '点击上方的破冰建议，或直接输入消息',
            style: TextStyle(color: Colors.grey[400], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(_ChatMessage message) {
    final isMe = message.isMe;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: Colors.purple.withOpacity(0.3),
              child: Text(
                widget.targetNickname[0],
                style: const TextStyle(color: Colors.purple, fontSize: 12),
              ),
            ),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? Colors.purple : Colors.grey[100],
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black87,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 6),
            CircleAvatar(
              radius: 14,
              backgroundColor: Colors.amber.withOpacity(0.3),
              child: const Icon(Icons.star, size: 14, color: Colors.amber),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey[200]!)),
        ),
        child: Row(
          children: [
            // Attachment buttons
            IconButton(
              icon: Icon(Icons.mic, color: Colors.grey[600]),
              onPressed: () {
                // TODO: Voice message
              },
            ),
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: '说点什么...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.purple,
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white, size: 18),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendIcebreaker(String text) {
    _messageController.text = text;
    _sendMessage();
    setState(() => _showIcebreakers = false);
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    
    setState(() {
      _messages.add(_ChatMessage(
        text: text,
        isMe: true,
        timestamp: DateTime.now(),
      ));
      _messageController.clear();
    });
    
    // Scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
    
    // Simulate reply (in real app, this comes from WebSocket)
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _messages.add(_ChatMessage(
            text: _generateAutoReply(text),
            isMe: false,
            timestamp: DateTime.now(),
          ));
        });
      }
    });
  }

  String _generateAutoReply(String message) {
    // Simple auto-reply for demo
    final replies = [
      '哈哈，谢谢你！很高兴认识你～',
      '嗯嗯，我也是！感觉我们挺有缘的 ✨',
      '对呀对呀！你喜欢这个多久了？',
      '太好了，终于找到同好了！',
      '谢谢你的消息，让我好开心 😊',
    ];
    return replies[DateTime.now().millisecond % replies.length];
  }

  void _showChatOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('查看主页'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed('/profile-view', arguments: {
                  'userId': widget.targetUserId,
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('消息免打扰'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.block, color: Colors.red),
              title: const Text('拉黑', style: TextStyle(color: Colors.red)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.flag, color: Colors.orange),
              title: const Text('举报', style: TextStyle(color: Colors.orange)),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isMe;
  final DateTime timestamp;

  _ChatMessage({
    required this.text,
    required this.isMe,
    required this.timestamp,
  });
}
