import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CrashlyticsScreen extends StatefulWidget {
  const CrashlyticsScreen({super.key});

  @override
  State<CrashlyticsScreen> createState() => _CrashlyticsScreenState();
}

class _CrashlyticsScreenState extends State<CrashlyticsScreen> {
  final _crashlytics = FirebaseCrashlytics.instance;
  final _messageController = TextEditingController(text: 'Test log message');
  final _keyController = TextEditingController(text: 'env');
  final _valueController = TextEditingController(text: 'staging');
  final _userIdController = TextEditingController(text: 'user-123');
  final List<String> _log = [];

  @override
  void dispose() {
    _messageController.dispose();
    _keyController.dispose();
    _valueController.dispose();
    _userIdController.dispose();
    super.dispose();
  }

  void _addLog(String message) {
    setState(() {
      _log.insert(0, '[${TimeOfDay.now().format(context)}] $message');
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
    );
  }

  Future<void> _forceCrash() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Force Crash'),
        content: const Text(
          'This will crash the app. You will need to reopen it. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => context.pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Crash Now'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      _crashlytics.crash();
    }
  }

  Future<void> _recordNonFatalError() async {
    try {
      throw Exception('Sample non-fatal exception from Crashlytics demo');
    } catch (e, stack) {
      await _crashlytics.recordError(e, stack, reason: 'non-fatal test');
      _addLog('Recorded non-fatal error');
    }
  }

  Future<void> _logMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;
    _crashlytics.log(message);
    _addLog('Logged message: $message');
  }

  Future<void> _setCustomKey() async {
    final key = _keyController.text.trim();
    final value = _valueController.text.trim();
    if (key.isEmpty) return;
    await _crashlytics.setCustomKey(key, value);
    _addLog('Set key "$key" = "$value"');
  }

  Future<void> _setUserId() async {
    final userId = _userIdController.text.trim();
    await _crashlytics.setUserIdentifier(userId);
    _addLog(userId.isEmpty
        ? 'Cleared user identifier'
        : 'Set user identifier: $userId');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Firebase Crashlytics')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: theme.colorScheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(Icons.warning_rounded,
                      color: theme.colorScheme.onErrorContainer, size: 32),
                  const SizedBox(height: 8),
                  Text(
                    'Force Crash',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onErrorContainer,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'This will crash the application',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onErrorContainer,
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _forceCrash,
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.error,
                      foregroundColor: theme.colorScheme.onError,
                    ),
                    child: const Text('Crash App'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _SectionTitle('Non-Fatal Error'),
          FilledButton.tonal(
            onPressed: _recordNonFatalError,
            child: const Text('Record Non-Fatal Exception'),
          ),
          const SizedBox(height: 20),
          _SectionTitle('Log Message'),
          TextField(
            controller: _messageController,
            decoration: const InputDecoration(
              labelText: 'Message',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.tonal(
            onPressed: _logMessage,
            child: const Text('Log Message'),
          ),
          const SizedBox(height: 20),
          _SectionTitle('Custom Key'),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _keyController,
                  decoration: const InputDecoration(
                    labelText: 'Key',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _valueController,
                  decoration: const InputDecoration(
                    labelText: 'Value',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FilledButton.tonal(
            onPressed: _setCustomKey,
            child: const Text('Set Custom Key'),
          ),
          const SizedBox(height: 20),
          _SectionTitle('User Identifier'),
          TextField(
            controller: _userIdController,
            decoration: const InputDecoration(
              labelText: 'User ID',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.tonal(
            onPressed: _setUserId,
            child: const Text('Set User Identifier'),
          ),
          if (_log.isNotEmpty) ...[
            const SizedBox(height: 24),
            _SectionTitle('Action Log'),
            Card(
              color: theme.colorScheme.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _log
                      .map((entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(entry,
                                style: theme.textTheme.bodySmall),
                          ))
                      .toList(),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}
