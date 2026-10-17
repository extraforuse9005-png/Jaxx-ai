import 'native_bridge.dart';

class ActionResult {
  const ActionResult({required this.success, required this.message});

  final bool success;
  final String message;
}

/// Phone actions. "Done" is only said when Android actually started the action.
class AppLauncher {
  AppLauncher._();

  /// If an app is not found in the installed list, these websites are opened.
  /// YouTube's website opens the YouTube app automatically when it is installed.
  static const Map<String, String> _webFallback = {
    'youtube': 'https://www.youtube.com',
    'chrome': 'https://www.google.com',
    'google': 'https://www.google.com',
  };

  static Future<ActionResult> openApp(String target) async {
    final query = target.toLowerCase().trim();

    final apps = await NativeBridge.listApps();
    if (apps.isNotEmpty) {
      AppInfo? match = _firstWhereOrNull(
          apps, (a) => a.name.toLowerCase() == query);
      match ??= _firstWhereOrNull(
          apps, (a) => a.name.toLowerCase().contains(query));

      if (match != null) {
        final ok = await NativeBridge.launchApp(match.packageName);
        return ok
            ? ActionResult(success: true, message: 'Done bhai, ${match.name} khol diya.')
            : ActionResult(success: false, message: '${match.name} khul nahi paya.');
      }
    }

    String? fallbackKey;
    for (final key in _webFallback.keys) {
      if (query.contains(key)) {
        fallbackKey = key;
        break;
      }
    }
    if (fallbackKey != null) {
      final ok = await NativeBridge.openUrl(_webFallback[fallbackKey]!);
      return ok
          ? ActionResult(
              success: true,
              message: 'Done bhai, website khol di. App list me nahi dikha.',
            )
          : const ActionResult(success: false, message: 'Browser nahi khul paya.');
    }

    return ActionResult(
      success: false,
      message: '"$target" naam ka app phone me nahi mila.',
    );
  }

  static Future<ActionResult> youtubeSearch(String query) async {
    final url =
        'https://www.youtube.com/results?search_query=${Uri.encodeQueryComponent(query)}';
    final ok = await NativeBridge.openUrl(url);
    return ok
        ? const ActionResult(
            success: true,
            message: 'YouTube par search khol diya. Gaana aapko tap karna hoga.',
          )
        : const ActionResult(success: false, message: 'YouTube ya browser nahi khul paya.');
  }

  static AppInfo? _firstWhereOrNull(List<AppInfo> list, bool Function(AppInfo) test) {
    for (final a in list) {
      if (test(a)) return a;
    }
    return null;
  }
}
