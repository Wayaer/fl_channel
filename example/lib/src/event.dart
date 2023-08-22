import 'package:example/main.dart';
import 'package:fl_channel/fl_channel.dart';
import 'package:flutter/material.dart';

class FlEventPage extends StatefulWidget {
  const FlEventPage({super.key});

  @override
  State<FlEventPage> createState() => _FlEventPageState();
}

class _FlEventPageState extends State<FlEventPage> {
  final ValueNotifier<List<String>> texts =
      ValueNotifier<List<String>>(<String>[]);

  String stateText = 'uninitialized';
  FlEvent? flEvent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarText('FlEvent'),
      body: Column(children: [
        TextBox('FlEvent', stateText),
        Wrap(
            spacing: 8,
            direction: Axis.horizontal,
            alignment: WrapAlignment.center,
            children: [
              ElevatedText(onPressed: initialize, text: 'initialize'),
              ElevatedText(onPressed: listen, text: 'listen'),
              ElevatedText(onPressed: sendFromNative, text: 'send from native'),
              ElevatedText(
                  onPressed: () {
                    stateText = 'pause ${flEvent?.pause()}';
                    setState(() {});
                  },
                  text: 'pause'),
              ElevatedText(
                  onPressed: () {
                    stateText = 'resume ${flEvent?.resume()}';
                    setState(() {});
                  },
                  text: 'resume'),
              ElevatedText(onPressed: _dispose, text: 'dispose'),
            ]),
        Expanded(
            child: ValueListenableBuilder<List<String>>(
                valueListenable: texts,
                builder: (_, List<String> value, __) {
                  return ListView.builder(
                      itemCount: value.length,
                      itemBuilder: (_, int index) =>
                          TextBox(index, value[index]));
                }))
      ]),
    );
  }

  Future<void> initialize() async {
    flEvent = await FlChannel().initFlEvent();
    stateText = 'initialize ${flEvent != null} ';
    setState(() {});
  }

  void listen() {
    final state = flEvent?.listen((dynamic data) {
      addText(data.toString());
    });
    stateText = 'add listener ${state ?? false}';
    setState(() {});
  }

  Future<void> sendFromNative() async {
    final status = await FlChannel().sendFlEventFromNative('Flutter to Native');
    stateText = status ? 'successful' : 'failed';
    setState(() {});
  }

  Future<void> _dispose() async {
    FlChannel().disposeFlEvent();
    stateText = 'successful';
    texts.value = [];
    setState(() {});
  }

  void addText(String text) {
    final value = [...texts.value];
    value.add(text);
    texts.value = value;
  }

  @override
  void dispose() {
    super.dispose();
    texts.dispose();
  }
}
