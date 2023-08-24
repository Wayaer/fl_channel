part of '../fl_channel.dart';

typedef FlEventListenData = void Function(dynamic data);
typedef FlEventListenError = void Function(dynamic error);
typedef FlEventListenDone = void Function();

class FlEvent extends EventChannel {
  FlEvent(super.name, [super.codec, super.binaryMessenger]) {
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
  bool listen<T>(FlEventListenData onData,
      {FlEventListenError? onError,
      FlEventListenDone? onDone,
      bool? cancelOnError}) {
    if (_supportPlatform && _stream != null) {
      if (_streamSubscription != null) return false;
      try {
        _streamSubscription = _stream!.listen(onData,
            onError: onError, onDone: onDone, cancelOnError: cancelOnError);
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
  Future<void> cancel() async {
    await _streamSubscription?.cancel();
    _streamSubscription = null;
    _stream = null;
  }
}
