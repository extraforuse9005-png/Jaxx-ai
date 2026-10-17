enum CommandType { openApp, youtubeSearch, stopSpeaking, askAi }

class ParsedCommand {
  const ParsedCommand(this.type, {this.target = ''});

  final CommandType type;
  final String target;
}

/// Decides whether a message is a phone action or a question for Gemini.
class CommandRouter {
  CommandRouter._();

  static final RegExp _youtubePlayOn = RegExp(
      r'^(?:play|chalao)\s+(.+?)\s+(?:on youtube|youtube par|youtube pe)$');
  static final RegExp _youtubeSearch = RegExp(
      r'^(?:search|dhoondo|search karo)\s+(.+?)\s+(?:on youtube|youtube par|youtube pe)$');
  static final RegExp _openOnYoutube = RegExp(
      r'^(?:open|kholo|khol do)\s+(.+?)\s+(?:on youtube|youtube par|youtube pe)$');
  static final RegExp _youtubePlay = RegExp(r'^(?:play|play karo)\s+(.+)$');
  static final RegExp _openPrefix = RegExp(r'^(?:open|kholo|khol do|khol)\s+(.+)$');
  static final RegExp _openSuffix = RegExp(r'^(.+?)\s+(?:kholo|khol do|khol|open karo)$');

  static const Set<String> _stopPhrases = {
    'stop',
    'stop speaking',
    'chup',
    'chup ho jao',
    'chup raho',
    'bolna band karo',
    'band karo',
    'bas karo',
  };

  static ParsedCommand parse(String input) {
    final text = input.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
    if (text.isEmpty) return const ParsedCommand(CommandType.askAi);

    if (_stopPhrases.contains(text)) {
      return const ParsedCommand(CommandType.stopSpeaking);
    }

    final ytMatch = _youtubePlayOn.firstMatch(text) ??
        _youtubeSearch.firstMatch(text) ??
        _openOnYoutube.firstMatch(text) ??
        _youtubePlay.firstMatch(text);
    if (ytMatch != null) {
      return ParsedCommand(CommandType.youtubeSearch,
          target: _clean(ytMatch.group(1)!));
    }

    final openMatch = _openPrefix.firstMatch(text) ?? _openSuffix.firstMatch(text);
    if (openMatch != null) {
      final target = _clean(openMatch.group(1)!);
      if (target.isNotEmpty) {
        return ParsedCommand(CommandType.openApp, target: target);
      }
    }

    return const ParsedCommand(CommandType.askAi);
  }

  static String _clean(String raw) {
    var t = raw.trim();
    for (final prefix in ['my ', 'the ', 'mera ', 'meri ', 'mere ']) {
      if (t.startsWith(prefix)) t = t.substring(prefix.length);
    }
    if (t.endsWith(' app')) t = t.substring(0, t.length - 4);
    return t.trim();
  }
}
