import 'package:flutter/material.dart';

import '../../core/theme/jaxx_theme.dart';
import '../../models/chat_message.dart';
import '../../services/api_key_store.dart';
import '../../services/gemini_service.dart';
import '../settings/ai_brain_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final GeminiService _gemini = GeminiService();
  final ApiKeyStore _store = ApiKeyStore();

  final List<ChatMessage> _messages = [
    ChatMessage(
      text: "Bhai, main ready hoon. Settings me Gemini API key save karo, phir jo poochna hai poochho.",
      author: MessageAuthor.jaxx,
      createdAt: DateTime.now(),
    ),
  ];

  bool _sending = false;
  String? _failedText;

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    _gemini.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send({String? retryText}) async {
    final text = (retryText ?? _input.text).trim();
    if (text.isEmpty || _sending) return;

    String? apiKey;
    String model = ApiKeyStore.defaultModel;
    try {
      apiKey = await _store.readApiKey();
      model = await _store.readModel();
    } catch (_) {
      apiKey = null;
    }

    if (apiKey == null || apiKey.isEmpty) {
      setState(() {
        _messages.add(ChatMessage(
          text: 'Bhai, pehle Settings > AI Brain me Gemini API key save karo. '
              'Phir main asli jawab de paunga.',
          author: MessageAuthor.jaxx,
          createdAt: DateTime.now(),
        ));
      });
      _scrollToBottom();
      return;
    }

    setState(() {
      if (retryText == null) {
        _messages.add(ChatMessage(
          text: text,
          author: MessageAuthor.user,
          createdAt: DateTime.now(),
        ));
        _input.clear();
      }
      _sending = true;
      _failedText = null;
    });
    _scrollToBottom();

    try {
      final reply = await _gemini.reply(
        apiKey: apiKey,
        model: model,
        history: List.of(_messages),
      );
      if (!mounted) return;
      setState(() {
        _messages.add(ChatMessage(
          text: reply,
          author: MessageAuthor.jaxx,
          createdAt: DateTime.now(),
        ));
      });
    } on GeminiException catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add(ChatMessage(
          text: e.message,
          author: MessageAuthor.jaxx,
          createdAt: DateTime.now(),
        ));
        _failedText = text;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _messages.add(ChatMessage(
          text: 'Kuch unexpected error aaya. Dobara try karo.',
          author: MessageAuthor.jaxx,
          createdAt: DateTime.now(),
        ));
        _failedText = text;
      });
    } finally {
      if (mounted) setState(() => _sending = false);
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemCount = _messages.length + (_sending ? 1 : 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('JAXX Chat'),
        actions: [
          IconButton(
            tooltip: 'AI Brain settings',
            icon: const Icon(Icons.tune),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AiBrainScreen()),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.all(16),
                itemCount: itemCount,
                itemBuilder: (context, index) {
                  if (index >= _messages.length) return const _TypingBubble();
                  return _MessageBubble(message: _messages[index]);
                },
              ),
            ),
            if (_failedText != null)
              TextButton.icon(
                onPressed: _sending ? null : () => _send(retryText: _failedText),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _input,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: const InputDecoration(
                        hintText: 'Message JAXX...',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    tooltip: 'Send',
                    onPressed: _sending ? null : () => _send(),
                    icon: const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: JaxxColors.surfaceHigh,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: JaxxColors.cyan.withValues(alpha: 0.25)),
        ),
        child: const Text(
          'JAXX soch raha hai...',
          style: TextStyle(color: JaxxColors.textMuted, fontStyle: FontStyle.italic),
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.author == MessageAuthor.user;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        decoration: BoxDecoration(
          color: isUser
              ? JaxxColors.electricBlue.withValues(alpha: 0.35)
              : JaxxColors.surfaceHigh,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUser
                ? JaxxColors.electricBlue
                : JaxxColors.cyan.withValues(alpha: 0.25),
          ),
        ),
        child: SelectableText(
          message.text,
          style: const TextStyle(color: JaxxColors.textPrimary, height: 1.4),
        ),
      ),
    );
  }
}
