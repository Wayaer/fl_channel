import 'package:fl_channel/fl_channel.dart';
import 'package:flutter/material.dart';

class DataStreamPage extends StatefulWidget {
  const DataStreamPage({super.key});

  @override
  State<DataStreamPage> createState() => _DataStreamPageState();
}

class _DataStreamPageState extends State<DataStreamPage> {
  final FlDataStream<int> _stream = FlDataStream<int>();
  final List<String> _log = <String>[];

  int _sequence = 0;
  VoidCallback? _cancelFirst;
  VoidCallback? _cancelSecond;

  bool get _firstActive => _cancelFirst != null;

  bool get _secondActive => _cancelSecond != null;

  @override
  void dispose() {
    _cancelFirst?.call();
    _cancelSecond?.call();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Data stream'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Text(
            'FlDataStream distributes values inside Dart only. It does not use a native channel.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              FilledButton.icon(
                onPressed: _firstActive ? null : _subscribeFirst,
                icon: const Icon(Icons.person_add_alt),
                label: const Text('Subscribe listener A'),
              ),
              OutlinedButton.icon(
                onPressed: _secondActive ? null : _subscribeSecond,
                icon: const Icon(Icons.person_add_alt),
                label: const Text('Subscribe listener B'),
              ),
              OutlinedButton.icon(
                onPressed: _firstActive || _secondActive ? _emit : null,
                icon: const Icon(Icons.send),
                label: const Text('Send value'),
              ),
              OutlinedButton.icon(
                onPressed: _firstActive || _secondActive ? _unsubscribeAll : null,
                icon: const Icon(Icons.person_remove),
                label: const Text('Unsubscribe all'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: <Widget>[
              Expanded(child: Text('Activity', style: theme.textTheme.titleMedium)),
              TextButton.icon(
                onPressed: _log.isEmpty ? null : _clearLog,
                icon: const Icon(Icons.clear_all),
                label: const Text('Clear'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_log.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'Subscribe a listener, then send a value.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            )
          else
            ..._log.map(
              (String entry) => Card(
                elevation: 0,
                child: ListTile(
                  dense: true,
                  leading: Icon(Icons.chevron_right, color: theme.colorScheme.primary),
                  title: Text(entry, style: theme.textTheme.bodyMedium),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _subscribeFirst() {
    _cancelFirst = _stream.listen((int data) => _append('Listener A received $data'));
    setState(() {});
    _append('Listener A subscribed');
  }

  void _subscribeSecond() {
    _cancelSecond = _stream.listen((int data) => _append('Listener B received $data'));
    setState(() {});
    _append('Listener B subscribed');
  }

  void _emit() {
    _sequence += 1;
    _stream.send(_sequence);
  }

  void _unsubscribeAll() {
    _cancelFirst?.call();
    _cancelSecond?.call();
    _cancelFirst = null;
    _cancelSecond = null;
    setState(() {});
    _append('All listeners unsubscribed');
  }

  void _clearLog() {
    setState(_log.clear);
  }

  void _append(String message) {
    if (!mounted) return;
    setState(() {
      _log.insert(0, message);
      if (_log.length > 100) _log.removeLast();
    });
  }
}
