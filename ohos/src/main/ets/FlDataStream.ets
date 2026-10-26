// 定义数据处理函数类型
type FlDataStreamHandler<T> = (data: T) => void;

// 定义取消监听函数类型
type FlDataStreamHandlerCancel = () => void;

// 自定义数据流管理器
export default class FlDataStream<T> {
  // 存储数据处理函数的列表
  private dataHandlers: FlDataStreamHandler<T>[] = [];

  // 发送数据到所有监听者
  send(data: T): void {
    for (const handler of this.dataHandlers) {
      handler(data);
    }
  }

  // 监听数据并返回取消监听的函数
  listen(handler: FlDataStreamHandler<T>): FlDataStreamHandlerCancel {
    this.dataHandlers.push(handler);
    return () => this.cancel(handler);
  }

  // 取消特定的监听
  private cancel(handler: FlDataStreamHandler<T>): void {
    this.dataHandlers = this.dataHandlers.filter(h => h !== handler);
  }
}