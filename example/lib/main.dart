import 'package:example/data_stream_page.dart';
import 'package:example/event_channel_page.dart';
import 'package:fl_channel/fl_channel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  static const Color seedColor = Color(0xFF0F766E);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'fl_channel',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: seedColor), useMaterial3: true),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: seedColor, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('fl_channel'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          const _PlatformCard(),
          const SizedBox(height: 16),
          _DemoTile(
            icon: Icons.swap_horiz,
            title: 'Event channel',
            subtitle: 'Create a native event channel and control its lifecycle.',
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const EventChannelPage()));
            },
          ),
          const SizedBox(height: 12),
          _DemoTile(
            icon: Icons.stream,
            title: 'Data stream',
            subtitle: 'Broadcast values to multiple listeners with FlDataStream.',
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const DataStreamPage()));
            },
          ),
        ],
      ),
    );
  }
}

class _PlatformCard extends StatelessWidget {
  const _PlatformCard();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool supported = FlChannel.instance.isSupported;
    final String platform = kIsWeb ? 'Web' : defaultTargetPlatform.name;
    final Color color = supported ? theme.colorScheme.primary : theme.colorScheme.error;
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest,
      child: ListTile(
        leading: Icon(supported ? Icons.bolt : Icons.block, color: color),
        title: Text('Running on $platform'),
        subtitle: Text(
          supported ? 'Native channels are available.' : 'Native channels are not supported on this platform.',
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
          child: Text(
            supported ? 'Supported' : 'Unsupported',
            style: theme.textTheme.labelMedium?.copyWith(color: color, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

class _DemoTile extends StatelessWidget {
  const _DemoTile({required this.icon, required this.title, required this.subtitle, required this.onTap});

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        leading: CircleAvatar(child: Icon(icon)),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
