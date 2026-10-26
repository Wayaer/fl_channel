## 2.0.0

* Add Swift Package Manager support for iOS and macOS with shared Darwin sources
* Add Windows (C++) and Linux (C++/GTK) platform support
* Add Web support with a local Dart event stream and the `flChannelSendEvent` JavaScript bridge
* Make the Web example load CanvasKit locally instead of from the gstatic CDN
* Raise the minimum iOS deployment target to 15.0 and macOS to 12.0
* Upgrade the Android build configuration to AGP 9.1.0, Kotlin 2.4.0, compileSdk 36 and Java 17
* Migrate the Android plugin to AGP built-in Kotlin
* Rewrite the example app for Flutter 3.47.0 with Android, iOS, macOS, Windows, Linux and Web platform shells; the Dart code also supports the Flutter 3.35+ used by the HarmonyOS toolchain
* Keep HarmonyOS (OHOS) platform support
* Fix the Android method channel not replying to unknown methods and improve argument validation
* Raise the minimum Dart SDK to 3.5.0
* Expose `FlChannel.dispose()` and `FlChannel.isSupported`, and add API documentation

## 1.1.1

* Add the `ohos` platform support

## 1.0.3

* Rewrite the creation and destruction methods
* JavaVersion to `JavaVersion.VERSION_17`

## 0.2.0

* Update gradle version

## 0.1.0

* Add the `cancel()` and `setStreamHandler()` methods in native

## 0.0.3

* initial release.
