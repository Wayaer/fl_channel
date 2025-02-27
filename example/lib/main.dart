import 'package:fl_channel/fl_channel.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      debugShowCheckedModeBanner: false,
      title: 'FlChannel',
      home: Scaffold(
        appBar: AppBarText('FlChannel'),
        body: Padding(padding: const EdgeInsets.all(8.0), child: FlEventPage()),
      ),
    );
  }
}

class FlEventPage extends StatefulWidget {
  const FlEventPage({super.key});

  @override
  State<FlEventPage> createState() => _FlEventPageState();
}

class _FlEventPageState extends State<FlEventPage> {
  List<String> texts = [];

  String name = 'event_test';

  String stateText = 'uninitialized';

  FlEventChannel? flEvent;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('FlEvent : $stateText'),
        Wrap(
          spacing: 8,
          direction: Axis.horizontal,
          alignment: WrapAlignment.center,
          children: [
            ElevatedText('create', onPressed: create),
            ElevatedText('listen', onPressed: listen),
            ElevatedText('send from native', onPressed: sendFromNative),
            ElevatedText(
              'pause',
              onPressed: () {
                stateText = 'pause ${flEvent?.pause()}';
                setState(() {});
              },
            ),
            ElevatedText(
              'resume',
              onPressed: () {
                stateText = 'resume ${flEvent?.resume()}';
                setState(() {});
              },
            ),
            ElevatedText('dispose', onPressed: _dispose),
          ],
        ),
        Expanded(
          child: ListView.builder(
            itemCount: texts.length,
            itemBuilder: (_, int index) => Text(texts[index]),
          ),
        ),
      ],
    );
  }

  Future<void> create() async {
    flEvent = await FlChannel().create(name);
    stateText = 'create ${flEvent != null} ';
    setState(() {});
  }

  void listen() {
    final state = flEvent?.listen((dynamic data) {
      texts.insert(0, '${DateTime.now().toString().split('.').first} : $data');
      setState(() {});
    });
    stateText = 'add listener ${state ?? false}';
    setState(() {});
  }

  Future<void> sendFromNative() async {
    final status = await FlChannel().sendEventFromNative(
      name,
      'Flutter to Native',
    );
    stateText = status ? 'successful' : 'failed';
    setState(() {});
  }

  Future<void> _dispose() async {
    await flEvent?.dispose();
    stateText = 'successful';
    texts = [];
    setState(() {});
  }
}

class ElevatedText extends ElevatedButton {
  ElevatedText(String text, {super.key, required super.onPressed})
    : super(child: Text(text));
}

class AppBarText extends AppBar {
  AppBarText(String text, {super.key})
    : super(
        elevation: 0,
        title: Text(
          text,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      );
}
