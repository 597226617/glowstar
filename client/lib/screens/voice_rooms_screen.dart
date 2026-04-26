import 'package:flutter/material.dart';

/// Voice Rooms List Screen for GlowStar
/// 
/// Browse and join active voice rooms
class VoiceRoomsScreen extends StatefulWidget {
  @override
  _VoiceRoomsScreenState createState() => _VoiceRoomsScreenState();
}

class _VoiceRoomsScreenState extends State<VoiceRoomsScreen> {
  final List<Map<String, dynamic>> _rooms = [
    {
      'id': 'room1',
      'topic': '今晚聊数学函数',
      'creator': '学霸小明',
      'participants': 5,
      'maxParticipants': 8,
      'tags': ['学习', '数学'],
    },
    {
      'id': 'room2',
      'topic': '深夜电台 🌙',
      'creator': '夜猫子小红',
      'participants': 3,
      'maxParticipants': 10,
      'tags': ['闲聊', '深夜'],
    },
    {
      'id': 'room3',
      'topic': '英语角 - 练口语',
      'creator': 'EnglishMaster',
      'participants': 7,
      'maxParticipants': 8,
      'tags': ['学习', '英语'],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('语音房间'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _rooms.length,
        itemBuilder: (context, index) {
          final room = _rooms[index];
          final isFull = room['participants'] >= room['maxParticipants'];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple, Colors.blue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.headset, color: Colors.white, size: 28),
              ),
              title: Text(room['topic']),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('由 ${room['creator']} 创建'),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.people, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${room['participants']}/${room['maxParticipants']} 人',
                        style: TextStyle(color: isFull ? Colors.red : Colors.grey[600], fontSize: 12),
                      ),
                      const SizedBox(width: 12),
                      ...((room['tags'] as List).map((tag) => Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Chip(
                          label: Text(tag, style: const TextStyle(fontSize: 11)),
                          backgroundColor: Colors.purple.withOpacity(0.1),
                          visualDensity: VisualDensity.compact,
                        ),
                      ))),
                    ],
                  ),
                ],
              ),
              trailing: ElevatedButton(
                onPressed: isFull ? null : () {
                  Navigator.pushNamed(context, '/voice-room', arguments: room);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isFull ? Colors.grey : Colors.purple,
                ),
                child: Text(isFull ? '已满' : '加入'),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createRoom,
        child: const Icon(Icons.add),
        backgroundColor: Colors.purple,
      ),
    );
  }

  void _createRoom() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('创建语音房间', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                hintText: '房间主题...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('创建房间'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
