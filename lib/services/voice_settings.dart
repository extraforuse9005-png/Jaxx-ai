import 'package:shared_preferences/shared_preferences.dart';

class VoiceSettings {
  const VoiceSettings({
    this.speechRate = 0.5,
    this.pitch = 1.0,
    this.autoSend = false,
    this.speakReplies = true,
    this.language = 'en-IN',
  });

  final double speechRate;
  final double pitch;
  final bool autoSend;
  final bool speakReplies;
  final String language;

  VoiceSettings copyWith({
    double? speechRate,
    double? pitch,
    bool? autoSend,
    bool? speakReplies,
    String? language,
  }) {
    return VoiceSettings(
      speechRate: speechRate ?? this.speechRate,
      pitch: pitch ?? this.pitch,
      autoSend: autoSend ?? this.autoSend,
      speakReplies: speakReplies ?? this.speakReplies,
      language: language ?? this.language,
    );
  }

  static const String _kRate = 'voice_rate';
  static const String _kPitch = 'voice_pitch';
  static const String _kAutoSend = 'voice_auto_send';
  static const String _kSpeak = 'voice_speak_replies';
  static const String _kLang = 'voice_language';

  static Future<VoiceSettings> load() async {
    final p = await SharedPreferences.getInstance();
    const d = VoiceSettings();
    return VoiceSettings(
      speechRate: p.getDouble(_kRate) ?? d.speechRate,
      pitch: p.getDouble(_kPitch) ?? d.pitch,
      autoSend: p.getBool(_kAutoSend) ?? d.autoSend,
      speakReplies: p.getBool(_kSpeak) ?? d.speakReplies,
      language: p.getString(_kLang) ?? d.language,
    );
  }

  Future<void> save() async {
    final p = await SharedPreferences.getInstance();
    await p.setDouble(_kRate, speechRate);
    await p.setDouble(_kPitch, pitch);
    await p.setBool(_kAutoSend, autoSend);
    await p.setBool(_kSpeak, speakReplies);
    await p.setString(_kLang, language);
  }
}
