import {
  BinaryMessenger,
  FlutterPlugin,
  FlutterPluginBinding,
  MethodCall,
  MethodCallHandler,
  MethodChannel,
  MethodResult,
} from '@ohos/flutter_ohos';
import FlEventChannel from './FlEventChannel';

export default class FlChannelPlugin implements FlutterPlugin, MethodCallHandler {
  private channel: MethodChannel | null = null;
  private messenger: BinaryMessenger | null = null;
  private static eventChannels: Map<string, FlEventChannel> = new Map();

  static getEventChannel(name: string): FlEventChannel | undefined {
    return FlChannelPlugin.eventChannels.get(name);
  }

  constructor() {
  }

  getUniqueClassName(): string {
    return 'FlChannelPlugin';
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    const messenger = binding.getBinaryMessenger();
    this.messenger = messenger;
    this.channel = new MethodChannel(messenger, 'fl_channel');
    this.channel.setMethodCallHandler(this);
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    if (this.channel != null) {
      this.channel.setMethodCallHandler(null);
    }
    this.channel = null;
    FlChannelPlugin.eventChannels.forEach((eventChannel: FlEventChannel) => {
      eventChannel.cancel();
    });
    FlChannelPlugin.eventChannels.clear();
    this.messenger = null;
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    switch (call.method) {
      case 'create': {
        const name = call.args as string;
        const messenger = this.messenger;
        if (messenger != null && !FlChannelPlugin.eventChannels.has(name)) {
          FlChannelPlugin.eventChannels.set(name, new FlEventChannel(name, messenger));
        }
        result.success(true);
        break;
      }
      case 'sendEventFromNative': {
        const name = call.argument('name') as string;
        const success = FlChannelPlugin.getEventChannel(name)?.send(call.argument('data')) ?? false;
        result.success(success);
        break;
      }
      case 'dispose': {
        const name = call.args as string;
        if (FlChannelPlugin.eventChannels.has(name)) {
          FlChannelPlugin.getEventChannel(name)?.cancel();
          FlChannelPlugin.eventChannels.delete(name);
        }
        result.success(true);
        break;
      }
      default:
        result.notImplemented();
        break;
    }
  }
}
