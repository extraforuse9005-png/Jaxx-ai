import 'package:flutter/material.dart';

import '../../core/theme/jaxx_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const String _appVersion = '0.1.0 (build 1)';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: const [
          _SectionHeader('AI Brain'),
          ListTile(
            leading: Icon(Icons.psychology_outlined),
            title: Text('Gemini connection'),
            subtitle: Text('Not connected. API key setup arrives in Phase 2.'),
          ),
          _SectionHeader('Voice'),
          ListTile(
            leading: Icon(Icons.record_voice_over_outlined),
            title: Text('Speech and voice output'),
            subtitle: Text('Arrives in Phase 3.'),
          ),
          _SectionHeader('Appearance'),
          ListTile(
            leading: Icon(Icons.palette_outlined),
            title: Text('Theme'),
            subtitle: Text('Dark theme only for now.'),
          ),
          _SectionHeader('Personality'),
          ListTile(
            leading: Icon(Icons.face_outlined),
            title: Text('Assistant name'),
            subtitle: Text('JAXX (customisation arrives in Phase 2).'),
          ),
          _SectionHeader('Permissions'),
          ListTile(
            leading: Icon(Icons.shield_outlined),
            title: Text('Permissions requested'),
            subtitle: Text(
              'None yet. JAXX asks only when a feature needs one.',
            ),
          ),
          _SectionHeader('Memory and Privacy'),
          ListTile(
            leading: Icon(Icons.lock_outline),
            title: Text('Stored data'),
            subtitle: Text(
              'Chat messages live only in memory and are cleared when you '
              'close the app.',
            ),
          ),
          _SectionHeader('Developer'),
          ListTile(
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
