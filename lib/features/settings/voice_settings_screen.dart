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
  List<Map<String, String>> _voices = [];
  bool _loadingVoices = true;

  static const Map<String, String> _languages = {
    'en-IN': 'English (India)',
    'hi-IN': 'Hindi',
    'en-US': 'English (US)',
  };

  @override
  void initState() {
    super.initState();
    VoiceSettings.load().then((s) {
      if (!mounted) return;
      setState(() => _s = s);
      _loadVoices();
    }).catchError((_) {});
  }

  @override
  void dispose() {
    _voice.dispose();
    super.dispose();
  }

  Future<void> _loadVoices() async {
    setState(() => _loadingVoices = true);
    final list = await _voice.voicesFor(_s.language);
    if (mounted) {
      setState(() {
        _voices = list;
        _loadingVoices = false;
      });
    }
  }

  void _update(VoiceSettings s, {bool reloadVoices = false}) {
    setState(() => _s = s);
    s.save();
    if (reloadVoices) _loadVoices();
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
            decoration: const InputDecoration(labelText: 'Language'),
            items: _languages.entries
                .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                .toList(),
            onChanged: (v) {
              if (v != null) _update(_s.copyWith(language: v, voiceName: ''), reloadVoices: true);
            },
          ),
          const SizedBox(height: 20),
          const Text(
            'Voice chuno (male-sounding wali). Har voice ko "Test voice" se sun kar pasand wali chuno.',
            style: TextStyle(color: JaxxColors.textMuted),
          ),
          const SizedBox(height: 8),
          ListTile(
            title: const Text("Phone ki default voice"),
            trailing: _s.voiceName.isEmpty
                ? const Icon(Icons.check, color: JaxxColors.cyan)
                : null,
            onTap: () => _update(_s.copyWith(voiceName: '', voiceLocale: '')),
          ),
          if (_loadingVoices)
            const Padding(
              padding: EdgeInsets.all(16),
              child: LinearProgressIndicator(),
            )
          else if (_voices.isEmpty)
            const Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                'Is phone me is language ki extra voices nahi mili. '
                'Google Text-to-speech app me English (India) voice download karo, phir yahan wapas aao.',
                style: TextStyle(color: JaxxColors.textMuted),
              ),
            )
          else
            ..._voices.map((v) {
              final selected = _s.voiceName == v['name'];
              return ListTile(
                title: Text(v['name']!),
                subtitle: Text(v['locale']!),
                trailing: selected ? const Icon(Icons.check, color: JaxxColors.cyan) : null,
                onTap: () => _update(_s.copyWith(
                  voiceName: v['name'],
                  voiceLocale: v['locale'],
                )),
              );
            }),
          const SizedBox(height: 20),
          Text('Speech rate: ${_s.speechRate.toStringAsFixed(2)}'),
          Slider(
            value: _s.speechRate,
            min: 0.2,
            max: 1.0,
            onChanged: (v) => setState(() => _s = _s.copyWith(speechRate: v)),
            onChangeEnd: (v) => _update(_s.copyWith(speechRate: v)),
          ),
          Text('Pitch (kam = bhari awaaz): ${_s.pitch.toStringAsFixed(2)}'),
          Slider(
            value: _s.pitch,
            min: 0.5,
            max: 1.5,
            onChanged: (v) => setState(() => _s = _s.copyWith(pitch: v)),
            onChangeEnd: (v) => _update(_s.copyWith(pitch: v)),
          ),
          SwitchListTile(
            title: const Text('JAXX replies bolkar sunaye'),
            value: _s.speakReplies,
            onChanged: (v) => _update(_s.copyWith(speakReplies: v)),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: JaxxColors.electricBlue),
            onPressed: () => _voice.speak(
              'Bhai, ye meri awaaz hai. Pasand aayi?',
              _s,
            ),
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
