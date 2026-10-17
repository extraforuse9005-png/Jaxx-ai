import 'package:flutter/material.dart';

import '../../core/theme/jaxx_theme.dart';
import 'ai_brain_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const String _appVersion = '0.2.0 (build 2)';

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
          const ListTile(
            leading: Icon(Icons.record_voice_over_outlined),
            title: Text('Speech and voice output'),
            subtitle: Text('Arrives in Phase 3.'),
          ),
          const _SectionHeader('Appearance'),
          const ListTile(
            leading: Icon(Icons.palette_outlined),
            title: Text('Theme'),
            subtitle: Text('Dark theme only for now.'),
          ),
          const _SectionHeader('Personality'),
          const ListTile(
            leading: Icon(Icons.face_outlined),
            title: Text('Assistant name'),
            subtitle: Text('JAXX. Customisation comes later.'),
          ),
          const _SectionHeader('Permissions'),
          const ListTile(
            leading: Icon(Icons.shield_outlined),
            title: Text('Permissions requested'),
            subtitle: Text(
              'Internet only (for Gemini). JAXX asks for more only when a feature needs it.',
            ),
          ),
          const _SectionHeader('Memory and Privacy'),
          const ListTile(
            leading: Icon(Icons.lock_outline),
            title: Text('Stored data'),
            subtitle: Text(
              'API key and model are kept in secure storage on this phone. '
              'Chat messages live only in memory and are cleared when you close the app.',
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
