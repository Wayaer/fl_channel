import 'package:example/main.dart';
import 'package:fl_channel/fl_channel.dart';
import 'package:flutter/material.dart';

class FlEventPage extends StatefulWidget {
  const FlEventPage({Key? key}) : super(key: key);

  @override
  State<FlEventPage> createState() => _FlEventPageState();
}

class _FlEventPageState extends State<FlEventPage> {
  String stateText = '未初始化';
  ValueNotifier<List<String>> text = ValueNotifier<List<String>>(<String>[]);
  FlEvent event = FlEvent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarText('FlEvent 消息通道'),
        body: Column(children: [
          TextBox('state', stateText),
          Wrap(spacing: 10, direction: Axis.horizontal, children: <Widget>[
            ElevatedText(onPressed: start, text: '注册消息通道'),
            ElevatedText(
                onPressed: () async {
                  final bool state = event.addListener((dynamic data) {
                    text.value.add(data.toString());
                  });
                  stateText = '添加监听 $state';
                  setState(() {});
                },
                text: '添加消息监听'),
            ElevatedText(onPressed: send, text: '发送消息'),
            ElevatedText(
                onPressed: () {
                  final bool state = event.pause();
                  stateText = '暂停消息流监听 $state';
                  setState(() {});
                },
                text: '暂停消息流监听'),
            ElevatedText(
                onPressed: () {
                  final bool state = event.resume();
                  stateText = '重新开始监听 $state';
                  setState(() {});
                },
                text: '重新开始监听'),
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
                  }),
            ),
          )
        ]));
  }

  Future<void> start() async {
    final bool eventState = await event.initialize();
    if (eventState) {
      stateText = '初始化成功';
      setState(() {});
    }
  }

  Future<void> send() async {
    final bool status = await event.send('这条消息是从Flutter 传递到原生');
    stateText = status ? '发送成功' : '发送失败';
    setState(() {});
  }

  Future<void> stop() async {
    final bool status = await event.dispose();
    stateText = status ? '已销毁' : '销毁失败';
    text.value.clear();
    setState(() {});
  }
}
