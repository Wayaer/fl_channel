part of '../fl_channel.dart';

typedef FlBasicMessageHandler = Future<dynamic> Function(dynamic message);

class FlBasicMessage {
  factory FlBasicMessage() => _singleton ??= FlBasicMessage._();

  FlBasicMessage._();

  static FlBasicMessage? _singleton;

  /// 消息通道
  BasicMessageChannel<dynamic>? _messageChannel;

  BasicMessageChannel<dynamic>? get messageChannel => _messageChannel;

  /// 初始化消息通道
  Future<bool> initialize<T>() async {
    if (!_supportPlatform) return false;
    if (_messageChannel != null) return true;
    bool? state =
        await FlChannel()._channel.invokeMethod<bool?>('startBasicMessage');
    state ??= false;
    if (state && _messageChannel == null) {
      _messageChannel = const BasicMessageChannel(
          'fl_channel/basic_message', StandardMessageCodec());
    }
    return state && _messageChannel != null;
  }

  /// 添加消息监听
  bool addListener(FlBasicMessageHandler handler) {
    if (_supportPlatform && _messageChannel != null) {
      try {
        FlChannel()._channel.invokeMethod<bool?>('basicMessageAddListener');
        _messageChannel!.setMessageHandler(handler);
        return true;
      } catch (e) {
        debugPrint(e.toString());
      }
    }
    return false;
  }

  /// 向Native发送消息
  Future<dynamic> send(dynamic message) async {
    if (_supportPlatform && _messageChannel != null) {
      final result = await _messageChannel!.send(message);
      return result;
    }
    return null;
  }

  /// 向Native发送消息
  Future<bool> sendFromNative(dynamic message) async {
    if (_supportPlatform && _messageChannel != null) {
      try {
        final state = await FlChannel()
            ._channel
            .invokeMethod<bool?>('sendBasicMessage', message);
        return state ?? false;
      } catch (e) {
        debugPrint(e.toString());
      }
    }
    return false;
  }

  /// 销毁消息通道
  Future<bool> dispose() async {
    if (_supportPlatform && _messageChannel != null) {
      _messageChannel!.setMessageHandler(null);
      _messageChannel = null;
      final state =
          await FlChannel()._channel.invokeMethod<bool>('stopBasicMessage');
      return state ?? false;
    }
    return false;
  }
}
