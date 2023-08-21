import 'package:example/main.dart';
import 'package:fl_channel/fl_channel.dart';
import 'package:flutter/material.dart';

class FlEventPage extends StatefulWidget {
  const FlEventPage({super.key});

  @override
  State<FlEventPage> createState() => _FlEventPageState();
}

class _FlEventPageState extends State<FlEventPage> {
  String stateText = 'uninitialized';
  FlEvent? flEvent;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      TextBox('FlEvent', stateText),
      Wrap(spacing: 8, direction: Axis.horizontal, children: <Widget>[
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
    ]);
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
}
