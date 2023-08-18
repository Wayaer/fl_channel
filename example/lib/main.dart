import 'package:example/src/basic_message.dart';
import 'package:example/src/event.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      debugShowCheckedModeBanner: false,
      title: 'FlChannel',
      home: Scaffold(appBar: AppBarText('FlChannel'), body: const App())));
}

final ValueNotifier<List<String>> texts =
    ValueNotifier<List<String>>(<String>[]);

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const SizedBox(width: double.infinity, child: Card(child: FlEventPage())),
      const SizedBox(
          width: double.infinity, child: Card(child: FlBasicMessagePage())),
      Expanded(
          child: ValueListenableBuilder<List<String>>(
              valueListenable: texts,
              builder: (_, List<String> value, __) {
                return ListView.builder(
                    itemCount: value.length,
                    itemBuilder: (_, int index) =>
                        TextBox(index, value[index]));
              }))
    ]);
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
            margin: const EdgeInsets.all(8), child: Text('$keyName = $value')));
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
