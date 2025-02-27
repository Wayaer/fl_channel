import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class FlChannel {
  factory FlChannel() => _singleton ??= FlChannel._();

  FlChannel._();

  static FlChannel? _singleton;

  final MethodChannel _channel = const MethodChannel('fl_channel');

  final String _name = 'fl_channel/event';

  /// 默认消息通道
  Future<FlEventChannel?> defaultEventChannel() async {
    if (_eventChannels.containsKey(_name)) {
      return _eventChannels[_name]!;
    } else {
      return await create(_name);
    }
  }

  /// 销毁默认消息通道
  Future<bool> defaultDispose() => _dispose(_name);

  /// 全局消息通道
  final Map<String, FlEventChannel> _eventChannels = {};

  Future<FlEventChannel?> create(String name) async {
    if (!_supportPlatform) return null;
    if (_eventChannels.containsKey(name)) return _eventChannels[name];
    final state = await _channel.invokeMethod<bool>('create', name);
    if (state == true) {
      final eventChannel = FlEventChannel(name);
      _eventChannels[name] = eventChannel;
      return eventChannel;
    }
    return null;
  }

  /// 销毁
  Future<bool> _dispose(String name) async {
    if (!_eventChannels.containsKey(name)) return true;
    final result = await _channel.invokeMethod<bool>('dispose', name);
    if (result == true) _eventChannels.remove(name);
    return result ?? false;
  }

  Future<bool> sendEventFromNative(String name, dynamic data) async {
    if (!_supportPlatform) return false;
    if (!_eventChannels.containsKey(name)) return false;
    final result = await _channel.invokeMethod('sendEventFromNative', {
      'name': name,
      'data': data,
    });
    return result ?? false;
  }
}

/// 监听数据
typedef FlEventChannelListenData = void Function(dynamic data);

/// 监听错误
typedef FlEventChannelListenError = void Function(dynamic error);

class FlEventChannel extends EventChannel {
  FlEventChannel(super.name, [super.codec, super.binaryMessenger]) {
    _stream = receiveBroadcastStream(<dynamic, dynamic>{});
  }

  /// 订阅流
  StreamSubscription<dynamic>? _streamSubscription;

  /// 创建流
  Stream<dynamic>? _stream;

  Stream<dynamic>? get stream => _stream;

  bool get isPaused =>
      _streamSubscription != null && _streamSubscription!.isPaused;

  /// 添加消息流监听
  bool listen<T>(
    FlEventChannelListenData onData, {
    FlEventChannelListenError? onError,
    VoidCallback? onDone,
    bool? cancelOnError,
  }) {
    if (_supportPlatform && _stream != null && _streamSubscription == null) {
      try {
        _streamSubscription = _stream!.listen(
          onData,
          onError: onError,
          onDone: onDone,
          cancelOnError: cancelOnError,
        );
        return true;
      } catch (e) {
        debugPrint(e.toString());
      }
    }
    return false;
  }

  /// 暂停消息流监听
  bool pause() {
    if (_supportPlatform &&
        _streamSubscription != null &&
        !_streamSubscription!.isPaused) {
      _streamSubscription!.pause();
      return true;
    }
    return false;
  }

  /// 重新开始监听
  bool resume() {
    if (_supportPlatform &&
        _streamSubscription != null &&
        _streamSubscription!.isPaused) {
      _streamSubscription!.resume();
      return true;
    }
    return false;
  }

  /// 关闭并销毁消息通道
  Future<bool> dispose() async {
    await _streamSubscription?.cancel();
    _streamSubscription = null;
    _stream = null;
    return await FlChannel()._dispose(name);
  }
}

typedef FlDataStreamHandler<T> = void Function(T);

class FlDataStream<T> {
  final List<FlDataStreamHandler<T>> _dataHandlers = [];

  /// 发送数据
  void send(T data) {
    for (var handler in _dataHandlers) {
      handler(data);
    }
  }

  /// 监听数据
  void Function() listen(FlDataStreamHandler<T> handler) {
    _dataHandlers.add(handler);
    return () => cancel(handler);
  }

  /// 取消监听
  void cancel(FlDataStreamHandler<T> handler) {
    _dataHandlers.remove(handler);
  }
}

bool get _supportPlatform {
  if (kIsWeb) return false;
  return defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.android;
}
