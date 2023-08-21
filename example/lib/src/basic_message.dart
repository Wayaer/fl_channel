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
  FlBasicMessage? flBasicMessage;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      TextBox('FlBasicMessage', stateText),
      Wrap(spacing: 8, direction: Axis.horizontal, children: <Widget>[
        ElevatedText(onPressed: initialize, text: 'initialize'),
        ElevatedText(onPressed: setMessageHandler, text: 'setMessageHandler'),
        ElevatedText(onPressed: sendToNative, text: 'send to native '),
        ElevatedText(onPressed: sendFormNative, text: 'send from native'),
        ElevatedText(onPressed: _dispose, text: 'dispose'),
      ]),
    ]);
  }

  void setMessageHandler() {
    /// add native listener
    FlChannel().addFlBasicMessageListenerForNative();

    /// add dart listener
    final state = flBasicMessage?.setMessageHandler((dynamic data) async {
      addText(data.toString());
      return 'Reply from Dart';
    });
    stateText = 'add listener ${state ?? false}';
    setState(() {});
  }

  Future<void> initialize() async {
    flBasicMessage = await FlChannel().initFlBasicMessage();
    stateText = 'initialize ${flBasicMessage != null}';
    setState(() {});
  }

  Future<void> sendFormNative() async {
    final status =
        await FlChannel().sendFlBasicMessageFromNative('Native to Flutter');
    stateText = status ? 'successful' : 'failed';
    setState(() {});
  }

  Future<void> sendToNative() async {
    final result = await flBasicMessage?.send('Flutter to Native');
    stateText = result != null ? 'successful' : 'failed';
    if (result != null) addText('Sent successfully and reply: $result');
    setState(() {});
  }

  Future<void> _dispose() async {
    final status = await FlChannel().disposeFlBasicMessage();
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
