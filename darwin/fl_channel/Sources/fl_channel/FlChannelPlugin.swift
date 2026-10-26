#if os(iOS)
import Flutter
#elseif os(macOS)
import FlutterMacOS
#endif
import Foundation

public class FlChannelPlugin: NSObject, FlutterPlugin {
    private let channel: FlutterMethodChannel
    private let messenger: FlutterBinaryMessenger

    public static func register(with registrar: FlutterPluginRegistrar) {
#if os(iOS)
        let messenger = registrar.messenger()
#elseif os(macOS)
        let messenger = registrar.messenger
#endif
        let channel = FlutterMethodChannel(name: "fl_channel", binaryMessenger: messenger)
        let instance = FlChannelPlugin(messenger, channel)
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public init(_ messenger: FlutterBinaryMessenger, _ channel: FlutterMethodChannel) {
        self.channel = channel
        self.messenger = messenger
        super.init()
    }

    private static var eventChannels: [String: FlEventChannel] = [:]

    public static func getEventChannel(_ name: String) -> FlEventChannel? {
        eventChannels[name]
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "create":
            guard let name = call.arguments as? String else {
                result(FlutterError(code: "invalid_argument", message: "Channel name must be a string.", details: nil))
                return
            }
            if FlChannelPlugin.eventChannels[name] == nil {
                FlChannelPlugin.eventChannels[name] = FlEventChannel(name, messenger)
            }
            result(true)
        case "sendEventFromNative":
            guard let args = call.arguments as? [String: Any], let name = args["name"] as? String else {
                result(FlutterError(code: "invalid_argument", message: "Channel name must be a string.", details: nil))
                return
            }
            result(FlChannelPlugin.getEventChannel(name)?.send(args["data"]) ?? false)
        case "dispose":
            if let name = call.arguments as? String {
                FlChannelPlugin.eventChannels[name]?.cancel()
                FlChannelPlugin.eventChannels.removeValue(forKey: name)
            }
            result(true)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    public func detachFromEngine(for registrar: FlutterPluginRegistrar) {
        channel.setMethodCallHandler(nil)
        for eventChannel in FlChannelPlugin.eventChannels.values {
            eventChannel.cancel()
        }
        FlChannelPlugin.eventChannels.removeAll()
    }
}
