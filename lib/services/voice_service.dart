import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'voice_settings.dart';

/// Speech-to-text (mic) and text-to-speech (JAXX speaks).
class VoiceService {
  final SpeechToText _stt = SpeechToText();
  final FlutterTts _tts = FlutterTts();
  bool _ttsReady = false;

  Future<bool> initSpeech({
    void Function(String status)? onStatus,
    void Function(String error)? onError,
  }) async {
    return _stt.initialize(
      onStatus: onStatus,
      onError: (e) => onError?.call(e.errorMsg),
    );
  }

  Future<void> listen({
    required String localeId,
    required void Function(String words, bool isFinal) onWords,
  }) {
    return _stt.listen(
      onResult: (r) => onWords(r.recognizedWords, r.finalResult),
      localeId: localeId,
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      listenOptions: SpeechListenOptions(partialResults: true),
    );
  }

  Future<void> stopListening() => _stt.stop();

  Future<void> _ensureTts() async {
    if (_ttsReady) return;
    await _tts.awaitSpeakCompletion(true);
    _ttsReady = true;
  }

  Future<void> speak(String text, VoiceSettings settings) async {
    await _ensureTts();
    await _tts.setLanguage(settings.language);
    await _tts.setSpeechRate(settings.speechRate);
    await _tts.setPitch(settings.pitch);
    await _tts.speak(text);
  }

  Future<void> stopSpeaking() => _tts.stop();

  void dispose() {
    _stt.cancel();
    _tts.stop();
  }
}
