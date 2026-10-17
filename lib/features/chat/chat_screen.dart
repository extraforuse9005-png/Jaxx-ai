import 'package:flutter/material.dart';

import '../../core/theme/jaxx_theme.dart';
import '../../models/chat_message.dart';
import '../../services/api_key_store.dart';
import '../../services/app_launcher.dart';
import '../../services/command_router.dart';
import '../../services/gemini_service.dart';
import '../../services/voice_service.dart';
import '../../services/voice_settings.dart';
import '../settings/ai_brain_screen.dart';
import '../settings/voice_settings_screen.dart';

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
  final VoiceService _voice = VoiceService();

  final List<ChatMessage> _messages = [
    ChatMessage(
      text: 'Bhai, main ready hoon. Bolo ya likho. "Chrome kholo", "play Kesariya on YouTube" ya kuch bhi poochho.',
      author: MessageAuthor.jaxx,
      createdAt: DateTime.now(),
    ),
  ];

  VoiceSettings _settings = const VoiceSettings();
  bool _sending = false;
  bool _listening = false;
  bool _sttAvailable = false;
  String? _failedText;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _initVoice();
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    _gemini.dispose();
    _voice.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final s = await VoiceSettings.load();
    if (mounted) setState(() => _settings = s);
  }

  Future<void> _initVoice() async {
    final ok = await _voice.initSpeech(
      onStatus: (status) {
        if (mounted && (status == 'done' || status == 'notListening')) {
          setState(() => _listening = false);
        }
      },
      onError: (_) {
        if (mounted) setState(() => _listening = false);
      },
    );
    if (mounted) setState(() => _sttAvailable = ok);
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

  void _addJaxx(String text) {
    if (!mounted) return;
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        author: MessageAuthor.jaxx,
        createdAt: DateTime.now(),
      ));
    });
    _scrollToBottom();
  }

  Future<void> _toggleMic() async {
    if (_listening) {
      await _voice.stopListening();
      setState(() => _listening = false);
      return;
    }

    if (!_sttAvailable) {
      _addJaxx('Mic chalu nahi hua. Mic permission allow karo, aur phone me Google speech service check karo.');
      return;
    }

    await _voice.stopSpeaking();
    setState(() => _listening = true);

    await _voice.listen(
      localeId: _settings.language,
      onWords: (words, isFinal) {
        if (!mounted) return;
        setState(() {
          _input.text = words;
          _input.selection = TextSelection.collapsed(offset: words.length);
          if (isFinal) _listening = false;
        });
        if (isFinal && _settings.autoSend && words.trim().isNotEmpty) {
          _send();
        }
      },
    );
  }

  Future<void> _send({String? retryText}) async {
    final text = (retryText ?? _input.text).trim();
    if (text.isEmpty || _sending) return;

    if (retryText == null) {
      setState(() {
        _messages.add(ChatMessage(
          text: text,
          author: MessageAuthor.user,
          createdAt: DateTime.now(),
        ));
        _input.clear();
      });
      _scrollToBottom();
    }

    final command = CommandRouter.parse(text);
    switch (command.type) {
      case CommandType.stopSpeaking:
        await _voice.stopSpeaking();
        _addJaxx('Chup ho gaya bhai.');
        return;

      case CommandType.openApp:
        setState(() => _sending = true);
        try {
          final r = await AppLauncher.openApp(command.target);
          _addJaxx(r.message);
        } finally {
          if (mounted) setState(() => _sending = false);
        }
        return;

      case CommandType.youtubeSearch:
        setState(() => _sending = true);
        try {
          final r = await AppLauncher.youtubeSearch(command.target);
          _addJaxx(r.message);
        } finally {
          if (mounted) setState(() => _sending = false);
        }
        return;

      case CommandType.askAi:
        break;
    }

    await _askGemini(text);
  }

  Future<void> _askGemini(String text) async {
    String? apiKey;
    String model = ApiKeyStore.defaultModel;
    try {
      apiKey = await _store.readApiKey();
      model = await _store.readModel();
    } catch (_) {
      apiKey = null;
    }

    if (apiKey == null || apiKey.isEmpty) {
      _addJaxx('Bhai, pehle Settings > AI Brain me Gemini API key save karo. Phir main asli jawab de paunga.');
      return;
    }

    setState(() {
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
      _addJaxx(reply);
      if (_settings.speakReplies) {
        _voice.speak(reply, _settings);
      }
    } on GeminiException catch (e) {
      if (!mounted) return;
      _addJaxx(e.message);
      setState(() => _failedText = text);
    } catch (_) {
      if (!mounted) return;
      _addJaxx('Kuch unexpected error aaya. Dobara try karo.');
      setState(() => _failedText = text);
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
            tooltip: 'Stop speaking',
            icon: const Icon(Icons.volume_off),
            onPressed: () => _voice.stopSpeaking(),
          ),
          IconButton(
            tooltip: 'Voice settings',
            icon: const Icon(Icons.record_voice_over_outlined),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const VoiceSettingsScreen()),
              );
              _loadSettings();
            },
          ),
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
            if (_listening)
              const Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Text(
                  'Sun raha hoon... bolo',
                  style: TextStyle(color: JaxxColors.cyan, fontSize: 12),
                ),
              ),
            if (_failedText != null)
              TextButton.icon(
                onPressed: _sending ? null : () => _send(retryText: _failedText),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 12, 12),
              child: Row(
                children: [
                  IconButton(
                    tooltip: _listening ? 'Stop listening' : 'Speak',
                    icon: Icon(_listening ? Icons.mic_off : Icons.mic),
                    color: _listening ? JaxxColors.danger : JaxxColors.cyan,
                    onPressed: _sending ? null : _toggleMic,
                  ),
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
