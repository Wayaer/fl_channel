# fl_channel example

Demonstrates the `fl_channel` plugin:

- Create a native event channel and listen to events
- Pause, resume and dispose the channel
- Send an event through the native side (or the JavaScript bridge on Web)
- Broadcast values with the pure Dart `FlDataStream`

## Run on Android, iOS, macOS, Windows or Linux

```bash
flutter pub get
flutter run
```

## Run on Web

```bash
flutter run -d chrome
```

The example loads CanvasKit from the local `canvaskit/` path instead of the gstatic CDN, so it also works when
the CDN is unreachable. For a release build, keep the local resources:

```bash
flutter build web --no-web-resources-cdn
```

The Web build uses a local Dart event stream. After a channel is created and listened to, JavaScript can send
events with `flChannelSendEvent(name, data)`.

## Run on HarmonyOS

HarmonyOS builds require the OpenHarmony Flutter SDK (`flutter_flutter`), not only DevEco Studio. The SDK
provides `flutter-hvigor-plugin` and `flutter.har`; run `flutter pub get` with that SDK before opening the
project. The example supports Flutter 3.35 and later so the HarmonyOS toolchain and the newer desktop
toolchains can share the same pubspec.

Open `example/ohos` with the OpenHarmony Flutter toolchain and DevEco Studio, then build and run the `entry`
module. The HarmonyOS sources live in the plugin's `ohos` directory and are not changed by the other platforms.
