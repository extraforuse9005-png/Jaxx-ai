import 'package:flutter/material.dart';

import '../../core/theme/jaxx_theme.dart';
import '../../services/voice_service.dart';
import '../../services/voice_settings.dart';

class VoiceSettingsScreen extends StatefulWidget {
  const VoiceSettingsScreen({super.key});

  @override
  State<VoiceSettingsScreen> createState() => _VoiceSettingsScreenState();
}

class _VoiceSettingsScreenState extends State<VoiceSettingsScreen> {
  final VoiceService _voice = VoiceService();
  VoiceSettings _s = const VoiceSettings();

  static const Map<String, String> _languages = {
    'en-IN': 'English (India)',
    'hi-IN': 'Hindi',
    'en-US': 'English (US)',
  };

  @override
  void initState() {
    super.initState();
    VoiceSettings.load().then((s) {
      if (mounted) setState(() => _s = s);
    });
  }

  @override
  void dispose() {
    _voice.dispose();
    super.dispose();
  }

  void _update(VoiceSettings s) {
    setState(() => _s = s);
    s.save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Voice')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<String>(
            key: ValueKey(_s.language),
            initialValue: _s.language,
            decoration: const InputDecoration(labelText: 'Language (listen + speak)'),
            items: _languages.entries
                .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                .toList(),
            onChanged: (v) {
              if (v != null) _update(_s.copyWith(language: v));
            },
          ),
          const SizedBox(height: 20),
          Text('Speech rate: ${_s.speechRate.toStringAsFixed(2)}'),
          Slider(
            value: _s.speechRate,
            min: 0.2,
            max: 1.0,
            onChanged: (v) => setState(() => _s = _s.copyWith(speechRate: v)),
            onChangeEnd: (v) => _update(_s.copyWith(speechRate: v)),
          ),
          const SizedBox(height: 12),
          Text('Pitch: ${_s.pitch.toStringAsFixed(2)}'),
          Slider(
            value: _s.pitch,
            min: 0.5,
            max: 2.0,
            onChanged: (v) => setState(() => _s = _s.copyWith(pitch: v)),
            onChangeEnd: (v) => _update(_s.copyWith(pitch: v)),
          ),
          SwitchListTile(
            title: const Text('Speak JAXX replies'),
            value: _s.speakReplies,
            onChanged: (v) => _update(_s.copyWith(speakReplies: v)),
          ),
          SwitchListTile(
            title: const Text('Auto-send after speaking'),
            subtitle: const Text('Off: text box me aayega, aap check karke bhejoge.'),
            value: _s.autoSend,
            onChanged: (v) => _update(_s.copyWith(autoSend: v)),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: JaxxColors.electricBlue),
            onPressed: () => _voice.speak('Bhai, voice check. Sun pa raha hai?', _s),
            icon: const Icon(Icons.volume_up),
            label: const Text('Test voice'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => _voice.stopSpeaking(),
            icon: const Icon(Icons.stop),
            label: const Text('Stop speaking'),
          ),
        ],
      ),
    );
  }
}
