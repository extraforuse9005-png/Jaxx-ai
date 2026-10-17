import 'package:flutter/material.dart';

import '../../core/theme/jaxx_theme.dart';
import '../../services/api_key_store.dart';
import '../../widgets/ai_orb.dart';
import '../chat/chat_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiKeyStore _store = ApiKeyStore();
  bool _hasKey = false;

  @override
  void initState() {
    super.initState();
    _refreshKeyStatus();
  }

  Future<void> _refreshKeyStatus() async {
    bool has;
    try {
      has = await _store.hasApiKey();
    } catch (_) {
      has = false;
    }
    if (mounted) setState(() => _hasKey = has);
  }

  Future<void> _open(Widget screen) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
    await _refreshKeyStatus();
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _hasKey ? JaxxColors.cyan : JaxxColors.textMuted;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'JAXX AI',
          style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.w600),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Row(
              children: [
                Icon(Icons.circle, size: 10, color: statusColor),
                const SizedBox(width: 6),
                Text(
                  _hasKey ? 'Key saved' : 'No key',
                  style: TextStyle(color: statusColor, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _open(const SettingsScreen()),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final orbSize = (constraints.maxWidth * 0.6).clamp(160.0, 260.0);

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AiOrb(size: orbSize),
                    const SizedBox(height: 32),
                    const Text(
                      "Hey bhai, I'm JAXX.",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                        color: JaxxColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Text mode. Voice arrives in Phase 3.',
                      style: TextStyle(color: JaxxColors.textMuted),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _hasKey
                          ? 'AI brain: API key saved. Settings me test kar sakte ho.'
                          : 'AI brain: API key not set. Settings > AI Brain me daalo.',
                      style: const TextStyle(color: JaxxColors.textMuted, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: JaxxColors.electricBlue,
                          foregroundColor: JaxxColors.textPrimary,
                        ),
                        onPressed: () => _open(const ChatScreen()),
                        icon: const Icon(Icons.chat_bubble_outline),
                        label: const Text('Talk to JAXX'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
