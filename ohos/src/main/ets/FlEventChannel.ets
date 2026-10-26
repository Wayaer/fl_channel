import { Any, BinaryMessenger, EventChannel, EventSink, StreamHandler } from '@ohos/flutter_ohos';

// 事件通道实现类
export default class FlEventChannel {
  private eventSink: EventSink | null = null;
  private eventChannel: EventChannel;
  private streamHandler: StreamHandler = {
    onListen: (_args: Any, events: EventSink) => {
      this.eventSink = events;
    },
    onCancel: () => {
      this.cancel();
    }
  } as StreamHandler;

  constructor(name: string, messenger: BinaryMessenger) {
    this.eventChannel = new EventChannel(messenger, name);
    // 初始化时设置流处理器
    this.setStreamHandler();
  }

  public setStreamHandler(): void {
    this.eventChannel.setStreamHandler(this.streamHandler);
  }

  public cancel(): void {
    this.eventSink?.endOfStream();
    this.eventSink = null;
  }

  public send(args: Any): boolean {
    if (this.eventSink) {
      this.eventSink?.success(args);
      return true;
    }
    return false;
  }
}
