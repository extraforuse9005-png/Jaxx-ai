import 'dart:async';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'speech_text.dart';
import 'voice_settings.dart';

class ListenResult {
  const ListenResult({this.text = '', this.error});

  final String text;
  final String? error;
}

/// Mic (speech to text) and JAXX's voice (text to speech).
class VoiceService {
  final SpeechToText _stt = SpeechToText();
  final FlutterTts _tts = FlutterTts();

  bool _sttReady = false;
  bool _ttsReady = false;
  Completer<ListenResult>? _pending;
  String _lastWords = '';

  Future<bool> init() async {
    if (_sttReady) return true;
    try {
      _sttReady = await _stt.initialize(
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') _finish();
        },
        onError: (e) => _finish(error: e.errorMsg),
      );
    } catch (_) {
      _sttReady = false;
    }
    return _sttReady;
  }

  void _finish({String? error}) {
    final c = _pending;
    _pending = null;
    if (c != null && !c.isCompleted) {
      c.complete(ListenResult(text: _lastWords, error: error));
    }
  }

  /// Listens until the user pauses. Returns what was heard.
  Future<ListenResult> listenOnce({
    required String localeId,
    void Function(String words)? onPartial,
  }) async {
    _lastWords = '';
    final c = Completer<ListenResult>();
    _pending = c;
    try {
      await _stt.listen(
        onResult: (r) {
          _lastWords = r.recognizedWords;
          onPartial?.call(_lastWords);
          if (r.finalResult) _finish();
        },
        localeId: localeId,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        listenOptions: SpeechListenOptions(partialResults: true),
      );
    } catch (_) {
      _finish(error: 'listen_failed');
    }
    return c.future;
  }

  Future<void> stopListening() async {
    try {
      await _stt.stop();
    } catch (_) {}
    _finish();
  }

  Future<void> speak(String text, VoiceSettings s) async {
    final clean = SpeechText.clean(text);
    if (clean.isEmpty) return;
    if (!_ttsReady) {
      await _tts.awaitSpeakCompletion(true);
      _ttsReady = true;
    }
    await _tts.setLanguage(s.language);
    if (s.voiceName.isNotEmpty) {
      await _tts.setVoice({
        'name': s.voiceName,
        'locale': s.voiceLocale.isEmpty ? s.language : s.voiceLocale,
      });
    }
    await _tts.setSpeechRate(s.speechRate);
    await _tts.setPitch(s.pitch);
    await _tts.speak(clean);
  }

  Future<void> stopSpeaking() => _tts.stop();

  /// Voices installed on this phone for the chosen language.
  Future<List<Map<String, String>>> voicesFor(String language) async {
    try {
      final raw = await _tts.getVoices;
      if (raw is! List) return [];
      final prefix = language.split('-').first.toLowerCase();
      final result = <Map<String, String>>[];
      for (final item in raw) {
        if (item is! Map) continue;
        final name = item['name']?.toString() ?? '';
        final locale = item['locale']?.toString() ?? '';
        if (name.isEmpty) continue;
        if (locale.toLowerCase().startsWith(prefix)) {
          result.add({'name': name, 'locale': locale});
        }
      }
      result.sort((a, b) => a['name']!.compareTo(b['name']!));
      return result;
    } catch (_) {
      return [];
    }
  }

  void dispose() {
    _stt.cancel();
    _tts.stop();
    _finish();
  }
}
