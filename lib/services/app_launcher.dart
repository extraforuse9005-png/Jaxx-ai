import 'native_bridge.dart';

class ActionResult {
  const ActionResult({required this.success, required this.message});

  final bool success;
  final String message;
}

/// Phone actions. "Done" is only said when Android actually started the action.
class AppLauncher {
  AppLauncher._();

  static Future<ActionResult> openApp(String target) async {
    final apps = await NativeBridge.listApps();
    if (apps.isEmpty) {
      return const ActionResult(
        success: false,
        message: 'Installed apps ki list nahi mil paayi. Native setup check karo.',
      );
    }

    final query = target.toLowerCase().trim();
    AppInfo? match = _firstWhereOrNull(
        apps, (a) => a.name.toLowerCase() == query);
    match ??= _firstWhereOrNull(
        apps, (a) => a.name.toLowerCase().contains(query));

    if (match == null) {
      return ActionResult(
        success: false,
        message: 'Bhai, "$target" naam ka app phone me installed nahi dikha.',
      );
    }

    final ok = await NativeBridge.launchApp(match.packageName);
    return ok
        ? ActionResult(success: true, message: 'Done bhai, ${match.name} khol diya.')
        : ActionResult(success: false, message: '${match.name} khul nahi paya. Dobara try karo.');
  }

  static Future<ActionResult> youtubeSearch(String query) async {
    final url =
        'https://www.youtube.com/results?search_query=${Uri.encodeQueryComponent(query)}';
    final ok = await NativeBridge.openUrl(url);
    return ok
        ? ActionResult(
            success: true,
            message: 'YouTube par "$query" ka search khol diya. Gaana tap karke aap play karoge, main abhi play nahi kar sakta.',
          )
        : const ActionResult(
            success: false,
            message: 'YouTube ya browser nahi khul paya.',
          );
  }

  static AppInfo? _firstWhereOrNull(List<AppInfo> list, bool Function(AppInfo) test) {
    for (final a in list) {
      if (test(a)) return a;
    }
    return null;
  }
}
