import Flutter
import UIKit

public class FlChannelPlugin: NSObject, FlutterPlugin {
    var channel: FlutterMethodChannel

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "fl_channel", binaryMessenger: registrar.messenger())
        let instance = FlChannelPlugin(registrar.messenger(), channel)
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public init(_ messenger: FlutterBinaryMessenger, _ channel: FlutterMethodChannel) {
        self.channel = channel
        super.init()
        FlEvent.shared.setBinaryMessenger(messenger)
        FlBasicMessage.shared.setBinaryMessenger(messenger)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "startEvent":
            FlEvent.shared.initialize()
            result(true)
        case "sendEvent":
            FlEvent.shared.send(call.arguments)
            result(true)
        case "stopEvent":
            FlEvent.shared.dispose()
            result(true)
        case "startBasicMessage":
            FlBasicMessage.shared.initialize()
            result(true)
        case "basicMessageAddListener":
            FlBasicMessage.shared.addListener {
                message, reply in
                print("BasicMessageListener==", "Received message：\(String(describing: message))")
                reply("(Received message：\(String(describing: message))),Reply from macos")
            }
            result(true)

        case "sendBasicMessage":
            FlBasicMessage.shared.send(call.arguments, reply: {
                reply in
                FlBasicMessage.shared.send("Received reply：(\(String(describing: reply))),from macos")
            })
            result(true)
        case "stopBasicMessage":
            FlBasicMessage.shared.dispose()
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
