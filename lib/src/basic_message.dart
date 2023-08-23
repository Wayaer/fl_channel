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
      return _messageChannel!.invokeMethod(method, arguments);
    }
    return null;
  }

  bool setMethodCallHandler(
      Future<dynamic> Function(MethodCall call)? handler) {
    if (_supportPlatform && isInitialize) {
      _messageChannel?.setMethodCallHandler(handler);
    }
    return isInitialize;
  }
}

extension ExtensionBasicMessageChannel on BasicMessageChannel {
  Future<T?> invokeMethod<T>(String method, [dynamic arguments]) async {
    final result = await send({method: arguments});
    if (result is Map) {
      final state = result['state'] as int? ?? 0;
      if (state == 0) {
        return result['result'] as T;
      } else {
        return Future.error(FlutterError(result['result'].toString()));
      }
    }
    return null;
  }

  void setMethodCallHandler(
      Future<dynamic> Function(MethodCall call)? handler) {
    FlBasicMessageHandler? flBasicMessageHandler;
    if (handler != null) {
      flBasicMessageHandler = (message) async {
        if (message is Map) {
          dynamic result;
          await Future.forEach(message.entries, (entry) async {
            result = await handler(MethodCall(entry.key, entry.value));
          });
          return result;
        }
        return null;
      };
    }
    setMessageHandler(flBasicMessageHandler);
  }
}
