import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MessagingScreen extends StatefulWidget {
  const MessagingScreen({super.key});

  @override
  State<MessagingScreen> createState() => _MessagingScreenState();
}

class _MessagingScreenState extends State<MessagingScreen> {
  final _messaging = FirebaseMessaging.instance;
  final _topicController = TextEditingController(text: 'news');
  String? _token;
  String _permissionStatus = 'Unknown';
  final List<String> _subscribedTopics = [];
  final List<String> _log = [];
  RemoteMessage? _lastMessage;

  @override
  void initState() {
    super.initState();
    _setupForegroundListener();
  }

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  void _setupForegroundListener() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      setState(() {
        _lastMessage = message;
        _log.insert(
          0,
          'Received: ${message.notification?.title ?? message.messageId}',
        );
      });
    });
  }

  void _addLog(String message) {
    setState(() {
      _log.insert(0, '[${TimeOfDay.now().format(context)}] $message');
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
    );
  }

  Future<void> _getToken() async {
    try {
      final token = await _messaging.getToken();
      setState(() => _token = token);
      _addLog('FCM token retrieved');
    } catch (e) {
      _addLog('Token error: $e');
    }
  }

  Future<void> _requestPermission() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        announcement: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
      );
      setState(() {
        _permissionStatus = settings.authorizationStatus.name;
      });
      _addLog('Permission: ${settings.authorizationStatus.name}');
    } catch (e) {
      _addLog('Permission error: $e');
    }
  }

  Future<void> _subscribeToTopic() async {
    final topic = _topicController.text.trim();
    if (topic.isEmpty) return;

    try {
      await _messaging.subscribeToTopic(topic);
      if (!_subscribedTopics.contains(topic)) {
        setState(() => _subscribedTopics.add(topic));
      }
      _addLog('Subscribed to "$topic"');
    } catch (e) {
      _addLog('Subscribe error: $e');
    }
  }

  Future<void> _unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      setState(() => _subscribedTopics.remove(topic));
      _addLog('Unsubscribed from "$topic"');
    } catch (e) {
      _addLog('Unsubscribe error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Firebase Messaging')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionTitle('Notification Permission'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    _permissionStatus == 'authorized'
                        ? Icons.check_circle
                        : Icons.info_outline,
                    color: _permissionStatus == 'authorized'
                        ? Colors.green
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('Status: $_permissionStatus'),
                  ),
                  FilledButton.tonal(
                    onPressed: _requestPermission,
                    child: const Text('Request'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          _SectionTitle('FCM Token'),
          FilledButton.icon(
            onPressed: _getToken,
            icon: const Icon(Icons.vpn_key_outlined),
            label: const Text('Get Token'),
          ),
          if (_token != null) ...[
            const SizedBox(height: 8),
            Card(
              color: theme.colorScheme.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: SelectableText(
                            _token!,
                            style: theme.textTheme.bodySmall,
                            maxLines: 3,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 18),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: _token!));
                            _addLog('Token copied to clipboard');
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          _SectionTitle('Topic Subscription'),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _topicController,
                  decoration: const InputDecoration(
                    labelText: 'Topic Name',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _subscribeToTopic,
                child: const Text('Subscribe'),
              ),
            ],
          ),
          if (_subscribedTopics.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _subscribedTopics
                  .map((topic) => Chip(
                        label: Text(topic),
                        onDeleted: () => _unsubscribeFromTopic(topic),
                      ))
                  .toList(),
            ),
          ],
          if (_lastMessage != null) ...[
            const SizedBox(height: 20),
            _SectionTitle('Last Foreground Message'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _lastMessage!.notification?.title ?? 'No title',
                      style: theme.textTheme.titleSmall,
                    ),
                    if (_lastMessage!.notification?.body != null)
                      Text(_lastMessage!.notification!.body!),
                    Text(
                      'ID: ${_lastMessage!.messageId}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ],
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
