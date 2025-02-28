# fl_channel

- `FlChannel()`、`FlEventChannel()` 。`EventChannel` 封装
```dart
Future<void> create() async {
  final flEvent = await FlChannel().create(name);
}

Future<void> listen() async {
  final state = flEvent?.listen((dynamic data) {});
}

Future<void> sendFromNative() async {
  final status = await FlChannel().sendEventFromNative(
    name,
    'Flutter to Native',
  );
}

Future<void> pause() async {
  await flEvent?.pause();
}

Future<void> resume() async {
  await flEvent?.resume();
}

Future<void> dispose() async {
  await FlChannel().dispose(name);
}

```
