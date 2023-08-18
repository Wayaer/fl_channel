import 'package:example/main.dart';
import 'package:fl_channel/fl_channel.dart';
import 'package:flutter/material.dart';

class FlBasicMessagePage extends StatefulWidget {
  const FlBasicMessagePage({super.key});

  @override
  State<FlBasicMessagePage> createState() => _FlBasicMessagePageState();
}

class _FlBasicMessagePageState extends State<FlBasicMessagePage> {
  String stateText = 'uninitialized';
  FlBasicMessage basicMessage = FlBasicMessage();

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      TextBox('FlBasicMessage', stateText),
      Wrap(spacing: 8, direction: Axis.horizontal, children: <Widget>[
        ElevatedText(onPressed: initialize, text: 'initialize'),
        ElevatedText(onPressed: addListener, text: 'addListener'),
        ElevatedText(onPressed: send, text: 'send msg'),
        ElevatedText(
            onPressed: sendFormNative, text: 'send msg (Native to Dart)'),
        ElevatedText(onPressed: _dispose, text: 'dispose'),
      ]),
    ]);
  }

  void addListener() {
    final bool state = basicMessage.addListener((dynamic data) async {
      addText(data.toString());
      return 'Reply from Dart';
    });
    stateText = 'add listener $state';
    setState(() {});
  }

  Future<void> initialize() async {
    final bool basicMessageState = await basicMessage.initialize();
    if (basicMessageState) {
      stateText = 'initialize successful';
      setState(() {});
    }
  }

  Future<void> sendFormNative() async {
    final bool status = await basicMessage.sendFromNative('Native to Flutter');
    stateText = status ? 'successful' : 'failed';
    setState(() {});
  }

  Future<void> send() async {
    final result = await basicMessage.send('Flutter to Native');
    stateText = result != null ? 'successful' : 'failed';
    addText('Sent successfully and reply: $result');
    setState(() {});
  }

  Future<void> _dispose() async {
    final bool status = await basicMessage.dispose();
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
