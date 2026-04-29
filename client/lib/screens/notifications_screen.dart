import 'package:flutter/material.dart';

/// Notifications Screen for GlowStar
/// 
/// Shows match notifications, messages, and system alerts
class NotificationsScreen extends StatefulWidget {
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<Map<String, dynamic>> _notifications = [
    {
      'type': 'match',
      'title': '新匹配！',
      'content': '你和 小明 有共同兴趣：音乐、足球',
      'avatar': 'https://example.com/avatar1.jpg',
      'time': '5 分钟前',
      'isRead': false,
    },
    {
      'type': 'message',
      'title': '新消息',
      'content': '小红：嗨！很高兴认识你！',
      'avatar': 'https://example.com/avatar2.jpg',
      'time': '15 分钟前',
      'isRead': false,
    },
    {
      'type': 'system',
      'title': '系统通知',
      'content': '你的资料已完善，匹配成功率提升 20%！',
      'avatar': null,
      'time': '1 小时前',
      'isRead': true,
    },
    {
      'type': 'study',
      'title': '学习小组邀请',
      'content': '小明 邀请你加入"数学学习小组"',
      'avatar': 'https://example.com/avatar1.jpg',
      'time': '2 小时前',
      'isRead': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('通知'),
        actions: [
          IconButton(
            icon: Icon(Icons.done_all),
            onPressed: _markAllAsRead,
          ),
        ],
      ),
      body: _notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 64, color: Colors.grey[400]),
                  SizedBox(height: 16),
                  Text('暂无通知', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(8),
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                return _buildNotificationCard(_notifications[index]);
              },
            ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    bool isRead = notification['isRead'] as bool;
    
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      color: isRead ? Colors.white : Colors.blue[50],
      child: ListTile(
        leading: _buildNotificationIcon(notification),
        title: Text(
          notification['title'],
          style: TextStyle(
            fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(notification['content']),
            SizedBox(height: 4),
            Text(
              notification['time'],
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: isRead
            ? null
            : Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
        onTap: () => _markAsRead(index),
      ),
    );
  }

  Widget _buildNotificationIcon(Map<String, dynamic> notification) {
    String type = notification['type'];
    
    if (type == 'match') {
      return CircleAvatar(
        backgroundImage: NetworkImage(notification['avatar']),
        radius: 24,
      );
    } else if (type == 'message') {
      return CircleAvatar(
        backgroundImage: NetworkImage(notification['avatar']),
        radius: 24,
      );
    } else if (type == 'system') {
      return CircleAvatar(
        backgroundColor: Colors.blue,
        radius: 24,
        child: Icon(Icons.info, color: Colors.white),
      );
    } else if (type == 'study') {
      return CircleAvatar(
        backgroundColor: Colors.green,
        radius: 24,
        child: Icon(Icons.school, color: Colors.white),
      );
    }
    
    return CircleAvatar(
      backgroundColor: Colors.grey,
      radius: 24,
      child: Icon(Icons.notifications, color: Colors.white),
    );
  }

  void _markAsRead(int index) {
    setState(() {
      _notifications[index]['isRead'] = true;
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification['isRead'] = true;
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('全部已读')),
    );
  }
}
