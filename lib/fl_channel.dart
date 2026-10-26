import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// 原生通道通信入口，全局单例。
///
/// 支持 Android、iOS、macOS、Windows、Linux、Web 与 HarmonyOS（OHOS）。
/// Web 平台使用 Dart 侧事件流模拟通道，并暴露 `flChannelSendEvent` 供 JavaScript 调用。
class FlChannel {
  FlChannel._();

  /// 兼容 `FlChannel()` 写法。
  factory FlChannel() => _instance;

  static final FlChannel _instance = FlChannel._();

  /// 全局单例。
  static FlChannel get instance => _instance;

  static const String _defaultChannelName = 'fl_channel/event';

  static const MethodChannel _methodChannel = MethodChannel('fl_channel');

  final Map<String, FlEventChannel> _eventChannels = <String, FlEventChannel>{};

  /// 当前平台是否支持通道。
  bool get isSupported => _supportPlatform;

  /// 获取默认事件通道，不存在时自动创建。
  Future<FlEventChannel?> defaultEventChannel() => create(_defaultChannelName);

  /// 销毁默认事件通道。
  Future<bool> defaultDispose() => dispose(_defaultChannelName);

  /// 创建指定名称的事件通道，已存在时直接返回。
  Future<FlEventChannel?> create(String name) async {
    if (kIsWeb) {
      final existing = _eventChannels[name];
      if (existing != null) return existing;
      final eventChannel = FlEventChannel(name);
      _eventChannels[name] = eventChannel;
      return eventChannel;
    }
    if (!_supportPlatform) return null;
    final existing = _eventChannels[name];
    if (existing != null) return existing;
    final state = await _methodChannel.invokeMethod<bool>('create', name);
    if (state != true) return null;
    final eventChannel = FlEventChannel(name);
    _eventChannels[name] = eventChannel;
    return eventChannel;
  }

  /// 销毁指定名称的事件通道。
  Future<bool> dispose(String name) async {
    if (kIsWeb) {
      final channel = _eventChannels.remove(name);
      await channel?._closeLocalStream();
      return true;
    }
    if (!_eventChannels.containsKey(name)) return true;
    final result = await _methodChannel.invokeMethod<bool>('dispose', name);
    if (result == true) _eventChannels.remove(name);
    return result ?? false;
  }

  /// 由原生侧（Web 平台为 JavaScript）向 Flutter 侧发送事件。
  ///
  /// 事件最终会通过 [FlEventChannel.listen] 注册的回调返回。
  Future<bool> sendEventFromNative(String name, dynamic data) async {
    final channel = _eventChannels[name];
    if (channel == null) return false;
    if (kIsWeb) return channel._dispatchLocalEvent(data);
    if (!_supportPlatform) return false;
    final result = await _methodChannel.invokeMethod<bool>('sendEventFromNative', <String, dynamic>{
      'name': name,
      'data': data,
    });
    return result ?? false;
  }
}

/// 监听数据。
typedef FlEventChannelListenData = void Function(dynamic data);

/// 监听错误。
typedef FlEventChannelListenError = void Function(dynamic error);

/// 事件通道，支持监听、暂停、恢复与销毁。
class FlEventChannel extends EventChannel {
  /// 创建事件通道。
  FlEventChannel(super.name, [super.codec, super.binaryMessenger]) {
    if (kIsWeb) {
      _localController = StreamController<dynamic>.broadcast();
      _stream = _localController!.stream;
    } else {
      _stream = receiveBroadcastStream(<dynamic, dynamic>{});
    }
  }

  StreamSubscription<dynamic>? _streamSubscription;

  Stream<dynamic>? _stream;

  StreamController<dynamic>? _localController;

  /// 事件流，销毁后为 null。
  Stream<dynamic>? get stream => _stream;

  /// 是否已添加监听。
  bool get isListening => _streamSubscription != null;

  /// 是否已暂停监听。
  bool get isPaused => _streamSubscription?.isPaused ?? false;

  /// 添加事件监听，重复调用返回 false。
  bool listen(
    FlEventChannelListenData onData, {
    FlEventChannelListenError? onError,
    VoidCallback? onDone,
    bool? cancelOnError,
  }) {
    if (!_supportPlatform || _stream == null || _streamSubscription != null) return false;
    try {
      _streamSubscription = _stream!.listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
      return true;
    } catch (error) {
      debugPrint(error.toString());
      return false;
    }
  }

  /// 暂停事件监听。
  bool pause() {
    if (!_supportPlatform || _streamSubscription == null || _streamSubscription!.isPaused) return false;
    _streamSubscription!.pause();
    return true;
  }

  /// 恢复事件监听。
  bool resume() {
    if (!_supportPlatform || _streamSubscription == null || !_streamSubscription!.isPaused) return false;
    _streamSubscription!.resume();
    return true;
  }

  /// 取消监听并销毁事件通道。
  Future<bool> dispose() async {
    await _streamSubscription?.cancel();
    _streamSubscription = null;
    _stream = null;
    await _closeLocalStream();
    return FlChannel.instance.dispose(name);
  }

  /// Web 平台向本地事件流分发数据，返回是否存在监听者。
  bool _dispatchLocalEvent(dynamic data) {
    if (_localController == null || _streamSubscription == null) return false;
    _localController!.add(data);
    return true;
  }

  /// 关闭 Web 平台的本地事件流。
  Future<void> _closeLocalStream() async {
    final controller = _localController;
    _localController = null;
    await controller?.close();
  }
}

/// 数据处理回调。
typedef FlDataStreamHandler<T> = void Function(T data);

/// 纯 Dart 数据流，可在同进程内分发数据。
class FlDataStream<T> {
  final List<FlDataStreamHandler<T>> _dataHandlers = <FlDataStreamHandler<T>>[];

  /// 发送数据，遍历期间允许监听器自行取消订阅。
  void send(T data) {
    for (final handler in List<FlDataStreamHandler<T>>.of(_dataHandlers)) {
      handler(data);
    }
  }

  /// 监听数据，返回取消监听的函数。
  VoidCallback listen(FlDataStreamHandler<T> handler) {
    _dataHandlers.add(handler);
    return () => cancel(handler);
  }

  /// 取消监听。
  void cancel(FlDataStreamHandler<T> handler) {
    _dataHandlers.remove(handler);
  }
}

bool get _supportPlatform {
  if (kIsWeb) return true;
  final TargetPlatform platform = defaultTargetPlatform;
  if (platform == TargetPlatform.android ||
      platform == TargetPlatform.iOS ||
      platform == TargetPlatform.macOS ||
      platform == TargetPlatform.windows ||
      platform == TargetPlatform.linux) {
    return true;
  }
  return platform.name == 'ohos';
}
