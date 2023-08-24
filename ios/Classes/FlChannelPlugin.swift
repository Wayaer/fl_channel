import Flutter
import UIKit

public class FlChannelPlugin: NSObject, FlutterPlugin {
    var channel: FlutterMethodChannel
    var messenger: FlutterBinaryMessenger
    var flEvent: FlEvent?

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

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initFlEvent":
            let name = (call.arguments as! [String: Any])["name"] as! String
            flEvent?.dispose()
            flEvent = nil
            flEvent = FlEvent(name, messenger)
            result(true)
        case "sendFlEventFromNative":
            let value = flEvent?.send(call.arguments)
            result(value ?? false)
        case "disposeFlEvent":
            flEvent?.dispose()
            flEvent = nil
            result(true)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    public func detachFromEngine(for registrar: FlutterPluginRegistrar) {
        flEvent?.dispose()
        channel.setMethodCallHandler(nil)
    }
}
