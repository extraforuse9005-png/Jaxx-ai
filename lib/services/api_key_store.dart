import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Stores the Gemini API key and model name in Android secure storage.
/// The key is never written to logs or shown back in full.
class ApiKeyStore {
  ApiKeyStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const String _keyName = 'gemini_api_key';
  static const String _modelName = 'gemini_model';

  /// Check the current model list in Google AI Studio if this stops working.
  static const String defaultModel = 'gemini-2.5-flash';

  Future<String?> readApiKey() => _storage.read(key: _keyName);

  Future<void> saveApiKey(String key) =>
      _storage.write(key: _keyName, value: key.trim());

  Future<void> deleteApiKey() => _storage.delete(key: _keyName);

  Future<bool> hasApiKey() async {
    final key = await readApiKey();
    return key != null && key.isNotEmpty;
  }

  Future<String> readModel() async =>
      (await _storage.read(key: _modelName)) ?? defaultModel;

  Future<void> saveModel(String model) =>
      _storage.write(key: _modelName, value: model.trim());
}
