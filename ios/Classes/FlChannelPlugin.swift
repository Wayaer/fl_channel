import Flutter
import UIKit

public class FlChannelPlugin: NSObject, FlutterPlugin {
    var channel: FlutterMethodChannel
    var messenger: FlutterBinaryMessenger
    var flEvent: FlEvent?
    var flBasicMessage: FlBasicMessage?

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
        case "initFlBasicMessage":
            let name = (call.arguments as! [String: Any])["name"] as! String
            flBasicMessage?.dispose()
            flBasicMessage = nil
            flBasicMessage = FlBasicMessage(name, messenger)
            result(true)
        case "setFlBasicMessageHandler":
            let value = flBasicMessage?.setMessageHandler {
                message, reply in
                print("BasicMessageListener==", "Received message：\(String(describing: message))")
                reply("(Received message：\(String(describing: message))),Reply from Native")
            }
            result(value ?? false)
        case "sendFlBasicMessageFromNative":
            let value = flBasicMessage?.send(call.arguments, reply: {
                reply in
                _ = self.flBasicMessage?.send("Native Received reply：(\(String(describing: reply))),from Native")
            })
            result(value ?? false)

        case "setFlBasicMethodCallHandler":
            let value = flBasicMessage?.setMethodCallHandler {
                call, result in
                print("Native Received FlBasicMethodCall：\(call.method) = \(String(describing: call.arguments))")
                result("(Received methodCall：\(String(describing: call.arguments))),Reply from Native")
            }
            result(value)
        case "sendFlBasicMethodCallFromNative":
            let args = call.arguments as! [String: Any]
            let name = args["name"] as! String
            let arguments = args["arguments"] as Any
            let value = flBasicMessage?.invokeMethod(name, arguments: arguments, result: { result in
                print("Native invokeMethod result: \(String(describing: result))")
            })
            result(value)
        case "disposeFlBasicMessage":
            flBasicMessage?.dispose()
            flBasicMessage = nil
            result(true)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    public func detachFromEngine(for registrar: FlutterPluginRegistrar) {
        flBasicMessage?.dispose()
        flEvent?.dispose()
        channel.setMethodCallHandler(nil)
    }
}
