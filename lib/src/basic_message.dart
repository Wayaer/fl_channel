part of '../fl_channel.dart';

typedef FlBasicMessageHandler = Future<dynamic> Function(dynamic message);

class FlBasicMessage {
  final String name;

  FlBasicMessage(this.name);

  /// 消息通道
  BasicMessageChannel<dynamic>? _messageChannel;

  BasicMessageChannel<dynamic>? get messageChannel => _messageChannel;

  bool get isInitialize => _messageChannel != null;

  /// 初始化消息通道
  Future<FlBasicMessage?> initialize() async {
    if (!_supportPlatform) return null;
    _messageChannel ??= BasicMessageChannel(name, const StandardMessageCodec());
    return this;
  }

  /// 添加消息监听
  bool setMessageHandler(FlBasicMessageHandler? handler) {
    if (_supportPlatform && isInitialize) {
      _messageChannel!.setMessageHandler(handler);
    }
    return isInitialize;
  }

  /// 向Native发送消息
  Future<dynamic> send(dynamic message) async {
    if (_supportPlatform && isInitialize) {
      return await _messageChannel!.send(message);
    }
    return null;
  }

  /// 销毁消息通道
  Future<void> dispose() async {
    _messageChannel?.setMessageHandler(null);
    _messageChannel = null;
  }

  Future<T?> invokeMethod<T>(String method, [dynamic arguments]) async {
    if (_supportPlatform && isInitialize) {
      final result = await _messageChannel!.send({method: arguments});
      return result as T;
    }
    return null;
  }

  bool setMethodCallHandler(
      Future<dynamic> Function(MethodCall call)? handler) {
    if (_supportPlatform && isInitialize) {
      FlBasicMessageHandler? flBasicMessageHandler;
      if (handler != null) {
        flBasicMessageHandler = (message) async {
          if (message is Map) {
            dynamic result;
            message.forEach((key, value) async {
              result = await handler(MethodCall(key, value));
            });
            return result;
          }
          return null;
        };
      }
      setMessageHandler(flBasicMessageHandler);
    }
    return isInitialize;
  }
}
