import 'package:flutter_test/flutter_test.dart';
import 'package:jaxx_ai/services/command_router.dart';

void main() {
  test('English open command', () {
    final c = CommandRouter.parse('open YouTube');
    expect(c.type, CommandType.openApp);
    expect(c.target, 'youtube');
  });

  test('Hinglish open command', () {
    final c = CommandRouter.parse('Chrome kholo');
    expect(c.type, CommandType.openApp);
    expect(c.target, 'chrome');
  });

  test('play on YouTube', () {
    final c = CommandRouter.parse('play Kesariya on YouTube');
    expect(c.type, CommandType.youtubeSearch);
    expect(c.target, 'kesariya');
  });

  test('plain play goes to YouTube search', () {
    final c = CommandRouter.parse('play Arijit Singh songs');
    expect(c.type, CommandType.youtubeSearch);
    expect(c.target, 'arijit singh songs');
  });

  test('stop phrases', () {
    expect(CommandRouter.parse('stop speaking').type, CommandType.stopSpeaking);
    expect(CommandRouter.parse('chup').type, CommandType.stopSpeaking);
  });

  test('normal question goes to AI', () {
    expect(CommandRouter.parse('what is flutter').type, CommandType.askAi);
    expect(CommandRouter.parse('what does open mean').type, CommandType.askAi);
  });
}
