import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/accessibility_provider.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

// ── Message model ─────────────────────────────────────────────────────────────
class _ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;
  const _ChatMessage({required this.text, required this.isUser, required this.time});
}

class AiChatbot extends StatefulWidget {
  const AiChatbot({super.key});

  @override
  State<AiChatbot> createState() => _AiChatbotState();
}

class _AiChatbotState extends State<AiChatbot> {
  final _controller      = TextEditingController();
  final _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];

  bool _isSending       = false;
  bool _showAttachMenu  = false;
  bool _isRecording     = false;
  String _uploadedContext = '';

  // Loaded from AuthService
  int    _userId        = 0;
  String _userName      = 'User';
  String _disabilityMode = 'none';

  @override
  void initState() {
    super.initState();
    _loadUserAndHistory();
  }

  Future<void> _loadUserAndHistory() async {
    final session = await AuthService.getSession();
    if (session != null) {
      setState(() {
        _userId        = session['id'] as int;
        _userName      = session['name'] as String;
        _disabilityMode = session['disability'] as String;
      });
    }

    // Load past chat history from backend
    final history = await ApiService.getChatHistory(_userId);
    if (mounted && history.isNotEmpty) {
      final msgs = <_ChatMessage>[];
      // history is newest-first; reverse for display
      for (final h in history.reversed) {
        msgs.add(_ChatMessage(
          text: h['message'] as String,
          isUser: true,
          time: DateTime.tryParse(h['created_at'] ?? '') ?? DateTime.now(),
        ));
        msgs.add(_ChatMessage(
          text: h['reply'] as String,
          isUser: false,
          time: DateTime.tryParse(h['created_at'] ?? '') ?? DateTime.now(),
        ));
      }
      setState(() => _messages.addAll(msgs));
      _scrollToBottom();
    } else if (mounted) {
      // Welcome message on first visit
      _messages.add(_ChatMessage(
        text: 'Hi $_userName! 👋 I\'m Elevate AI, your personal study assistant. '
            'Ask me anything about your lessons or upload a document to get started!',
        isUser: false,
        time: DateTime.now(),
      ));
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage([String? override]) async {
    final text = (override ?? _controller.text).trim();
    if (text.isEmpty || _isSending) return;

    _controller.clear();
    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true, time: DateTime.now()));
      _isSending = true;
    });
    _scrollToBottom();

    try {
      final reply = await ApiService.sendChatMessage(
        userId:         _userId,
        userName:       _userName,
        message:        text,
        disabilityMode: _disabilityMode,
        context:        _uploadedContext,
      );
      if (mounted) {
        setState(() {
          _messages.add(_ChatMessage(text: reply, isUser: false, time: DateTime.now()));
        });
        _scrollToBottom();
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(_ChatMessage(
            text: '⚠️ ${e.message}',
            isUser: false,
            time: DateTime.now(),
          ));
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _messages.add(_ChatMessage(
            text: '⚠️ Could not reach the server. Make sure the backend is running.',
            isUser: false,
            time: DateTime.now(),
          ));
        });
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _pickAndUploadFile() async {
    setState(() => _showAttachMenu = false);
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'txt', 'docx'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    if (file.bytes == null) return;

    setState(() => _isSending = true);
    _addSystemMessage('📎 Uploading "${file.name}"…');

    try {
      final res = await ApiService.uploadDocument(
        fileBytes: file.bytes!,
        fileName:  file.name,
      );
      _uploadedContext = (res['text_chunks'] as List<dynamic>?)?.join('\n') ?? '';
      _addSystemMessage(
        '✅ Document loaded! I can now answer questions about "${file.name}". Ask me anything!',
      );
    } on ApiException catch (e) {
      _addSystemMessage('⚠️ Upload failed: ${e.message}');
    } catch (_) {
      _addSystemMessage('⚠️ Upload failed — please check your backend connection.');
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _addSystemMessage(String text) {
    if (!mounted) return;
    setState(() => _messages.add(
          _ChatMessage(text: text, isUser: false, time: DateTime.now()),
        ));
    _scrollToBottom();
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

  @override
  Widget build(BuildContext context) {
    final a11y = Provider.of<AccessibilityProvider>(context);

    return Scaffold(
      appBar: _buildAppBar(a11y),
      body: GestureDetector(
        onTap: () => setState(() => _showAttachMenu = false),
        child: Column(
          children: [
            Expanded(child: _buildMessageList(a11y)),
            if (_isSending) _buildTypingIndicator(),
            if (_showAttachMenu) _buildAttachMenu(),
            _buildInputBar(a11y),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(AccessibilityProvider a11y) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      titleSpacing: 0,
      leading: const SizedBox(),
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.brandPrimary, Color(0xFF2196F3)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Saamya AI',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppTheme.textPrimary),
              ),
              Text(
                _isSending ? 'Thinking…' : 'Online',
                style: TextStyle(
                  fontSize: 11,
                  color: _isSending ? Colors.orange : AppTheme.successColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.delete_outline, color: AppTheme.textSecondary),
          tooltip: 'Clear chat',
          onPressed: _confirmClearChat,
        ),
      ],
    );
  }

  void _confirmClearChat() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Chat?'),
        content: const Text('This clears your local view. History is still saved on the server.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              setState(() => _messages.clear());
              Navigator.pop(ctx);
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(AccessibilityProvider a11y) {
    if (_messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome, size: 48, color: AppTheme.brandPrimary.withValues(alpha: 0.3)),
            const SizedBox(height: 12),
            Text('Start a conversation!', style: TextStyle(color: AppTheme.textSecondary, fontSize: 15)),
          ],
        ),
      );
    }
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _messages.length,
      itemBuilder: (_, i) => _buildBubble(_messages[i], a11y),
    );
  }

  Widget _buildBubble(_ChatMessage msg, AccessibilityProvider a11y) {
    final isUser = msg.isUser;
    return Padding(
      padding: EdgeInsets.only(
        bottom: 12,
        left: isUser ? 48 : 0,
        right: isUser ? 0 : 48,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser)
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 8, bottom: 4),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.brandPrimary, Color(0xFF2196F3)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
            ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? AppTheme.brandPrimary : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                msg.text,
                style: TextStyle(
                  color: isUser ? Colors.white : AppTheme.textPrimary,
                  fontSize: 14 * (a11y.textSizeScale),
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppTheme.brandPrimary, Color(0xFF2196F3)]),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8)],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _DotPulse(delay: 0),
                SizedBox(width: 4),
                _DotPulse(delay: 200),
                SizedBox(width: 4),
                _DotPulse(delay: 400),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachMenu() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 16)],
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _attachChip(Icons.picture_as_pdf, 'PDF / DOCX / TXT', _pickAndUploadFile),
        ],
      ),
    );
  }

  Widget _attachChip(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.brandPrimary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: AppTheme.brandPrimary),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.brandPrimary)),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar(AccessibilityProvider a11y) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, -4))],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Attach button
            _iconBtn(
              icon: Icons.attach_file,
              tooltip: 'Attach file',
              onTap: () => setState(() => _showAttachMenu = !_showAttachMenu),
              active: _showAttachMenu,
            ),
            const SizedBox(width: 8),

            // Text field
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _controller,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                  style: TextStyle(fontSize: 14 * a11y.textSizeScale),
                  decoration: InputDecoration(
                    hintText: _uploadedContext.isNotEmpty
                        ? 'Ask about your document…'
                        : 'Ask Saamya AI anything…',
                    hintStyle: TextStyle(color: AppTheme.textTertiary, fontSize: 14 * a11y.textSizeScale),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Voice / Send button
            _controller.text.trim().isNotEmpty
                ? _iconBtn(
                    icon: Icons.send_rounded,
                    tooltip: 'Send',
                    onTap: _sendMessage,
                    filled: true,
                  )
                : _iconBtn(
                    icon: _isRecording ? Icons.stop : Icons.mic,
                    tooltip: _isRecording ? 'Stop recording' : 'Voice input',
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() => _isRecording = !_isRecording);
                      if (_isRecording) {
                        Future.delayed(const Duration(seconds: 3), () {
                          if (mounted && _isRecording) {
                            setState(() => _isRecording = false);
                          }
                        });
                      }
                    },
                    filled: _isRecording,
                    activeColor: Colors.red,
                  ),
          ],
        ),
      ),
    );
  }

  Widget _iconBtn({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    bool filled = false,
    bool active = false,
    Color activeColor = AppTheme.brandPrimary,
  }) {
    final Color bg = filled
        ? AppTheme.brandPrimary
        : active
            ? activeColor.withValues(alpha: 0.12)
            : Colors.transparent;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(shape: BoxShape.circle, color: bg),
          child: Icon(
            icon,
            size: 22,
            color: filled || active ? (filled ? Colors.white : activeColor) : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ── Typing dots ───────────────────────────────────────────────────────────────
class _DotPulse extends StatefulWidget {
  final int delay;
  const _DotPulse({required this.delay});
  @override
  State<_DotPulse> createState() => _DotPulseState();
}

class _DotPulseState extends State<_DotPulse> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: AppTheme.brandPrimary,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
