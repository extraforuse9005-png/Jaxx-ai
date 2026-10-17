import 'package:flutter_test/flutter_test.dart';
import 'package:jaxx_ai/services/gemini_service.dart';

void main() {
  test('extracts and joins reply text from a normal response', () {
    final json = {
      'candidates': [
        {
          'content': {
            'parts': [
              {'text': 'Hello '},
              {'text': 'bhai'},
            ]
          }
        }
      ]
    };
    expect(GeminiService.extractText(json), 'Hello bhai');
  });

  test('empty candidates give a friendly GeminiException', () {
    expect(
      () => GeminiService.extractText({'candidates': []}),
      throwsA(isA<GeminiException>()),
    );
  });

  test('blocked prompt gives a friendly GeminiException', () {
    expect(
      () => GeminiService.extractText({
        'promptFeedback': {'blockReason': 'SAFETY'}
      }),
      throwsA(isA<GeminiException>()),
    );
  });

  test('status codes map to actionable messages', () {
    expect(GeminiService.friendlyMessageForStatus(429, 'm'), contains('Rate limit'));
    expect(GeminiService.friendlyMessageForStatus(404, 'gemini-x'), contains('gemini-x'));
    expect(GeminiService.friendlyMessageForStatus(403, 'm'), contains('API key'));
    expect(GeminiService.friendlyMessageForStatus(503, 'm'), contains('server'));
  });
}
