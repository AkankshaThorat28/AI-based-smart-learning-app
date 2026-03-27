import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_alerts.dart';

class AiChatbot extends StatefulWidget {
  const AiChatbot({super.key});

  @override
  State<AiChatbot> createState() => _AiChatbotState();
}

class _AiChatbotState extends State<AiChatbot> with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  final List<Map<String, dynamic>> _attachments = [];
  bool _hasText = false;
  bool _isRecording = false;
  bool _showAttachMenu = false;
  int _recordingSeconds = 0;
  Timer? _recordingTimer;

  late AnimationController _attachMenuController;
  late Animation<double> _attachMenuAnimation;

  @override
  void initState() {
    super.initState();
    _textController.addListener(() {
      final hasText = _textController.text.trim().isNotEmpty;
      if (hasText != _hasText) setState(() => _hasText = hasText);
    });

    _attachMenuController = AnimationController(vsync: this, duration: AppTheme.animDuration);
    _attachMenuAnimation = CurvedAnimation(parent: _attachMenuController, curve: AppTheme.animCurve);

    // Welcome message
    _messages.add(_ChatMessage(text: 'Hello! I\'m your AI study assistant. Ask me anything about your lessons, or upload class materials for me to help with. 📚', isUser: false));
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _attachMenuController.dispose();
    _recordingTimer?.cancel();
    super.dispose();
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty && _attachments.isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage(
        text: text,
        isUser: true,
        attachments: _attachments.isNotEmpty ? List.from(_attachments) : null,
      ));
      _textController.clear();
      _attachments.clear();
    });
    _scrollToBottom();

    // Simulate AI response
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() {
        _messages.add(_ChatMessage(text: 'That\'s a great question! Let me think about that... 🤔\n\nBased on your study materials, here\'s what I found relevant to your query.', isUser: false));
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 80,
          duration: AppTheme.animDuration,
          curve: AppTheme.animCurve,
        );
      }
    });
  }

  void _toggleAttachMenu() {
    setState(() => _showAttachMenu = !_showAttachMenu);
    if (_showAttachMenu) {
      _attachMenuController.forward();
    } else {
      _attachMenuController.reverse();
    }
  }

  void _onAttach(String type) async {
    _toggleAttachMenu();
    if (type == 'Class Material') {
      _showMaterialPicker();
    } else {
      try {
        FileType fileType = FileType.any;
        List<String>? allowedExtensions;
        if (type == 'Image') {
          fileType = FileType.image;
        } else if (type == 'Document') {
          fileType = FileType.custom;
          allowedExtensions = ['pdf', 'doc', 'docx', 'txt', 'ppt', 'pptx', 'xls', 'xlsx'];
        }

        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: fileType,
          allowedExtensions: allowedExtensions,
          withData: true,
        );

        if (result != null && mounted) {
          setState(() {
            _attachments.add({
              'title': result.files.single.name,
              'icon': type == 'Image' ? Icons.image : Icons.insert_drive_file,
              'color': type == 'Image' ? const Color(0xFF43A047) : const Color(0xFF1E88E5),
              'bytes': result.files.single.bytes,
              'isImage': type == 'Image',
            });
          });
        }
      } catch (e) {
        if (mounted) {
          AppAlerts.showError(context, 'Could not pick file. Please try again.');
        }
      }
    }
  }

  void _showMaterialPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        final materials = [
          {'title': 'Quadratic Equations Guide', 'icon': Icons.calculate, 'color': const Color(0xFF1E88E5)},
          {'title': 'Newton\'s Laws of Motion', 'icon': Icons.science, 'color': const Color(0xFF43A047)},
          {'title': 'Human Circulatory System', 'icon': Icons.biotech, 'color': const Color(0xFF8E24AA)},
        ];
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
              const Padding(
                padding: EdgeInsets.all(20),
                child: Align(alignment: Alignment.centerLeft, child: Text('Select Class Material', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800))),
              ),
              ...materials.map((mat) => ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: (mat['color'] as Color).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: Icon(mat['icon'] as IconData, color: mat['color'] as Color, size: 20),
                ),
                title: Text(mat['title'] as String, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _attachments.add(mat));
                },
              )),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _startRecording() {
    setState(() {
      _isRecording = true;
      _recordingSeconds = 0;
    });
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() => _recordingSeconds++);
    });
  }

  void _stopRecording({bool send = false}) {
    _recordingTimer?.cancel();
    setState(() => _isRecording = false);
    if (send && _recordingSeconds > 0) {
      setState(() {
        _messages.add(_ChatMessage(text: '🎤 Voice message (${_recordingSeconds}s)', isUser: true));
      });
      _scrollToBottom();
    }
  }

  String _formatDuration(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
          ),
          child: Row(
            children: [
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  gradient: AppTheme.gradientPrimary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.smart_toy_outlined, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('AI Assistant', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                  Text('Always here to help', style: TextStyle(fontSize: 11, color: AppTheme.textTertiary)),
                ],
              ),
              const Spacer(),
              Container(
                width: 8, height: 8,
                decoration: const BoxDecoration(color: Color(0xFF43A047), shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              const Text('Online', style: TextStyle(fontSize: 11, color: AppTheme.textTertiary)),
            ],
          ),
        ),

        // Messages
        Expanded(
          child: Container(
            color: const Color(0xFFF0F2F5),
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  return _MessageBubble(message: msg);
                },
              ),
            ),
          ),
        ),

        // Attach menu
        SizeTransition(
          sizeFactor: _attachMenuAnimation,
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              border: Border(top: BorderSide(color: Colors.grey.shade100)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _AttachOption(icon: Icons.insert_drive_file_outlined, label: 'File', color: const Color(0xFF1E88E5), onTap: () => _onAttach('File')),
                _AttachOption(icon: Icons.image_outlined, label: 'Image', color: const Color(0xFF43A047), onTap: () => _onAttach('Image')),
                _AttachOption(icon: Icons.description_outlined, label: 'Document', color: const Color(0xFFFF7043), onTap: () => _onAttach('Document')),
                _AttachOption(icon: Icons.school_outlined, label: 'Class Material', color: const Color(0xFF8E24AA), onTap: () => _onAttach('Class Material')),
              ],
            ),
          ),
        ),

        // Attachment Previews
        if (_attachments.isNotEmpty)
          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade100)),
            ),
            child: SizedBox(
              height: 56,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _attachments.length,
                itemBuilder: (context, index) => _buildAttachmentChip(_attachments[index]),
              ),
            ),
          ),

        // Input bar
        Container(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.grey.shade100)),
          ),
          child: SafeArea(
            top: false,
            child: _isRecording ? _buildRecordingBar() : _buildInputBar(),
          ),
        ),
      ],
    );
  }

  Widget _buildInputBar() {
    return Row(
      children: [
        // + button
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _toggleAttachMenu,
            borderRadius: BorderRadius.circular(20),
            child: AnimatedContainer(
              duration: AppTheme.animFast,
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: _showAttachMenu ? AppTheme.brandPrimary.withValues(alpha: 0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: AnimatedRotation(
                turns: _showAttachMenu ? 0.125 : 0,
                duration: AppTheme.animDuration,
                curve: AppTheme.animCurve,
                child: Icon(Icons.add, color: _showAttachMenu ? AppTheme.brandPrimary : AppTheme.textSecondary, size: 24),
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        // Text field
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F5),
              borderRadius: BorderRadius.circular(AppTheme.inputRadius),
            ),
            child: TextField(
              controller: _textController,
              style: const TextStyle(fontSize: 14),
              maxLines: 4,
              minLines: 1,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                hintStyle: TextStyle(color: AppTheme.textTertiary, fontSize: 14),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Send / Mic button
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: (_hasText || _attachments.isNotEmpty) ? _sendMessage : _startRecording,
            borderRadius: BorderRadius.circular(22),
            child: AnimatedContainer(
              duration: AppTheme.animDuration,
              curve: AppTheme.animCurve,
              width: 44, height: 44,
              decoration: BoxDecoration(
                gradient: (_hasText || _attachments.isNotEmpty) ? AppTheme.gradientPrimary : null,
                color: (_hasText || _attachments.isNotEmpty) ? null : const Color(0xFFF3F4F5),
                borderRadius: BorderRadius.circular(22),
              ),
              child: AnimatedSwitcher(
                duration: AppTheme.animFast,
                transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                child: (_hasText || _attachments.isNotEmpty)
                    ? const Icon(Icons.rocket_launch, color: Colors.white, size: 20, key: ValueKey('send'))
                    : Icon(Icons.mic, color: AppTheme.textSecondary, size: 22, key: const ValueKey('mic')),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecordingBar() {
    return Row(
      children: [
        // Cancel
        IconButton(
          onPressed: () => _stopRecording(),
          icon: const Icon(Icons.close, color: AppTheme.textSecondary),
        ),
        // Waveform preview
        Expanded(
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFFCE4EC),
              borderRadius: BorderRadius.circular(AppTheme.inputRadius),
            ),
            child: Row(
              children: [
                const _PulsingDot(),
                const SizedBox(width: 10),
                Text('Recording...', style: TextStyle(fontSize: 13, color: Colors.red.shade700, fontWeight: FontWeight.w500)),
                const Spacer(),
                Text(_formatDuration(_recordingSeconds), style: TextStyle(fontSize: 13, color: Colors.red.shade700, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Send recording
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _stopRecording(send: true),
            borderRadius: BorderRadius.circular(22),
            child: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                gradient: AppTheme.gradientPrimary,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAttachmentChip(Map<String, dynamic> doc) {
    final color = (doc['color'] as Color?) ?? AppTheme.brandPrimary;
    final isImage = doc['isImage'] == true && doc['bytes'] != null;

    return Container(
      margin: const EdgeInsets.only(right: 8, bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isImage)
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.memory(doc['bytes'] as Uint8List, width: 32, height: 32, fit: BoxFit.cover),
            )
          else
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(doc['icon'] as IconData? ?? Icons.insert_drive_file, size: 16, color: color),
            ),
          const SizedBox(width: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 100),
            child: Text(
              doc['title'] as String,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => setState(() => _attachments.remove(doc)),
            child: Container(
              width: 20, height: 20,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, size: 12, color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;
  final List<Map<String, dynamic>>? attachments;
  _ChatMessage({required this.text, required this.isUser, this.attachments});
}

class _MessageBubble extends StatelessWidget {
  final _ChatMessage message;
  const _MessageBubble({required this.message});

  void _showFullImage(BuildContext context, Uint8List bytes) {
    showDialog(
      context: context,
      useSafeArea: false,
      builder: (context) => Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.memory(bytes),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 12,
              left: 12,
              child: Material(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => Navigator.pop(context),
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(Icons.close, color: Colors.white, size: 24),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasImages = message.attachments?.any((a) => a['isImage'] == true && a['bytes'] != null) ?? false;
    final bool hasNonImageAttachments = message.attachments?.any((a) => a['isImage'] != true || a['bytes'] == null) ?? false;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isUser)
            Container(
              width: 28, height: 28, margin: const EdgeInsets.only(right: 6, bottom: 2),
              decoration: BoxDecoration(gradient: AppTheme.gradientPrimary, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 14),
            ),
          Flexible(
            child: Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
              decoration: BoxDecoration(
                color: message.isUser ? AppTheme.brandPrimary : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(message.isUser ? 18 : 4),
                  bottomRight: Radius.circular(message.isUser ? 4 : 18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Image attachments - rendered edge-to-edge inside the bubble
                  if (hasImages)
                    ...message.attachments!.where((a) => a['isImage'] == true && a['bytes'] != null).map((doc) {
                      return GestureDetector(
                        onTap: () => _showFullImage(context, doc['bytes'] as Uint8List),
                        child: ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(18),
                            topRight: const Radius.circular(18),
                            bottomLeft: (message.text.isEmpty && !hasNonImageAttachments) ? Radius.circular(message.isUser ? 18 : 4) : Radius.zero,
                            bottomRight: (message.text.isEmpty && !hasNonImageAttachments) ? Radius.circular(message.isUser ? 4 : 18) : Radius.zero,
                          ),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 220),
                            child: Image.memory(
                              doc['bytes'] as Uint8List,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    }),

                  // Non-image attachments
                  if (hasNonImageAttachments)
                    Padding(
                      padding: EdgeInsets.only(
                        left: 10, right: 10,
                        top: hasImages ? 8 : 10,
                        bottom: message.text.isEmpty ? 10 : 4,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: message.attachments!.where((a) => a['isImage'] != true || a['bytes'] == null).map((doc) {
                          final color = (doc['color'] as Color?) ?? (message.isUser ? Colors.white70 : AppTheme.brandPrimary);
                          return Container(
                            margin: const EdgeInsets.only(bottom: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: message.isUser
                                  ? Colors.white.withValues(alpha: 0.15)
                                  : color.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  doc['icon'] as IconData? ?? Icons.description,
                                  size: 16,
                                  color: message.isUser ? Colors.white : color,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    doc['title'] as String,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: message.isUser ? Colors.white : color,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                  // Text content
                  if (message.text.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(
                        left: 14, right: 14,
                        top: (hasImages || hasNonImageAttachments) ? 6 : 10,
                        bottom: 10,
                      ),
                      child: Text(
                        message.text,
                        style: TextStyle(
                          fontSize: 14,
                          color: message.isUser ? Colors.white : AppTheme.textPrimary,
                          height: 1.4,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AttachOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AttachOption({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 6),
              Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot();

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 10, height: 10,
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.5 + _controller.value * 0.5),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}
