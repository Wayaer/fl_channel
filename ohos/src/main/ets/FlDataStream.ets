// 定义数据处理函数类型
type FlDataStreamHandler<T> = (data: T) => void;

// 定义取消监听函数类型
type FlDataStreamHandlerCancel = () => void;

// 自定义数据流管理器
export default class FlDataStream<T> {
  // 存储数据处理函数的列表
  private dataHandlers: FlDataStreamHandler<T>[] = [];

  // 发送数据到所有监听者，遍历期间允许监听器自行取消监听
  send(data: T): void {
    const handlers = this.dataHandlers.slice();
    for (const handler of handlers) {
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
    const index = this.dataHandlers.indexOf(handler);
    if (index >= 0) {
      this.dataHandlers.splice(index, 1);
    }
  }
}
