import 'package:example/src/event.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      debugShowCheckedModeBanner: false,
      title: 'FlChannel',
      home: const App()));
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarText('FlChannel'),
        body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          ElevatedText(
              text: 'FlEvent',
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const FlEventPage()));
              }),
          ElevatedText(
              text: 'FlBasicMessage',
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const FlEventPage()));
              }),
          const SizedBox(width: double.infinity),
        ]));
  }
}

class TextBox extends StatelessWidget {
  const TextBox(this.keyName, this.value, {Key? key}) : super(key: key);
  final dynamic keyName;
  final dynamic value;

  @override
  Widget build(BuildContext context) {
    return Visibility(
        visible: value != null &&
            value.toString().isNotEmpty &&
            value.toString() != 'null',
        child: Container(
            margin: const EdgeInsets.all(10),
            child: Text('$keyName = $value')));
  }
}

class ElevatedText extends ElevatedButton {
  ElevatedText({super.key, required String text, required super.onPressed})
      : super(child: Text(text));
}

class AppBarText extends AppBar {
  AppBarText(String text, {Key? key})
      : super(
            key: key,
            elevation: 0,
            title: Text(text,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            centerTitle: true);
}