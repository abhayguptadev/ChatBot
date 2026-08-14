import 'package:flutter/material.dart';
import 'ChatMsg.dart';
import 'Service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> _messages = [];

  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final GroqApiService _apiService = GroqApiService();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _messages.add(
      ChatMessage(
        role: 'system',
        content: 'You are a helpful, concise AI companion assistant.',
      ),
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  Future<void> _handleSubmittedMessage() async {
    final text = _inputController.text.trim();

    if (text.isEmpty || _isLoading) return;

    _inputController.clear();

    setState(() {
      _messages.add(
        ChatMessage(
          role: 'user',
          content: text,
        ),
      );

      _isLoading = true;
    });

    _scrollToBottom();

    try {
      final reply = await _apiService.sendMessageToGroq(_messages);

      if (!mounted) return;

      setState(() {
        _messages.add(
          ChatMessage(
            role: 'assistant',
            content: reply,
          ),
        );

        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _messages.add(
          ChatMessage(
            role: 'assistant',
            content:
            'Sorry, something went wrong. Please check your connection and try again.',
          ),
        );

        _isLoading = false;
      });
    }

    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final displayMessages =
    _messages.where((m) => m.role != 'system').toList();

    return Scaffold(
      backgroundColor: const Color(0xFF09090B),
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: displayMessages.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  16,
                  20,
                  16,
                  20,
                ),
                itemCount: displayMessages.length,
                itemBuilder: (context, index) {
                  final message = displayMessages[index];

                  return _buildMessageBubble(
                    message,
                    index,
                  );
                },
              ),
            ),

            if (_isLoading) _buildTypingIndicator(),

            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // APP BAR
  // ------------------------------------------------------------

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: const Color(0xFF0D0D10),
      surfaceTintColor: Colors.transparent,

      titleSpacing: 16,

      title: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF7C3AED),
                  Color(0xFF4F46E5),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),

            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 23,
            ),
          ),
// problem in API Service

          const SizedBox(width: 12),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your AI Friend',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 3),

              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF22C55E),
                    ),
                  ),

                  const SizedBox(width: 6),

                  const Text(
                    'Online',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),

      actions: [
        IconButton(
          onPressed: () {
            // Add settings/menu functionality here.
          },
          icon: const Icon(
            Icons.more_vert_rounded,
            color: Colors.white70,
          ),
        ),

        const SizedBox(width: 6),
      ],
    );
  }

  // ------------------------------------------------------------
  // EMPTY STATE
  // ------------------------------------------------------------

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 35),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF8B5CF6),
                    Color(0xFF4F46E5),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withOpacity(0.3),
                    blurRadius: 35,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 38,
              ),
            ),

            const SizedBox(height: 28),

            const Text(
              'How can I help you?',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Ask me anything. I can help you write, learn, '
                  'brainstorm, code, and more.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 14,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 28),

            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                _suggestionChip('💡 Explain something'),
                _suggestionChip('💻 Help me code'),
                _suggestionChip('✍️ Write something'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _suggestionChip(String text) {
    return GestureDetector(
      onTap: () {
        _inputController.text = text.substring(2).trim();
        _inputController.selection = TextSelection.fromPosition(
          TextPosition(
            offset: _inputController.text.length,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 13,
          vertical: 9,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF15151A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.07),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Color(0xFFD1D5DB),
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // MESSAGE BUBBLE
  // ------------------------------------------------------------

  Widget _buildMessageBubble(
      ChatMessage message,
      int index,
      ) {
    final bool isUser = message.role == 'user';

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        mainAxisAlignment:
        isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            _buildAvatar(false),
            const SizedBox(width: 9),
          ],

          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.78,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                gradient: isUser
                    ? const LinearGradient(
                  colors: [
                    Color(0xFF7C3AED),
                    Color(0xFF5B21B6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
                    : null,
                color: isUser
                    ? null
                    : const Color(0xFF17171C),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(
                    isUser ? 18 : 4,
                  ),
                  bottomRight: Radius.circular(
                    isUser ? 4 : 18,
                  ),
                ),
                border: isUser
                    ? null
                    : Border.all(
                  color: Colors.white.withOpacity(0.06),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                message.content,
                style: TextStyle(
                  color: isUser
                      ? Colors.white
                      : const Color(0xFFE5E7EB),
                  fontSize: 15,
                  height: 1.45,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),

          if (isUser) ...[
            const SizedBox(width: 9),
            _buildAvatar(true),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar(bool isUser) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: isUser
              ? const [
            Color(0xFF6366F1),
            Color(0xFF8B5CF6),
          ]
              : const [
            Color(0xFF7C3AED),
            Color(0xFF4F46E5),
          ],
        ),
      ),
      child: Icon(
        isUser
            ? Icons.person_rounded
            : Icons.auto_awesome_rounded,
        size: 18,
        color: Colors.white,
      ),
    );
  }

  // ------------------------------------------------------------
  // TYPING INDICATOR
  // ------------------------------------------------------------

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: 10,
      ),
      child: Row(
        children: [
          _buildAvatar(false),

          const SizedBox(width: 10),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF17171C),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withOpacity(0.06),
              ),
            ),
            child: const SizedBox(
              width: 28,
              child: Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
                children: [
                  _Dot(),
                  _Dot(),
                  _Dot(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // INPUT AREA
  // ------------------------------------------------------------

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        12,
        8,
        12,
        12,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D10),
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.05),
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF17171C),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: Colors.white.withOpacity(0.07),
                ),
              ),
              child: TextField(
                controller: _inputController,
                enabled: !_isLoading,
                minLines: 1,
                maxLines: 5,
                textCapitalization:
                TextCapitalization.sentences,
                keyboardType: TextInputType.multiline,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
                decoration: const InputDecoration(
                  hintText: 'Message AI...',
                  hintStyle: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                ),
                onSubmitted: (_) {
                  _handleSubmittedMessage();
                },
              ),
            ),
          ),

          const SizedBox(width: 9),

          GestureDetector(
            onTap: _isLoading
                ? null
                : _handleSubmittedMessage,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: _isLoading
                    ? const LinearGradient(
                  colors: [
                    Color(0xFF333338),
                    Color(0xFF333338),
                  ],
                )
                    : const LinearGradient(
                  colors: [
                    Color(0xFF8B5CF6),
                    Color(0xFF6366F1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: _isLoading
                    ? []
                    : [
                  BoxShadow(
                    color: Colors.deepPurple
                        .withOpacity(0.35),
                    blurRadius: 15,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Icon(
                _isLoading
                    ? Icons.hourglass_top_rounded
                    : Icons.arrow_upward_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------
// TYPING DOT
// ------------------------------------------------------------

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF9CA3AF),
      ),
    );
  }
}