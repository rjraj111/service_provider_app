import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';

/// Message status enum for delivery indicators
enum MessageStatus { sending, sent, delivered, read }

/// Represents an individual chat message
class ChatMessage {
  final String id;
  final String text;
  final bool isMe;
  final String time;
  final MessageStatus status;
  final String? attachmentType; // 'location', 'image', null

  const ChatMessage({
    required this.id,
    required this.text,
    required this.isMe,
    required this.time,
    this.status = MessageStatus.read,
    this.attachmentType,
  });
}

/// A premium WhatsApp/Messenger style Live Chat interface.
/// Features animated typing indicators, delivery receipts, rich message bubbles,
/// simulated real-time technician replies, and quick action suggestion pills.
class ChatScreen extends StatefulWidget {
  final String providerName;
  final String serviceName;
  final String? avatarUrl;
  final Color avatarColor;

  const ChatScreen({
    super.key,
    this.providerName = 'Rahim Uddin',
    this.serviceName = 'Plumber · 8 yrs exp',
    this.avatarUrl = 'https://images.unsplash.com/photo-1540569014015-19a7be504e3a?auto=format&fit=crop&q=80&w=400',
    this.avatarColor = const Color(0xFF3B82F6),
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  bool _isTyping = false;
  bool _isProviderTyping = false;
  Timer? _replyTimer;

  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  // Realistic conversation dummy history
  final List<ChatMessage> _messages = [
    const ChatMessage(
      id: '1',
      text: 'Hello! I have accepted your plumbing service booking.',
      isMe: false,
      time: '10:45 AM',
      status: MessageStatus.read,
    ),
    const ChatMessage(
      id: '2',
      text: 'Thanks! Are you nearby?',
      isMe: true,
      time: '10:46 AM',
      status: MessageStatus.read,
    ),
    const ChatMessage(
      id: '3',
      text: 'Yes, just crossed Gulshan 2. Be there in 5 mins.',
      isMe: false,
      time: '10:47 AM',
      status: MessageStatus.read,
    ),
    const ChatMessage(
      id: '4',
      text: 'Great, the security guard knows you are coming. Apartment 4B on the 4th floor.',
      isMe: true,
      time: '10:48 AM',
      status: MessageStatus.read,
    ),
    const ChatMessage(
      id: '5',
      text: 'Understood. Bringing the spare brass valves, Teflon tape, and pipe sealant 👍',
      isMe: false,
      time: '10:49 AM',
      status: MessageStatus.read,
    ),
  ];

  final List<String> _quickReplies = [
    '📍 Share Live Location',
    '🚪 Waiting at the gate',
    '📞 Call me upon arrival',
    '🏢 4th Floor, Apt 4B',
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _textController.addListener(() {
      final hasText = _textController.text.trim().isNotEmpty;
      if (hasText != _isTyping) {
        setState(() => _isTyping = hasText);
      }
    });
  }

  @override
  void dispose() {
    _replyTimer?.cancel();
    _pulseController.dispose();
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutQuad,
        );
      }
    });
  }

  void _handleSendMessage([String? customText]) {
    final text = (customText ?? _textController.text).trim();
    if (text.isEmpty) return;

    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'PM' : 'AM';
    final timeStr = '$hour:$minute $period';

    setState(() {
      _messages.add(
        ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: text,
          isMe: true,
          time: timeStr,
          status: MessageStatus.sent,
        ),
      );
    });

    if (customText == null) {
      _textController.clear();
    }
    _scrollToBottom();
    HapticFeedback.lightImpact();

    // Trigger simulated provider typing and reply
    _simulateProviderReply(text);
  }

  void _simulateProviderReply(String userMessage) {
    _replyTimer?.cancel();

    // After 1.2s, simulate provider is typing
    _replyTimer = Timer(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() => _isProviderTyping = true);
      _scrollToBottom();

      // After another 1.8s, post reply
      _replyTimer = Timer(const Duration(milliseconds: 1800), () {
        if (!mounted) return;

        final replyText = _generateSmartReply(userMessage);
        final now = DateTime.now();
        final hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
        final minute = now.minute.toString().padLeft(2, '0');
        final period = now.hour >= 12 ? 'PM' : 'AM';
        final timeStr = '$hour:$minute $period';

        setState(() {
          _isProviderTyping = false;
          _messages.add(
            ChatMessage(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              text: replyText,
              isMe: false,
              time: timeStr,
              status: MessageStatus.read,
            ),
          );
        });
        _scrollToBottom();
        HapticFeedback.mediumImpact();
      });
    });
  }

  String _generateSmartReply(String query) {
    final q = query.toLowerCase();
    if (q.contains('where') || q.contains('nearby') || q.contains('location') || q.contains('gate')) {
      return 'I just reached the main avenue gate! Signing in with security now.';
    } else if (q.contains('call') || q.contains('phone')) {
      return 'Sure, will dial your number as soon as I park my bike.';
    } else if (q.contains('apt') || q.contains('floor') || q.contains('4b')) {
      return 'Noted, taking the elevator to Apartment 4B directly.';
    } else if (q.contains('cost') || q.contains('price') || q.contains('pay')) {
      return 'Don\'t worry, payment will be settled strictly through the app via your chosen method.';
    }
    return 'Got it! I am right outside your building now 👍';
  }

  void _showAttachmentOptions() {
    final colors = AppColorsResolved.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: colors.border),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.textHint.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildAttachmentItem(
                  icon: Icons.camera_alt_rounded,
                  label: 'Camera',
                  color: const Color(0xFFEF4444),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _handleSendMessage('📷 [Sent photo of pipe joint]');
                  },
                ),
                _buildAttachmentItem(
                  icon: Icons.photo_library_rounded,
                  label: 'Gallery',
                  color: const Color(0xFF8B5CF6),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _handleSendMessage('🖼️ [Uploaded leak photo]');
                  },
                ),
                _buildAttachmentItem(
                  icon: Icons.location_on_rounded,
                  label: 'Location',
                  color: const Color(0xFF10B981),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _handleSendMessage('📍 Shared current GPS pin (Gulshan 2)');
                  },
                ),
                _buildAttachmentItem(
                  icon: Icons.description_rounded,
                  label: 'Document',
                  color: const Color(0xFF3B82F6),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _handleSendMessage('📄 [Attached appliance warranty PDF]');
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final colors = AppColorsResolved.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.25), width: 1.5),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColorsResolved.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1016) : const Color(0xFFF7F8FA),
      appBar: _buildCustomAppBar(colors, isDark),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          children: [
            // ─── Messages List View ───────────────────────────────────────────
            Expanded(
              child: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: ListView.builder(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  itemCount: _messages.length + (_isProviderTyping ? 1 : 0) + 1,
                  itemBuilder: (context, index) {
                    // Date banner at the top
                    if (index == 0) {
                      return _buildDateHeader();
                    }

                    final messageIndex = index - 1;

                    // Simulated live typing bubble at the bottom
                    if (_isProviderTyping && messageIndex == _messages.length) {
                      return _buildTypingBubble(colors);
                    }

                    final message = _messages[messageIndex];
                    return _buildMessageBubble(message, colors);
                  },
                ),
              ),
            ),

            // ─── Quick Suggestion Chips ──────────────────────────────────────
            _buildQuickRepliesBar(colors),

            // ─── Bottom Message Input Bar ────────────────────────────────────
            _buildBottomInputBar(colors, bottomPadding),
          ],
        ),
      ),
    );
  }

  // ─── Custom Premium AppBar ──────────────────────────────────────────────────

  PreferredSizeWidget _buildCustomAppBar(AppColorsResolved colors, bool isDark) {
    return AppBar(
      backgroundColor: colors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0.5,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      leadingWidth: 42,
      leading: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: colors.textPrimary),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      titleSpacing: 4,
      title: Row(
        children: [
          // Provider Avatar with Live Online Badge
          Stack(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 1.5),
                ),
                child: ClipOval(
                  child: widget.avatarUrl != null
                      ? Image.network(
                          widget.avatarUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: widget.avatarColor,
                            child: const Icon(Icons.person_rounded, color: Colors.white, size: 24),
                          ),
                        )
                      : Container(
                          color: widget.avatarColor,
                          child: const Icon(Icons.person_rounded, color: Colors.white, size: 24),
                        ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.surface, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),

          // Provider Name and Dynamic Status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        widget.providerName,
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          color: colors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.verified_rounded, size: 15, color: Color(0xFF1D9BF0)),
                  ],
                ),
                const SizedBox(height: 1),
                Row(
                  children: [
                    if (!_isProviderTyping) ...[
                      FadeTransition(
                        opacity: _pulseAnimation,
                        child: Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Online · Typically replies in 1 min',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: colors.textSecondary,
                        ),
                      ),
                    ] else ...[
                      const Text(
                        'Typing...',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.phone_rounded, color: AppColors.primary, size: 22),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Calling ${widget.providerName} (+880 1712-345678)...'),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
              ),
            );
          },
        ),
        IconButton(
          icon: Icon(Icons.more_vert_rounded, color: colors.textSecondary, size: 22),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Technician verified & insured by ServiceHub Safety Shield.'),
                behavior: SnackBarBehavior.floating,
                duration: Duration(seconds: 2),
              ),
            );
          },
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  // ─── Date Header ───────────────────────────────────────────────────────────

  Widget _buildDateHeader() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Text(
          'TODAY',
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: Colors.grey,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }

  // ─── Message Bubbles (WhatsApp / Messenger Style) ──────────────────────────

  Widget _buildMessageBubble(ChatMessage msg, AppColorsResolved colors) {
    final isMe = msg.isMe;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Received message technician mini-avatar
          if (!isMe) ...[
            Container(
              width: 26,
              height: 26,
              margin: const EdgeInsets.only(right: 6, bottom: 2),
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: ClipOval(
                child: widget.avatarUrl != null
                    ? Image.network(
                        widget.avatarUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: widget.avatarColor,
                          child: const Icon(Icons.person, size: 16, color: Colors.white),
                        ),
                      )
                    : Container(
                        color: widget.avatarColor,
                        child: const Icon(Icons.person, size: 16, color: Colors.white),
                      ),
              ),
            ),
          ],

          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.76,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                // Distinct backgrounds: Primary gradient for user, surfaceVariant / dark grey for provider
                gradient: isMe
                    ? const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryLight],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isMe ? null : colors.surfaceVariant,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: isMe ? const Radius.circular(18) : const Radius.circular(4),
                  bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isMe ? 0.08 : 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    msg.text,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.35,
                      color: isMe ? Colors.white : colors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        msg.time,
                        style: TextStyle(
                          fontSize: 10.5,
                          color: isMe ? Colors.white70 : colors.textHint,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.done_all_rounded,
                          size: 14,
                          color: Color(0xFF93C5FD), // WhatsApp style blue double tick
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Simulated Live Typing Bubble ──────────────────────────────────────────

  Widget _buildTypingBubble(AppColorsResolved colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 26,
            height: 26,
            margin: const EdgeInsets.only(right: 6, bottom: 2),
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: ClipOval(
              child: widget.avatarUrl != null
                  ? Image.network(
                      widget.avatarUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: widget.avatarColor,
                        child: const Icon(Icons.person, size: 16, color: Colors.white),
                      ),
                    )
                  : Container(
                      color: widget.avatarColor,
                      child: const Icon(Icons.person, size: 16, color: Colors.white),
                    ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: colors.surfaceVariant,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(18),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildBouncingDot(0),
                const SizedBox(width: 4),
                _buildBouncingDot(1),
                const SizedBox(width: 4),
                _buildBouncingDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBouncingDot(int index) {
    return FadeTransition(
      opacity: _pulseAnimation,
      child: Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.8),
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  // ─── Quick Suggestion Chips Bar ───────────────────────────────────────────

  Widget _buildQuickRepliesBar(AppColorsResolved colors) {
    return Container(
      height: 38,
      margin: const EdgeInsets.only(bottom: 6),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        itemCount: _quickReplies.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final reply = _quickReplies[index];
          return GestureDetector(
            onTap: () => _handleSendMessage(reply),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  reply,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── Bottom Input Bar ─────────────────────────────────────────────────────

  Widget _buildBottomInputBar(AppColorsResolved colors, double bottomPadding) {
    return Container(
      padding: EdgeInsets.fromLTRB(10, 8, 10, bottomPadding > 0 ? bottomPadding : 10),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Attachment Button (+)
          IconButton(
            onPressed: _showAttachmentOptions,
            icon: Icon(Icons.add_circle_outline_rounded, color: colors.textSecondary, size: 24),
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(),
          ),

          // Camera Quick Icon
          IconButton(
            onPressed: () => _handleSendMessage('📷 [Photo attached]'),
            icon: Icon(Icons.camera_alt_outlined, color: colors.textSecondary, size: 22),
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 4),

          // Rounded Text Input Field
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: colors.surfaceVariant.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: colors.border),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      focusNode: _focusNode,
                      minLines: 1,
                      maxLines: 4,
                      textCapitalization: TextCapitalization.sentences,
                      style: TextStyle(fontSize: 14, color: colors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: TextStyle(fontSize: 13.5, color: colors.textHint),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      onSubmitted: (_) => _handleSendMessage(),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _textController.text += ' 👍';
                    },
                    child: const Icon(Icons.sentiment_satisfied_alt_rounded, size: 20, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Send / Voice Note Action Button
          GestureDetector(
            onTap: () {
              if (_isTyping) {
                _handleSendMessage();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Hold to record voice message for technician.'),
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 1),
                  ),
                );
              }
            },
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: _isTyping
                    ? const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryLight],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: _isTyping ? null : colors.surfaceVariant,
                shape: BoxShape.circle,
                boxShadow: _isTyping
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Icon(
                  _isTyping ? Icons.send_rounded : Icons.mic_rounded,
                  color: _isTyping ? Colors.white : colors.textPrimary,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
