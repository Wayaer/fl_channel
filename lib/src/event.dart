part of '../fl_channel.dart';

typedef FlEventListenData = void Function(dynamic data);
typedef FlEventListenError = void Function(dynamic error);
typedef FlEventListenDone = void Function();

class FlEvent {
  factory FlEvent() => _singleton ??= FlEvent._();

  FlEvent._();

  static FlEvent? _singleton;

  /// 订阅流
  StreamSubscription<dynamic>? _streamSubscription;

  /// 创建流
  Stream<dynamic>? _stream;

  Stream<dynamic>? get stream => _stream;

  /// 消息通道
  EventChannel? _eventChannel;

  bool get isPaused =>
      _streamSubscription != null && _streamSubscription!.isPaused;

  /// 初始化消息通道
  Future<bool> initialize() async {
    if (!_supportPlatform) return false;
    bool? state = await FlChannel()._channel.invokeMethod<bool?>('startEvent');
    state ??= false;
    if (state && _eventChannel == null) {
      _eventChannel = const EventChannel('fl_channel/event');
      _stream = _eventChannel?.receiveBroadcastStream(<dynamic, dynamic>{});
    }
    return state && _eventChannel != null && _stream != null;
  }

  /// 添加消息流监听
  bool addListener<T>(FlEventListenData onData,
      {FlEventListenError? onError,
      FlEventListenDone? onDone,
      bool? cancelOnError}) {
    if (!_supportPlatform) return false;
    if (_eventChannel != null && _stream != null) {
      if (_streamSubscription != null) return false;
      try {
        _streamSubscription = _stream!.listen(onData,
            onError: onError, onDone: onDone, cancelOnError: cancelOnError);
        return true;
      } catch (e) {
        debugPrint(e.toString());
        return false;
      }
    }
    return false;
  }

  /// 调用原生方法 发送消息
  Future<bool> send(dynamic arguments) async {
    if (!_supportPlatform) return false;
    if (_eventChannel == null ||
        _streamSubscription == null ||
        _streamSubscription!.isPaused) return false;
    final state =
        await FlChannel()._channel.invokeMethod<bool?>('sendEvent', arguments);
    return state ?? false;
  }

  /// 暂停消息流监听
  bool pause() {
    if (!_supportPlatform) return false;
    if (_streamSubscription != null && !_streamSubscription!.isPaused) {
      _streamSubscription!.pause();
      return true;
    }
    return false;
  }

  /// 重新开始监听
  bool resume() {
    if (!_supportPlatform) return false;
    if (_streamSubscription != null && _streamSubscription!.isPaused) {
      _streamSubscription!.resume();
      return true;
    }
    return false;
  }

  /// 关闭并销毁消息通道
  Future<bool> dispose() async {
    if (!_supportPlatform) return false;
    await _streamSubscription?.cancel();
    _streamSubscription = null;
    _stream = null;
    _eventChannel = null;
    final state = await FlChannel()._channel.invokeMethod<bool>('stopEvent');
    return state ?? false;
  }
}
