import 'package:flutter/services.dart';

class AppInfo {
  const AppInfo({required this.name, required this.packageName});

  final String name;
  final String packageName;
}

/// Talks to the Kotlin code in native/MainActivity.kt over a MethodChannel.
class NativeBridge {
  NativeBridge._();

  static const MethodChannel _channel = MethodChannel('jaxx/native');

  static Future<List<AppInfo>> listApps() async {
    try {
      final raw = await _channel.invokeListMethod<Map<Object?, Object?>>('listApps');
      final list = raw ?? const <Map<Object?, Object?>>[];
      return list
          .map((m) => AppInfo(
                name: (m['name'] as String?) ?? '',
                packageName: (m['package'] as String?) ?? '',
              ))
          .where((a) => a.packageName.isNotEmpty)
          .toList();
    } on PlatformException {
      return [];
    } on MissingPluginException {
      return [];
    }
  }

  static Future<bool> launchApp(String packageName) =>
      _invokeBool('launchApp', {'package': packageName});

  static Future<bool> openUrl(String url) => _invokeBool('openUrl', {'url': url});

  static Future<bool> _invokeBool(String method, Map<String, dynamic> args) async {
    try {
      return await _channel.invokeMethod<bool>(method, args) ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }
}
