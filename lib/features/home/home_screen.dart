import 'package:flutter/material.dart';

import '../../core/theme/jaxx_theme.dart';
import '../../widgets/ai_orb.dart';
import '../chat/chat_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Phase 1 has no AI connection yet, so this is honestly false.
  // Phase 2 replaces it with a real connection check.
  static const bool _aiConnected = false;

  @override
  Widget build(BuildContext context) {
    const statusColor =
        _aiConnected ? JaxxColors.cyan : JaxxColors.textMuted;

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
                  _aiConnected ? 'Online' : 'Offline',
                  style: TextStyle(color: statusColor, fontSize: 12),
                ),
              ],
            ),
          ),
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Scale the orb to the screen, but keep it within sensible limits.
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
                      'Text mode. Voice arrives in a later phase.',
                      style: TextStyle(color: JaxxColors.textMuted),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'AI brain: not connected yet',
                      style: TextStyle(color: JaxxColors.textMuted, fontSize: 12),
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
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const ChatScreen()),
                        ),
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
