import 'package:example/main.dart';
import 'package:fl_channel/fl_channel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FlBasicMessageMethodCallPage extends StatefulWidget {
  const FlBasicMessageMethodCallPage({super.key});

  @override
  State<FlBasicMessageMethodCallPage> createState() =>
      _FlBasicMessagePageState();
}

class _FlBasicMessagePageState extends State<FlBasicMessageMethodCallPage> {
  final ValueNotifier<List<String>> texts =
      ValueNotifier<List<String>>(<String>[]);
  String stateText = 'uninitialized';
  FlBasicMessage? flBasicMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarText('FlBasicMessage'),
        body: Column(children: [
          TextBox('FlBasicMessage', stateText),
          Wrap(
              spacing: 8,
              direction: Axis.horizontal,
              alignment: WrapAlignment.center,
              children: [
                ElevatedText(onPressed: initialize, text: 'initialize'),
                ElevatedText(
                    onPressed: setMethodCallHandler,
                    text: 'setMethodCallHandler'),
                ElevatedText(onPressed: invokeMethod, text: 'invoke method '),
                ElevatedText(
                    onPressed: invokeMethodFormNative,
                    text: 'invoke method from native'),
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
        ]));
  }

  void setMethodCallHandler() {
    /// add native listener
    FlChannel().setFlBasicMethodCallHandler();

    /// add dart listener
    final state = flBasicMessage?.setMethodCallHandler((MethodCall call) async {
      addText('Native call: ${call.method} = ${call.arguments}');
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

  Future<void> invokeMethodFormNative() async {
    final status = await FlChannel()
        .sendFlBasicMethodCallFromNative('callDart', 'Call dart from Native');
    stateText = status ? 'successful' : 'failed';
    setState(() {});
  }

  Future<void> invokeMethod() async {
    final result = await flBasicMessage?.invokeMethod(
        'callNative', 'Call native from dart');
    stateText = result != null ? 'successful' : 'failed';
    if (result != null) addText('invokeMethod result: $result');
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

  @override
  void dispose() {
    super.dispose();
    texts.dispose();
  }
}
