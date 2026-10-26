import 'package:fl_channel/fl_channel.dart';
import 'package:flutter/material.dart';

class EventChannelPage extends StatefulWidget {
  const EventChannelPage({super.key});

  @override
  State<EventChannelPage> createState() => _EventChannelPageState();
}

class _EventChannelPageState extends State<EventChannelPage> {
  static const String _initialChannelName = 'demo_event';

  final TextEditingController _nameController = TextEditingController(text: _initialChannelName);
  final List<String> _events = <String>[];

  FlEventChannel? _channel;
  String _status = 'Idle. Create a channel to begin.';
  bool _busy = false;

  bool get _hasChannel => _channel != null;

  bool get _isListening => _channel?.isListening ?? false;

  bool get _isPaused => _channel?.isPaused ?? false;

  bool get _canCreate => !_busy && !_hasChannel;

  bool get _canListen => !_busy && _hasChannel && !_isListening;

  bool get _canPause => !_busy && _isListening && !_isPaused;

  bool get _canResume => !_busy && _isListening && _isPaused;

  bool get _canSend => !_busy && _isListening;

  bool get _canDispose => !_busy && _hasChannel;

  @override
  void dispose() {
    _channel?.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Event channel'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Card(
            elevation: 0,
            color: theme.colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextField(
                    controller: _nameController,
                    enabled: !_hasChannel,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      labelText: 'Channel name',
                      helperText: 'The same name is used by native code.',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: <Widget>[
                      Icon(_isListening ? Icons.graphic_eq : Icons.hourglass_empty, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_status, style: theme.textTheme.bodyMedium)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              FilledButton.icon(
                onPressed: _canCreate ? _create : null,
                icon: const Icon(Icons.add_link),
                label: const Text('Create'),
              ),
              OutlinedButton.icon(
                onPressed: _canListen ? _listen : null,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Listen'),
              ),
              OutlinedButton.icon(
                onPressed: _canPause ? _pause : null,
                icon: const Icon(Icons.pause),
                label: const Text('Pause'),
              ),
              OutlinedButton.icon(
                onPressed: _canResume ? _resume : null,
                icon: const Icon(Icons.play_circle_outline),
                label: const Text('Resume'),
              ),
              OutlinedButton.icon(
                onPressed: _canSend ? _sendFromNative : null,
                icon: const Icon(Icons.call_made),
                label: const Text('Send from native'),
              ),
              OutlinedButton.icon(
                onPressed: _canDispose ? _disposeChannel : null,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Dispose'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: <Widget>[
              Expanded(child: Text('Events', style: theme.textTheme.titleMedium)),
              TextButton.icon(
                onPressed: _events.isEmpty ? null : _clearEvents,
                icon: const Icon(Icons.clear_all),
                label: const Text('Clear'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_events.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'No events yet. Attach a listener, then press "Send from native".',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            )
          else
            ..._events.map(
              (String event) => Card(
                elevation: 0,
                child: ListTile(
                  dense: true,
                  leading: Icon(Icons.chevron_right, color: theme.colorScheme.primary),
                  title: Text(event, style: theme.textTheme.bodyMedium),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _create() async {
    final String name = _nameController.text.trim();
    if (name.isEmpty) {
      _setStatus('Channel name cannot be empty.');
      return;
    }
    await _run(() async {
      final FlEventChannel? channel = await FlChannel.instance.create(name);
      if (!mounted) return;
      setState(() {
        _channel = channel;
        _events.clear();
        _status = channel == null
            ? 'Channel "$name" could not be created on this platform.'
            : 'Channel "$name" created.';
      });
    });
  }

  void _listen() {
    final FlEventChannel? channel = _channel;
    if (channel == null) return;
    final bool state = channel.listen(
      (dynamic data) => _append('event: $data'),
      onError: (dynamic error) => _append('error: $error'),
      onDone: () => _append('stream closed'),
    );
    _setStatus(state ? 'Listener attached. Waiting for events.' : 'A listener is already attached.');
  }

  void _pause() {
    final bool state = _channel?.pause() ?? false;
    _setStatus(state ? 'Paused. Events are buffered until resume.' : 'Unable to pause the listener.');
  }

  void _resume() {
    final bool state = _channel?.resume() ?? false;
    _setStatus(state ? 'Listening resumed.' : 'Unable to resume the listener.');
  }

  Future<void> _sendFromNative() async {
    final FlEventChannel? channel = _channel;
    if (channel == null) return;
    final bool success = await FlChannel.instance.sendEventFromNative(
      channel.name,
      'hello from native at ${_timestamp()}',
    );
    _append('native payload delivered: $success');
    _setStatus(success ? 'Event sent from the native side.' : 'The native side has no active listener.');
  }

  Future<void> _disposeChannel() async {
    final FlEventChannel? channel = _channel;
    if (channel == null) return;
    await _run(() async {
      await channel.dispose();
      if (!mounted) return;
      setState(() {
        _channel = null;
        _status = 'Channel disposed.';
      });
    });
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
    } catch (error) {
      _setStatus('Error: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _append(String message) {
    if (!mounted) return;
    setState(() {
      _events.insert(0, '${_timestamp()}  $message');
      if (_events.length > 100) _events.removeLast();
    });
  }

  void _clearEvents() {
    setState(_events.clear);
  }

  void _setStatus(String status) {
    if (!mounted) return;
    setState(() => _status = status);
  }

  String _timestamp() => DateTime.now().toIso8601String().substring(11, 19);
}
