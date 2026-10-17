/// Cleans text before JAXX speaks it, so symbols like * or # are not read aloud.
class SpeechText {
  SpeechText._();

  static String clean(String input) {
    var t = input;
    t = t.replaceAll(RegExp(r'```[\s\S]*?```'), ' Code screen par dekh lo. ');
    t = t.replaceAll('°', ' degree');
    t = t.replaceAll(RegExp(r'[*_`#>|~]'), ' ');
    t = t.replaceAll(RegExp(r'\s+'), ' ').trim();
    return t;
  }
}
