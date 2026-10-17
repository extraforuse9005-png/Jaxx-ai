import 'package:shared_preferences/shared_preferences.dart';

class VoiceSettings {
  const VoiceSettings({
    this.speechRate = 0.5,
    this.pitch = 0.9,
    this.autoSend = true,
    this.speakReplies = true,
    this.language = 'en-IN',
    this.voiceName = '',
    this.voiceLocale = '',
  });

  final double speechRate;
  final double pitch;
  final bool autoSend;
  final bool speakReplies;
  final String language;

  /// Empty means the phone's default voice.
  final String voiceName;
  final String voiceLocale;

  VoiceSettings copyWith({
    double? speechRate,
    double? pitch,
    bool? autoSend,
    bool? speakReplies,
    String? language,
    String? voiceName,
    String? voiceLocale,
  }) {
    return VoiceSettings(
      speechRate: speechRate ?? this.speechRate,
      pitch: pitch ?? this.pitch,
      autoSend: autoSend ?? this.autoSend,
      speakReplies: speakReplies ?? this.speakReplies,
      language: language ?? this.language,
      voiceName: voiceName ?? this.voiceName,
      voiceLocale: voiceLocale ?? this.voiceLocale,
    );
  }

  static const String _kRate = 'voice_rate';
  static const String _kPitch = 'voice_pitch';
  static const String _kAutoSend = 'voice_auto_send';
  static const String _kSpeak = 'voice_speak_replies';
  static const String _kLang = 'voice_language';
  static const String _kVoiceName = 'voice_name';
  static const String _kVoiceLocale = 'voice_locale';

  static Future<VoiceSettings> load() async {
    final p = await SharedPreferences.getInstance();
    const d = VoiceSettings();
    return VoiceSettings(
      speechRate: p.getDouble(_kRate) ?? d.speechRate,
      pitch: p.getDouble(_kPitch) ?? d.pitch,
      autoSend: p.getBool(_kAutoSend) ?? d.autoSend,
      speakReplies: p.getBool(_kSpeak) ?? d.speakReplies,
      language: p.getString(_kLang) ?? d.language,
      voiceName: p.getString(_kVoiceName) ?? d.voiceName,
      voiceLocale: p.getString(_kVoiceLocale) ?? d.voiceLocale,
    );
  }

  Future<void> save() async {
    final p = await SharedPreferences.getInstance();
    await p.setDouble(_kRate, speechRate);
    await p.setDouble(_kPitch, pitch);
    await p.setBool(_kAutoSend, autoSend);
    await p.setBool(_kSpeak, speakReplies);
    await p.setString(_kLang, language);
    await p.setString(_kVoiceName, voiceName);
    await p.setString(_kVoiceLocale, voiceLocale);
  }
}
