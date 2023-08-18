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
        self.messenger = messenger
        self.channel = channel
        super.init()
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "startEvent":
            FlEvent.shared.initialize(messenger)
            result(true)
        case "sendEvent":
            FlEvent.shared.send(arguments: call.arguments)
            result(true)
        case "stopEvent":
            FlEvent.shared.dispose()
            result(true)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    public func detachFromEngine(for registrar: FlutterPluginRegistrar) {
        FlEvent.shared.dispose()
        channel.setMethodCallHandler(nil)
    }
}
