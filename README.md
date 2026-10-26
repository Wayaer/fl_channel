# fl_channel

[![pub package](https://img.shields.io/pub/v/fl_channel.svg)](https://pub.dev/packages/fl_channel)
[Web example](https://wayaer.github.io/fl_channel/example/app/web/)

Native channel communication for Flutter. Create event channels, control their lifecycle from Dart, and push
events from native code back to Flutter.

## Supported platforms

| Platform        | Support | Native implementation            |
|-----------------|---------|----------------------------------|
| Android         | Yes     | Kotlin, minSdk 24                |
| iOS             | Yes     | Swift, iOS 15.0+, Swift Package Manager and CocoaPods |
| macOS           | Yes     | Swift, macOS 12.0+, Swift Package Manager and CocoaPods |
| Windows         | Yes     | C++, MethodChannel and EventChannel |
| Linux           | Yes     | C++ and GTK, MethodChannel and EventChannel |
| Web             | Yes     | Dart event stream and JavaScript bridge |
| HarmonyOS (OHOS)| Yes     | ArkTS                            |

## Requirements

- Flutter `>=3.24.0`
- Dart `>=3.5.0`

Android builds use AGP 9.1 and Gradle 9.3, so they require Flutter 3.47.0 or later. HarmonyOS builds use the
OpenHarmony Flutter SDK, which may be based on an earlier Flutter release.

## Installation

```yaml
dependencies:
  fl_channel: ^2.0.0
```

## Usage

### Create an event channel

```dart
final FlEventChannel? channel = await FlChannel.instance.create('event_test');
```

`create` returns the existing channel when it has already been created.

### Listen to events

```dart
final bool listening = channel?.listen(
  (dynamic data) {
    debugPrint('received: $data');
  },
  onError: (dynamic error) {
    debugPrint('error: $error');
  },
) ?? false;
```

### Pause, resume and dispose

```dart
channel?.pause();
channel?.resume();
final bool paused = channel?.isPaused ?? false;

await channel?.dispose();
```

### Send an event from Dart for demonstration

```dart
await FlChannel.instance.sendEventFromNative('event_test', 'Hello from Dart');
```

This method goes through the native plugin and emits the payload on the event channel. On Web it dispatches
the payload to the local Dart event stream. It is useful for smoke tests; real applications usually send
events from native code as shown below.

### Default channel

```dart
final FlEventChannel? channel = await FlChannel.instance.defaultEventChannel();
await FlChannel.instance.defaultDispose();
```

The default channel name is `fl_channel/event`.

### Pure Dart data stream

`FlDataStream<T>` is a small in-process event bus that does not involve native code.

```dart
final FlDataStream<String> stream = FlDataStream<String>();
final void Function() cancel = stream.listen((String data) {
  debugPrint(data);
});

stream.send('hello');
cancel();
```

## Sending events from native code

Create the channel from Dart first, then send events from native code.

Android (Kotlin):

```kotlin
FlChannelPlugin.getEventChannel("event_test")?.send(mapOf("value" to 42))
```

iOS and macOS (Swift):

```swift
FlChannelPlugin.getEventChannel("event_test")?.send(["value": 42])
```

HarmonyOS (ArkTS):

```typescript
FlChannelPlugin.getEventChannel("event_test")?.send({ value: 42 });
```

Windows and Linux events are delivered by the plugin's C++ EventChannel implementation, so applications use
the same Dart API on every desktop platform.

## Web JavaScript bridge

Web platforms have no native process. Channels are simulated with a local Dart stream, and JavaScript can
send events to an existing channel:

```javascript
flChannelSendEvent('event_test', 'hello from JavaScript');
```

The channel must be created and listened to from Dart before JavaScript sends an event.

If `www.gstatic.com` is unreachable, self-host CanvasKit by running `flutter build web --no-web-resources-cdn`,
or point `canvasKitBaseUrl` at a local `canvaskit/` directory. The example app already does this in
`web/flutter_bootstrap.js`.

## Swift Package Manager

iOS and macOS sources are shared in `darwin/` and expose a `Package.swift`, so the plugin works with both
Swift Package Manager and CocoaPods.

## Example

The `example` app demonstrates creating a channel, listening to events, pausing, resuming, disposing and
sending events. It supports Android, iOS, macOS, Windows, Linux, Web and HarmonyOS.

Run it with:

```bash
cd example
flutter run
```

For Web:

```bash
cd example
flutter run -d chrome
```

To build the Web example without the gstatic CDN, use the bundled CanvasKit files:

```bash
cd example
flutter build web --no-web-resources-cdn
```

## License

MIT
