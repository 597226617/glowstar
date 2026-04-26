import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

/// Voice Card Screen for GlowStar
/// 
/// Users record a 10-second voice intro
/// Others can play it to "hear" the person
class VoiceCardScreen extends StatefulWidget {
  final String userId;
  final String? existingAudioUrl;
  final int? existingDuration;

  const VoiceCardScreen({
    Key? key,
    required this.userId,
    this.existingAudioUrl,
    this.existingDuration,
  }) : super(key: key);

  @override
  _VoiceCardScreenState createState() => _VoiceCardScreenState();
}

class _VoiceCardScreenState extends State<VoiceCardScreen> with SingleTickerProviderStateMixin {
  bool _isRecording = false;
  bool _hasRecording = false;
  int _recordDuration = 0;
  double _waveformProgress = 0;
  late AnimationController _animController;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  // Simulated waveform data
  final List<double> _waveformBars = List.generate(30, (i) => 0.2 + (i % 5) * 0.15);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    if (widget.existingAudioUrl != null) {
      _hasRecording = true;
      _recordDuration = widget.existingDuration ?? 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('声音名片'),
      ),
      body: Column(
        children: [
          // Header explanation
          Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(Icons.mic, size: 60, color: Colors.purple.withOpacity(0.7)),
                const SizedBox(height: 16),
                const Text(
                  '用声音介绍自己',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  '录制一段 10 秒的语音\n让同好们"听"到你',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ),

          // Waveform visualization
          Expanded(
            child: Center(
              child: _hasRecording
                  ? _buildWaveformDisplay()
                  : _buildRecordingArea(),
            ),
          ),

          // Action buttons
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_hasRecording) ...[
                  OutlinedButton.icon(
                    onPressed: _reRecord,
                    icon: const Icon(Icons.refresh),
                    label: const Text('重新录制'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.purple,
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                ElevatedButton.icon(
                  onPressed: _hasRecording ? _saveVoiceCard : null,
                  icon: const Icon(Icons.check),
                  label: Text(_hasRecording ? '保存' : '开始录制'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordingArea() {
    return GestureDetector(
      onTapDown: (_) => _startRecording(),
      onTapUp: (_) => _stopRecording(),
      onTapCancel: () => _stopRecording(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _animController,
            builder: (context, child) {
              return Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isRecording
                      ? Colors.red.withOpacity(0.2)
                      : Colors.purple.withOpacity(0.1),
                  border: Border.all(
                    color: _isRecording ? Colors.red : Colors.purple,
                    width: 3,
                  ),
                ),
                child: Icon(
                  _isRecording ? Icons.mic : Icons.mic_none,
                  size: 50,
                  color: _isRecording ? Colors.red : Colors.purple,
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          Text(
            _isRecording
                ? '$_recordDuration/10 秒\n松开停止'
                : '按住麦克风\n开始录制',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: _isRecording ? Colors.red : Colors.grey[600],
              fontWeight: _isRecording ? FontWeight.bold : null,
            ),
          ),
          if (_isRecording) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: 200,
              child: LinearProgressIndicator(
                value: _recordDuration / 10,
                backgroundColor: Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWaveformDisplay() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Waveform bars
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _waveformBars.asMap().entries.map((entry) {
            final i = entry.key;
            final height = entry.value;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              width: 3,
              height: _isPlaying ? (height * 60) : (height * 40),
              decoration: BoxDecoration(
                color: _isPlaying && i < (_waveformProgress * _waveformBars.length)
                    ? Colors.purple
                    : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        // Play/Pause button
        GestureDetector(
          onTap: _togglePlayback,
          child: Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.purple,
            ),
            child: Icon(
              _isPlaying ? Icons.pause : Icons.play_arrow,
              size: 30,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '$_recordDuration 秒',
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
      ],
    );
  }

  void _startRecording() {
    setState(() => _isRecording = true);
    _simulateRecording();
  }

  void _stopRecording() {
    setState(() {
      _isRecording = false;
      _hasRecording = _recordDuration >= 1;
    });
  }

  void _simulateRecording() async {
    while (_isRecording && _recordDuration < 10) {
      await Future.delayed(const Duration(seconds: 1));
      if (_isRecording) {
        setState(() => _recordDuration++);
        // Randomize waveform
        setState(() {
          for (int i = 0; i < _waveformBars.length; i++) {
            _waveformBars[i] = 0.15 + (i % 7) * 0.12 + (DateTime.now().millisecond % 100) / 500;
          }
        });
      }
    }
    if (_recordDuration >= 10) _stopRecording();
  }

  void _togglePlayback() async {
    if (_isPlaying) {
      setState(() => _isPlaying = false);
    } else {
      setState(() => _isPlaying = true);
      // Simulate playback progress
      for (int i = 0; i <= _waveformBars.length; i++) {
        await Future.delayed(const Duration(milliseconds: 200));
        if (!_isPlaying) break;
        setState(() => _waveformProgress = i / _waveformBars.length);
      }
      if (_isPlaying) {
        setState(() {
          _isPlaying = false;
          _waveformProgress = 0;
        });
      }
    }
  }

  void _reRecord() {
    setState(() {
      _hasRecording = false;
      _recordDuration = 0;
      _waveformProgress = 0;
    });
  }

  void _saveVoiceCard() {
    // In real implementation, upload audio and call VoiceApi
    Navigator.pop(context, true);
  }

  @override
  void dispose() {
    _animController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }
}

/// Voice Message Widget (used in chat)
class VoiceMessageWidget extends StatefulWidget {
  final String audioUrl;
  final int duration;
  final bool isMe;

  const VoiceMessageWidget({
    Key? key,
    required this.audioUrl,
    required this.duration,
    this.isMe = false,
  }) : super(key: key);

  @override
  _VoiceMessageWidgetState createState() => _VoiceMessageWidgetState();
}

class _VoiceMessageWidgetState extends State<VoiceMessageWidget> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  @override
  Widget build(BuildContext context) {
    final barCount = 20 + widget.duration * 2;
    return GestureDetector(
      onTap: _togglePlay,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 220),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: widget.isMe ? Colors.purple : Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _isPlaying ? Icons.pause : Icons.play_arrow,
              size: 20,
              color: widget.isMe ? Colors.white : Colors.grey[700],
            ),
            const SizedBox(width: 8),
            Text(
              '${widget.duration}"',
              style: TextStyle(
                fontSize: 13,
                color: widget.isMe ? Colors.white : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _togglePlay() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
      setState(() => _isPlaying = false);
    } else {
      setState(() => _isPlaying = true);
      try {
        await _audioPlayer.play(UrlSource(widget.audioUrl));
        await Future.delayed(Duration(seconds: widget.duration));
        if (mounted) setState(() => _isPlaying = false);
      } catch (e) {
        if (mounted) setState(() => _isPlaying = false);
      }
    }
  }
}

/// Voice Room Screen
class VoiceRoomScreen extends StatefulWidget {
  final String roomId;
  final String topic;
  final String creatorNickname;

  const VoiceRoomScreen({
    Key? key,
    required this.roomId,
    required this.topic,
    required this.creatorNickname,
  }) : super(key: key);

  @override
  _VoiceRoomScreenState createState() => _VoiceRoomScreenState();
}

class _VoiceRoomScreenState extends State<VoiceRoomScreen> {
  bool _isMuted = false;
  bool _isSpeaking = false;
  final List<Map<String, dynamic>> _participants = [
    {'nickname': '主持人', 'avatar': null, 'isSpeaking': true, 'isMuted': false, isHost: true},
    {'nickname': '小明', 'avatar': null, 'isSpeaking': false, 'isMuted': false},
    {'nickname': '小红', 'avatar': null, 'isSpeaking': false, 'isMuted': true},
    {'nickname': '小李', 'avatar': null, 'isSpeaking': false, 'isMuted': false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('语音房间', style: TextStyle(fontSize: 14)),
            Text(widget.topic, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Topic banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.withOpacity(0.8), Colors.blue.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(widget.topic, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('由 ${widget.creatorNickname} 创建', style: const TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),

          // Participants grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _participants.length,
              itemBuilder: (context, index) {
                final p = _participants[index];
                return _buildParticipantCard(p);
              },
            ),
          ),

          // Bottom controls
          Container(
            padding: const EdgeInsets.only(bottom: 32),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildControlButton(
                  icon: _isMuted ? Icons.mic_off : Icons.mic,
                  label: _isMuted ? '取消静音' : '静音',
                  color: _isMuted ? Colors.red : Colors.purple,
                  onTap: () => setState(() => _isMuted = !_isMuted),
                ),
                const SizedBox(width: 24),
                _buildControlButton(
                  icon: Icons.call_end,
                  label: '离开',
                  color: Colors.red,
                  onTap: () => Navigator.pop(context),
                  size: 60,
                ),
                const SizedBox(width: 24),
                _buildControlButton(
                  icon: Icons.chat_bubble,
                  label: '文字聊天',
                  color: Colors.blue,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantCard(Map<String, dynamic> p) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: p['isSpeaking'] == true
                    ? Colors.green.withOpacity(0.3)
                    : Colors.grey[200],
                border: Border.all(
                  color: p['isSpeaking'] == true ? Colors.green : Colors.grey[300]!,
                  width: 3,
                ),
              ),
              child: p['avatar'] != null
                  ? ClipOval(child: Image.network(p['avatar']!, fit: BoxFit.cover))
                  : Center(
                      child: Text(
                        (p['nickname'] ?? '?')[0],
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                    ),
            ),
            if (p['isMuted'] == true)
              const Positioned(
                top: 0,
                right: 0,
                child: Icon(Icons.mic_off, size: 16, color: Colors.red),
              ),
            if (p['isHost'] == true)
              const Positioned(
                bottom: 0,
                child: Icon(Icons.star, size: 14, color: Colors.amber),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          p['nickname'] ?? '',
          style: const TextStyle(fontSize: 12),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    double size = 48,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
            child: Icon(icon, color: Colors.white, size: size * 0.45),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}
