part of '../fl_channel.dart';

typedef FlDataStreamHandler<T> = void Function(T);

class FlDataStream<T> {
  final List<FlDataStreamHandler<T>> _dataHandlers = [];

  // 发送数据
  void send(T data) {
    for (var handler in _dataHandlers) {
      handler(data);
    }
  }

  // 监听数据
  void Function() listen(FlDataStreamHandler<T> handler) {
    _dataHandlers.add(handler);
    return () => cancel(handler);
  }

  // 取消监听
  void cancel(FlDataStreamHandler<T> handler) {
    _dataHandlers.remove(handler);
  }
}
