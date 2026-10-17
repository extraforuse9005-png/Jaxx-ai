import 'package:flutter/material.dart';

import '../../core/theme/jaxx_theme.dart';
import '../../models/chat_message.dart';
import '../../services/api_key_store.dart';
import '../../services/gemini_service.dart';

class AiBrainScreen extends StatefulWidget {
  const AiBrainScreen({super.key});

  @override
  State<AiBrainScreen> createState() => _AiBrainScreenState();
}

class _AiBrainScreenState extends State<AiBrainScreen> {
  final ApiKeyStore _store = ApiKeyStore();
  final GeminiService _gemini = GeminiService();
  final TextEditingController _keyCtrl = TextEditingController();
  final TextEditingController _modelCtrl = TextEditingController();

  bool _hasKey = false;
  bool _showKey = false;
  bool _busy = false;
  String? _status;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _keyCtrl.dispose();
    _modelCtrl.dispose();
    _gemini.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final has = await _store.hasApiKey();
      final model = await _store.readModel();
      if (!mounted) return;
      setState(() {
        _hasKey = has;
        _modelCtrl.text = model;
      });
    } catch (_) {
      if (mounted) setState(() => _status = 'Saved settings load nahi ho paaye.');
    }
  }

  /// Runs an action with a busy state and shows a friendly status message.
  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _status = null;
    });
    try {
      await action();
    } on GeminiException catch (e) {
      _status = e.message;
    } catch (_) {
      _status = 'Kuch galat hua. Dobara try karo.';
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _saveKey() async {
    final key = _keyCtrl.text.trim();
    if (key.isEmpty) {
      setState(() => _status = 'Pehle API key paste karo.');
      return;
    }
    await _run(() async {
      await _store.saveApiKey(key);
      _keyCtrl.clear();
      _hasKey = true;
      _status = 'API key secure storage me save ho gayi.';
    });
  }

  Future<void> _saveModel() async {
    final model = _modelCtrl.text.trim();
    if (model.isEmpty) {
      setState(() => _status = 'Model naam khaali nahi ho sakta.');
      return;
    }
    await _run(() async {
      await _store.saveModel(model);
      _status = 'Model save ho gaya: $model';
    });
  }

  Future<void> _deleteKey() async {
    await _run(() async {
      await _store.deleteApiKey();
      _hasKey = false;
      _status = 'API key delete ho gayi.';
    });
  }

  Future<void> _testConnection() async {
    await _run(() async {
      final key = await _store.readApiKey();
      if (key == null || key.isEmpty) {
        throw const GeminiException('Pehle API key save karo.');
      }
      final reply = await _gemini.reply(
        apiKey: key,
        model: _modelCtrl.text.trim(),
        history: [
          ChatMessage(
            text: 'Ek short line me bolo: connection ok hai?',
            author: MessageAuthor.user,
            createdAt: DateTime.now(),
          ),
        ],
      );
      _status = 'Connected! JAXX ne bola: $reply';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Brain')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Icon(
                _hasKey ? Icons.check_circle : Icons.error_outline,
                color: _hasKey ? JaxxColors.cyan : JaxxColors.textMuted,
              ),
              const SizedBox(width: 8),
              Text(
                _hasKey ? 'API key saved' : 'API key not set',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _keyCtrl,
            obscureText: !_showKey,
            autocorrect: false,
            enableSuggestions: false,
            decoration: InputDecoration(
              hintText: _hasKey
                  ? 'Naya key yahan paste karo (purana replace hoga)'
                  : 'Gemini API key yahan paste karo',
              suffixIcon: IconButton(
                tooltip: _showKey ? 'Hide' : 'Show',
                icon: Icon(_showKey ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _showKey = !_showKey),
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _busy ? null : _saveKey,
            child: const Text('Save API key'),
          ),
          const SizedBox(height: 28),
          TextField(
            controller: _modelCtrl,
            autocorrect: false,
            decoration: const InputDecoration(
              labelText: 'Gemini model',
              helperText:
                  'Example: gemini-2.5-flash. 404 error aaye to AI Studio me current model naam check karo.',
              helperMaxLines: 3,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: _busy ? null : _saveModel,
            child: const Text('Save model'),
          ),
          const SizedBox(height: 28),
          OutlinedButton.icon(
            onPressed: _busy ? null : _testConnection,
            icon: const Icon(Icons.wifi_tethering),
            label: const Text('Test connection'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: (_busy || !_hasKey) ? null : _deleteKey,
            style: TextButton.styleFrom(foregroundColor: JaxxColors.danger),
            child: const Text('Delete API key'),
          ),
          if (_busy) ...[
            const SizedBox(height: 16),
            const LinearProgressIndicator(),
          ],
          if (_status != null) ...[
            const SizedBox(height: 16),
            Text(_status!, style: const TextStyle(color: JaxxColors.textPrimary)),
          ],
          const SizedBox(height: 28),
          const Text(
            'Key phone ki secure storage me save hoti hai aur kisi ko dikhayi nahi jaati. '
            'Ye personal use ke liye hai. Public app me key ko backend proxy ke peeche rakhna chahiye, '
            'kyunki APK se key nikali ja sakti hai.',
            style: TextStyle(color: JaxxColors.textMuted, fontSize: 12, height: 1.4),
          ),
        ],
      ),
    );
  }
}
