import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final _analytics = FirebaseAnalytics.instance;
  final _eventNameController = TextEditingController(text: 'test_event');
  final _paramKeyController = TextEditingController(text: 'item_name');
  final _paramValueController = TextEditingController(text: 'sample_item');
  final _userIdController = TextEditingController();
  final _propertyNameController = TextEditingController(text: 'favorite_food');
  final _propertyValueController = TextEditingController(text: 'pizza');
  final List<String> _log = [];

  @override
  void dispose() {
    _eventNameController.dispose();
    _paramKeyController.dispose();
    _paramValueController.dispose();
    _userIdController.dispose();
    _propertyNameController.dispose();
    _propertyValueController.dispose();
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

  Future<void> _logCustomEvent() async {
    final name = _eventNameController.text.trim();
    final paramKey = _paramKeyController.text.trim();
    final paramValue = _paramValueController.text.trim();
    if (name.isEmpty) return;

    await _analytics.logEvent(
      name: name,
      parameters: paramKey.isNotEmpty ? {paramKey: paramValue} : null,
    );
    _addLog('Logged event: $name');
  }

  Future<void> _logScreenView() async {
    await _analytics.logScreenView(
      screenName: 'AnalyticsDemoScreen',
      screenClass: 'AnalyticsScreen',
    );
    _addLog('Logged screen view: AnalyticsDemoScreen');
  }

  Future<void> _setUserId() async {
    final userId = _userIdController.text.trim();
    await _analytics.setUserId(id: userId.isEmpty ? null : userId);
    _addLog(userId.isEmpty ? 'Cleared user ID' : 'Set user ID: $userId');
  }

  Future<void> _setUserProperty() async {
    final name = _propertyNameController.text.trim();
    final value = _propertyValueController.text.trim();
    if (name.isEmpty) return;

    await _analytics.setUserProperty(
      name: name,
      value: value.isEmpty ? null : value,
    );
    _addLog('Set property "$name" = "$value"');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Firebase Analytics')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionTitle('Log Custom Event'),
          TextField(
            controller: _eventNameController,
            decoration: const InputDecoration(
              labelText: 'Event Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _paramKeyController,
                  decoration: const InputDecoration(
                    labelText: 'Param Key',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _paramValueController,
                  decoration: const InputDecoration(
                    labelText: 'Param Value',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: _logCustomEvent,
            icon: const Icon(Icons.send),
            label: const Text('Log Event'),
          ),
          const SizedBox(height: 20),
          _SectionTitle('Screen View'),
          FilledButton.tonal(
            onPressed: _logScreenView,
            child: const Text('Log Screen View'),
          ),
          const SizedBox(height: 20),
          _SectionTitle('User ID'),
          TextField(
            controller: _userIdController,
            decoration: const InputDecoration(
              labelText: 'User ID (empty to clear)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.tonal(
            onPressed: _setUserId,
            child: const Text('Set User ID'),
          ),
          const SizedBox(height: 20),
          _SectionTitle('User Property'),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _propertyNameController,
                  decoration: const InputDecoration(
                    labelText: 'Property Name',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _propertyValueController,
                  decoration: const InputDecoration(
                    labelText: 'Property Value',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FilledButton.tonal(
            onPressed: _setUserProperty,
            child: const Text('Set User Property'),
          ),
          if (_log.isNotEmpty) ...[
            const SizedBox(height: 24),
            _SectionTitle('Event Log'),
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
