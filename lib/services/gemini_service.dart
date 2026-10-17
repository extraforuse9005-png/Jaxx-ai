import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/chat_message.dart';

/// An error with a message that is safe to show to the user.
class GeminiException implements Exception {
  const GeminiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class GeminiService {
  GeminiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';
  static const Duration timeout = Duration(seconds: 30);
  static const int maxHistoryMessages = 20;

  static const String systemPrompt =
      'You are JAXX, a friendly, witty and supportive male best friend AI. '
      'Speak casually and confidently. If the user writes in Hinglish, reply in '
      'friendly Hinglish. If the user writes in English, reply in English. '
      'Be honest when you are unsure. You can open installed apps and YouTube '
      'searches when asked, but you cannot play music, tap the screen or send '
      'messages yet, so never claim you did. '
      'Keep answers concise unless the user asks for detail. Avoid excessive emojis.';

  /// Sends the conversation to Gemini and returns the reply text.
  Future<String> reply({
    required String apiKey,
    required String model,
    required List<ChatMessage> history,
  }) async {
    final recent = history.length > maxHistoryMessages
        ? history.sublist(history.length - maxHistoryMessages)
        : history;

    // Gemini expects the conversation to start with a user message.
    final start = recent.indexWhere((m) => m.author == MessageAuthor.user);
    final usable = start < 0 ? <ChatMessage>[] : recent.sublist(start);

    final body = {
      'systemInstruction': {
        'parts': [
          {'text': systemPrompt}
        ]
      },
      'contents': usable
          .map((m) => {
                'role': m.author == MessageAuthor.user ? 'user' : 'model',
                'parts': [
                  {'text': m.text}
                ]
              })
          .toList(),
      'generationConfig': {
        'maxOutputTokens': 1024,
        'temperature': 0.8,
      },
    };

    final uri =
        Uri.parse('$_baseUrl/${Uri.encodeComponent(model)}:generateContent');

    http.Response response;
    try {
      response = await _client
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'x-goog-api-key': apiKey,
            },
            body: jsonEncode(body),
          )
          .timeout(timeout);
    } on TimeoutException {
      throw const GeminiException('Jawab me bahut time lag gaya. Dobara try karo.');
    } on SocketException {
      throw const GeminiException(
          'Internet connection nahi hai. Network check karke dobara try karo.');
    } on http.ClientException {
      throw const GeminiException('Network error aaya. Internet check karo.');
    }

    if (response.statusCode != 200) {
      throw GeminiException(friendlyMessageForStatus(response.statusCode, model));
    }

    final Map<String, dynamic> json;
    try {
      json = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    } catch (_) {
      throw const GeminiException('Gemini ka jawab samajh nahi aaya.');
    }
    return extractText(json);
  }

  /// Pulls the reply text out of a Gemini response, or throws a friendly error.
  static String extractText(Map<String, dynamic> json) {
    final feedback = json['promptFeedback'];
    if (feedback is Map && feedback['blockReason'] != null) {
      throw const GeminiException(
          'Is message ka jawab safety rules ki wajah se nahi mil sakta. Alag tarah se poochho.');
    }

    const empty = GeminiException('Gemini ne khaali jawab diya. Dobara try karo.');

    final candidates = json['candidates'];
    if (candidates is! List || candidates.isEmpty) throw empty;

    final first = candidates.first;
    final content = first is Map ? first['content'] : null;
    final parts = content is Map ? content['parts'] : null;
    if (parts is! List) throw empty;

    final text = parts
        .whereType<Map>()
        .map((p) => (p['text'] as String?) ?? '')
        .join()
        .trim();
    if (text.isEmpty) throw empty;
    return text;
  }

  /// Maps an HTTP status code to a message the user can act on.
  static String friendlyMessageForStatus(int code, String model) {
    switch (code) {
      case 400:
        return 'Request galat hai. API key ya settings check karo.';
      case 401:
      case 403:
        return 'API key galat hai ya is key ko access nahi hai. Settings me key check karo.';
      case 404:
        return 'Model "$model" supported nahi hai. Settings me sahi model naam daalo.';
      case 429:
        return 'Rate limit ya quota khatam ho gaya. Thodi der baad try karo.';
      default:
        if (code >= 500) {
          return 'Gemini server me problem hai. Thodi der baad try karo.';
        }
        return 'Gemini se error aaya (code $code). Dobara try karo.';
    }
  }

  void dispose() => _client.close();
}
