import 'package:flutter/material.dart';

import '../../core/theme/jaxx_theme.dart';
import '../../models/chat_message.dart';
import '../../services/api_key_store.dart';
import '../../services/app_launcher.dart';
import '../../services/command_router.dart';
import '../../services/gemini_service.dart';
import '../../services/voice_service.dart';
import '../../services/voice_settings.dart';
import '../../widgets/ai_orb.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const String _idleStatus = 'Orb dabao, baat shuru karte hain';

  final ApiKeyStore _store = ApiKeyStore();
  final GeminiService _gemini = GeminiService();
  final VoiceService _voice = VoiceService();
  final List<ChatMessage> _history = [];

  VoiceSettings _settings = const VoiceSettings();
  OrbState _orb = OrbState.idle;
  String _status = _idleStatus;
  bool _active = false;
  int _emptyTurns = 0;

  @override
  void initState() {
    super.initState();
    VoiceSettings.load().then((s) {
      if (mounted) setState(() => _settings = s);
    }).catchError((_) {});
  }

  @override
  void dispose() {
    _active = false;
    _gemini.dispose();
    _voice.dispose();
    super.dispose();
  }

  void _set(OrbState orb, String status) {
    if (!mounted) return;
    setState(() {
      _orb = orb;
      _status = status;
    });
  }

  Future<void> _onOrbTap() async {
    if (_active) {
      await _endSession('Theek hai bhai, band kar diya.');
      return;
    }
    await _startSession();
  }

  Future<void> _startSession() async {
    _set(OrbState.thinking, 'Connecting...');

    String? key;
    try {
      key = await _store.readApiKey();
    } catch (_) {
      key = null;
    }
    if (key == null || key.isEmpty) {
      _set(OrbState.idle, 'API key nahi hai. Settings me daalo.');
      return;
    }

    final ready = await _voice.init();
    if (!ready) {
      _set(OrbState.idle, 'Mic chalu nahi hua. Mic permission allow karo.');
      return;
    }

    _active = true;
    _emptyTurns = 0;
    _set(OrbState.speaking, 'Connected. Bolo bhai.');
    await _voice.speak('Haan bhai, bolo. Main sun raha hoon.', _settings);
    if (_active) _runLoop();
  }

  Future<void> _runLoop() async {
    while (_active) {
      _set(OrbState.listening, 'Sun raha hoon...');

      final result = await _voice.listenOnce(
        localeId: _settings.language,
        onPartial: (words) {
          if (mounted && _active && words.isNotEmpty) {
            setState(() => _status = words);
          }
        },
      );
      if (!_active) break;

      final error = result.error;
      if (error != null &&
          (error.contains('permission') || error.contains('insufficient'))) {
        await _endSession('Mic permission nahi mili bhai. Phone settings me allow karo.');
        break;
      }

      final heard = result.text.trim();
      if (heard.isEmpty) {
        _emptyTurns++;
        if (_emptyTurns >= 4) {
          await _endSession('Kaafi der se kuch suna nahi. Session band kar raha hoon.');
          break;
        }
        continue;
      }
      _emptyTurns = 0;

      final cmd = CommandRouter.parse(heard);
      if (cmd.type == CommandType.stopSpeaking) {
        await _endSession('Theek hai bhai, chup ho gaya.');
        break;
      }

      _set(OrbState.thinking, 'Soch raha hoon...');
      final reply = await _respond(heard, cmd);
      if (!_active) break;

      if (_settings.speakReplies) {
        _set(OrbState.speaking, reply);
        await _voice.speak(reply, _settings);
      } else {
        _set(OrbState.idle, reply);
      }
    }
    await _voice.stopListening();
  }

  Future<String> _respond(String heard, ParsedCommand cmd) async {
    switch (cmd.type) {
      case CommandType.openApp:
        return (await AppLauncher.openApp(cmd.target)).message;
      case CommandType.youtubeSearch:
        return (await AppLauncher.youtubeSearch(cmd.target)).message;
      case CommandType.stopSpeaking:
      case CommandType.askAi:
        return _askGemini(heard);
    }
  }

  Future<String> _askGemini(String heard) async {
    String? key;
    String model = ApiKeyStore.defaultModel;
    try {
      key = await _store.readApiKey();
      model = await _store.readModel();
    } catch (_) {
      key = null;
    }
    if (key == null || key.isEmpty) {
      return 'API key nahi hai bhai. Settings me daalo.';
    }

    _history.add(ChatMessage(
      text: heard,
      author: MessageAuthor.user,
      createdAt: DateTime.now(),
    ));
    try {
      final reply = await _gemini.reply(
        apiKey: key,
        model: model,
        history: List.of(_history),
      );
      _history.add(ChatMessage(
        text: reply,
        author: MessageAuthor.jaxx,
        createdAt: DateTime.now(),
      ));
      return reply;
    } on GeminiException catch (e) {
      _history.removeLast();
      return e.message;
    } catch (_) {
      _history.removeLast();
      return 'Kuch gadbad ho gayi bhai. Dobara bolo.';
    }
  }

  Future<void> _endSession(String message) async {
    _active = false;
    await _voice.stopListening();
    await _voice.stopSpeaking();
    _set(OrbState.idle, message);
  }

  @override
  Widget build(BuildContext context) {
    final orbSize = (MediaQuery.of(context).size.width * 0.6).clamp(160.0, 260.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'JAXX AI',
          style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: GestureDetector(
                  onTap: _onOrbTap,
                  child: AiOrb(state: _orb, size: orbSize),
                ),
              ),
            ),
            const Text(
              "Hey bhai, I'm JAXX.",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: JaxxColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                _status,
                textAlign: TextAlign.center,
                maxLines: 6,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: JaxxColors.textMuted, fontSize: 14),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
