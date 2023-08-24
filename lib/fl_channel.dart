library fl_channel;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

part 'src/event.dart';

part 'src/data_stream.dart';

class FlChannel {
  factory FlChannel() => _singleton ??= FlChannel._();

  FlChannel._();

  static FlChannel? _singleton;

  final MethodChannel _channel = const MethodChannel('fl_channel');

  FlEvent? _flEvent;

  FlEvent? get flEvent => _flEvent;

  Future<FlEvent?> initFlEvent() async {
    if (_supportPlatform && _flEvent == null) {
      const name = 'fl_channel/event';
      final state =
          await _channel.invokeMethod<bool?>('initFlEvent', {'name': name});
      if (state == true) return _flEvent = FlEvent(name);
    }
    return _flEvent;
  }

  Future<bool> disposeFlEvent() async {
    _flEvent?.dispose();
    _flEvent = null;
    final state = await _channel.invokeMethod<bool>('disposeFlEvent');
    return state ?? false;
  }

  Future<bool> sendFlEventFromNative(dynamic args) async {
    if (_supportPlatform && _flEvent != null && !_flEvent!.isPaused) {
      final state =
          await _channel.invokeMethod<bool?>('sendFlEventFromNative', args);
      return state ?? false;
    }
    return false;
  }
}

bool get _supportPlatform {
  if (kIsWeb) return false;
  return defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.android;
}
