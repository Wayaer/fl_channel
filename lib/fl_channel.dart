library fl_channel;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

part 'src/event.dart';

part 'src/basic_message.dart';

part 'src/data_stream.dart';

class FlChannel {
  factory FlChannel() => _singleton ??= FlChannel._();

  FlChannel._();

  static FlChannel? _singleton;

  final MethodChannel _channel = const MethodChannel('fl_channel');

  FlEvent? _flEvent;

  FlBasicMessage? _flBasicMessage;

  Future<FlEvent?> initFlEvent() async {
    if (_supportPlatform && _flEvent == null) {
      const name = 'fl_channel/event';
      final state =
          await _channel.invokeMethod<bool?>('initFlEvent', {'name': name});
      if (state == true) {
        _flEvent = FlEvent(name);
        return await _flEvent!.initialize();
      }
    }
    return _flEvent;
  }

  Future<bool> disposeFlEvent() async {
    _flEvent?.dispose();
    _flEvent = null;
    final state = await _channel.invokeMethod<bool>('disposeFlEvent');
    return state ?? false;
  }

  /// 调用原生方法 发送消息
  Future<bool> sendFlEventFromNative(dynamic args) async {
    if (_supportPlatform && _flEvent != null && !_flEvent!.isPaused) {
      final state =
          await _channel.invokeMethod<bool?>('sendFlEventFromNative', args);
      return state ?? false;
    }
    return false;
  }

  Future<FlBasicMessage?> initFlBasicMessage() async {
    if (_supportPlatform && _flBasicMessage == null) {
      const name = 'fl_channel/basic_message';
      final state = await _channel
          .invokeMethod<bool?>('initFlBasicMessage', {'name': name});
      if (state == true) {
        _flBasicMessage = FlBasicMessage(name);
        return await _flBasicMessage!.initialize();
      }
    }
    return _flBasicMessage;
  }

  Future<bool> addFlBasicMessageListenerForNative() async {
    if (_supportPlatform && _flBasicMessage != null) {
      final state = await _channel
          .invokeMethod<bool?>('addFlBasicMessageListenerForNative');
      return state ?? false;
    }
    return false;
  }

  /// 向Native发送消息
  Future<bool> sendFlBasicMessageFromNative(dynamic message) async {
    if (_supportPlatform && _flBasicMessage != null) {
      final state = await _channel.invokeMethod<bool?>(
          'sendFlBasicMessageFromNative', message);
      return state ?? false;
    }
    return false;
  }

  Future<bool> disposeFlBasicMessage() async {
    _flBasicMessage?.dispose();
    _flBasicMessage = null;
    final state = await _channel.invokeMethod<bool>('disposeFlBasicMessage');
    return state ?? false;
  }
}

bool get _supportPlatform {
  if (kIsWeb) return false;
  return defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.android;
}
