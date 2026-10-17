import 'package:flutter/material.dart';

import '../../core/theme/jaxx_theme.dart';
import 'ai_brain_screen.dart';
import 'voice_settings_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const String _appVersion = '0.3.1 (build 4)';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const _SectionHeader('AI Brain'),
          ListTile(
            leading: const Icon(Icons.psychology_outlined),
            title: const Text('Gemini connection'),
            subtitle: const Text('API key, model aur connection test'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AiBrainScreen()),
            ),
          ),
          const _SectionHeader('Voice'),
          ListTile(
            leading: const Icon(Icons.record_voice_over_outlined),
            title: const Text('Voice, language aur male voice'),
            subtitle: const Text('Voice chuno, speed, pitch'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const VoiceSettingsScreen()),
            ),
          ),
          const _SectionHeader('Permissions'),
          const ListTile(
            leading: Icon(Icons.shield_outlined),
            title: Text('Permissions used'),
            subtitle: Text(
              'Internet (Gemini), Microphone (voice). Installed apps ki list app kholne ke liye padhi jaati hai.',
            ),
          ),
          const _SectionHeader('Privacy'),
          const ListTile(
            leading: Icon(Icons.lock_outline),
            title: Text('Stored data'),
            subtitle: Text(
              'API key aur voice settings is phone par save hain. '
              'Baat-cheet sirf app khuli rehne tak memory me rehti hai.',
            ),
          ),
          const _SectionHeader('Developer'),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('App version'),
            subtitle: Text(_appVersion),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: JaxxColors.cyan,
          fontSize: 12,
          letterSpacing: 1.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
