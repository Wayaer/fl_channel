import Flutter
import UIKit

public class FlChannelPlugin: NSObject, FlutterPlugin {
    var channel: FlutterMethodChannel
    var messenger: FlutterBinaryMessenger

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "fl_channel", binaryMessenger: registrar.messenger())
        let instance = FlChannelPlugin(registrar.messenger(), channel)
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public init(_ messenger: FlutterBinaryMessenger, _ channel: FlutterMethodChannel) {
        self.channel = channel
        self.messenger = messenger
        super.init()
    }

    private static var eventChannels: [String: FlEventChannel] = [:]

    public static func getEventChannel(name: String) -> FlEventChannel? {
        if eventChannels.keys.contains(name) {
            return eventChannels[name]
        }
        return nil
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "create":
            var name = call.arguments as! String
            if !FlChannelPlugin.eventChannels.keys.contains(name) {
                var eventChannel = FlEventChannel(name, messenger)
                FlChannelPlugin.eventChannels[name] = eventChannel
            }
            result(true)
        case "sendEventFromNative":
            var args = call.arguments as! [String: Any]
            var name = args["name"] as! String
            var data = args["data"]
            var state = FlChannelPlugin.getEventChannel(name: name)?.send(data)
            result(state ?? false)
        case "dispose":
            var name = call.arguments as! String
            if FlChannelPlugin.eventChannels.keys.contains(name) {
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
    }
}
