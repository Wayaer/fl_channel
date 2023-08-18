import 'package:example/main.dart';
import 'package:fl_channel/fl_channel.dart';
import 'package:flutter/material.dart';

class FlBasicMessagePage extends StatefulWidget {
  const FlBasicMessagePage({super.key});

  @override
  State<FlBasicMessagePage> createState() => _FlBasicMessagePageState();
}

class _FlBasicMessagePageState extends State<FlBasicMessagePage> {
  String stateText = '未初始化';
  ValueNotifier<List<String>> text = ValueNotifier<List<String>>(<String>[]);
  FlBasicMessage basicMessage = FlBasicMessage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarText('FlBasicMessage 消息通道'),
        body: Column(children: [
          TextBox('state', stateText),
          Wrap(spacing: 10, direction: Axis.horizontal, children: <Widget>[
            ElevatedText(onPressed: start, text: '注册消息通道'),
            ElevatedText(onPressed: addListener, text: '添加消息监听'),
            ElevatedText(onPressed: send, text: '发送消息'),
            ElevatedText(
                onPressed: sendFormNative, text: '发送消息(Native to Dart)'),
            ElevatedText(onPressed: stop, text: '销毁消息通道'),
          ]),
          const SizedBox(height: 20),
          Expanded(
              child: SafeArea(
                  bottom: true,
                  child: ValueListenableBuilder<List<String>>(
                      valueListenable: text,
                      builder: (_, List<String> value, __) {
                        return ListView.builder(
                            itemCount: value.length,
                            itemBuilder: (_, int index) =>
                                TextBox(index, value[index]));
                      })))
        ]));
  }

  void addListener() {
    final bool state = basicMessage.addListener((dynamic data) async {
      text.value.add(data.toString());
      return 'Reply from Dart';
    });
    stateText = '添加监听 $state';
    setState(() {});
  }

  Future<void> start() async {
    final bool basicMessageState = await basicMessage.initialize();
    if (basicMessageState) {
      stateText = '初始化成功';
      setState(() {});
    }
  }

  Future<void> sendFormNative() async {
    final bool status =
        await basicMessage.sendFromNative('这条消息是从Native到Flutter');
    stateText = status ? '发送成功' : '发送失败';
    setState(() {});
  }

  Future<void> send() async {
    final result = await basicMessage.send('这条消息是从Flutter传递到Native');
    stateText = result != null ? '发送成功' : '发送失败';
    text.value.add('发送成功 并回复: $result');
    setState(() {});
  }

  Future<void> stop() async {
    final bool status = await basicMessage.dispose();
    stateText = status ? '已销毁' : '销毁失败';
    text.value.clear();
    setState(() {});
  }
}
