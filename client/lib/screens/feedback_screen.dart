import 'package:flutter/material.dart';

/// Feedback Screen for GlowStar
/// 
/// Allows users to submit feedback and bug reports
class FeedbackScreen extends StatefulWidget {
  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _feedbackType = 'bug';
  int _rating = 3;

  final List<String> _feedbackTypes = [
    'bug',
    'feature',
    'improvement',
    'other',
  ];

  final Map<String, String> _feedbackTypeLabels = {
    'bug': 'Bug 报告',
    'feature': '功能建议',
    'improvement': '改进建议',
    'other': '其他',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('反馈'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('反馈类型', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _feedbackTypes.map((type) => ChoiceChip(
                label: Text(_feedbackTypeLabels[type]!),
                selected: _feedbackType == type,
                onSelected: (selected) {
                  setState(() {
                    _feedbackType = type;
                  });
                },
              )).toList(),
            ),
            SizedBox(height: 24),
            Text('评分', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) => IconButton(
                icon: Icon(
                  index < _rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 40,
                ),
                onPressed: () {
                  setState(() {
                    _rating = index + 1;
                  });
                },
              )),
            ),
            SizedBox(height: 24),
            Text('标题', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: '简要描述你的反馈',
                border: OutlineInputBorder(),
              ),
              maxLines: 1,
            ),
            SizedBox(height: 16),
            Text('详细描述', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                hintText: '请详细描述你的反馈或建议...',
                border: OutlineInputBorder(),
              ),
              maxLines: 8,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitFeedback,
              child: Text('提交反馈'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                minimumSize: Size(double.infinity, 0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitFeedback() {
    if (_titleController.text.trim().isEmpty || _descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('请填写标题和详细描述')),
      );
      return;
    }

    // Submit feedback
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('提交成功'),
        content: Text('感谢你的反馈！我们会尽快处理。'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text('确定'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
