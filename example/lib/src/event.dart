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
  FlEvent event = FlEvent();

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      TextBox('FlEvent', stateText),
      Wrap(spacing: 8, direction: Axis.horizontal, children: <Widget>[
        ElevatedText(onPressed: initialize, text: 'initialize'),
        ElevatedText(onPressed: addListener, text: 'addListener'),
        ElevatedText(onPressed: send, text: 'send msg'),
        ElevatedText(
            onPressed: () {
              final bool state = event.pause();
              stateText = 'pause $state';
              setState(() {});
            },
            text: 'pause'),
        ElevatedText(
            onPressed: () {
              final bool state = event.resume();
              stateText = 'resume $state';
              setState(() {});
            },
            text: 'resume'),
        ElevatedText(onPressed: _dispose, text: 'dispose'),
      ]),
    ]);
  }

  void addListener() {
    final bool state = event.addListener((dynamic data) {
      addText(data.toString());
    });
    stateText = 'add listener $state';
    setState(() {});
  }

  Future<void> initialize() async {
    final bool eventState = await event.initialize();
    if (eventState) {
      stateText = 'initialize successful';
      setState(() {});
    }
  }

  Future<void> send() async {
    final bool status = await event.send('Flutter to Native');
    stateText = status ? 'successful' : 'failed';
    setState(() {});
  }

  Future<void> _dispose() async {
    final bool status = await event.dispose();
    stateText = status ? 'successful' : 'failed';
    texts.value = [];
    setState(() {});
  }

  void addText(String text) {
    final value = [...texts.value];
    value.add(text);
    texts.value = value;
  }
}
