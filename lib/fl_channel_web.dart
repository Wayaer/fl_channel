import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:fl_channel/fl_channel.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

/// Web 插件注册入口。
///
/// Web 平台没有原生进程，事件通道由 Dart 侧本地事件流模拟。Dart 侧创建并监听通道后，
/// JavaScript 可通过 `flChannelSendEvent(name, data)` 向 Flutter 发送事件。
class FlChannelWeb {
  /// 注册 Web 插件并暴露 JavaScript 事件入口。
  static void registerWith(Registrar registrar) {
    globalContext['flChannelSendEvent'] = ((JSString name, JSAny? data) {
      final Object? payload = data?.dartify();
      unawaited(FlChannel.instance.sendEventFromNative(name.toDart, payload));
    }).toJS;
  }
}
