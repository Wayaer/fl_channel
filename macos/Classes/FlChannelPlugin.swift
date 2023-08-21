import Cocoa
import FlutterMacOS

public class FlChannelPlugin: NSObject, FlutterPlugin {
    var channel: FlutterMethodChannel
    var messenger: FlutterBinaryMessenger
    var flEvent: FlEvent?
    var flBasicMessage: FlBasicMessage?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "fl_channel", binaryMessenger: registrar.messenger())
        let instance = FlChannelPlugin(registrar.messenger, channel)
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
            flEvent?.send(call.arguments)
            result(flEvent != nil)
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
        case "addFlBasicMessageListenerForNative":
            flBasicMessage?.setMessageHandler {
                message, reply in
                print("BasicMessageListener==", "Received message：\(String(describing: message))")
                reply("(Received message：\(String(describing: message))),Reply from macos")
            }
            result(true)

        case "sendFlBasicMessageFromNative":
            flBasicMessage?.send(call.arguments, reply: {
                reply in
                self.flBasicMessage?.send("Macos Received reply：(\(String(describing: reply))),from macos")
            })
            result(true)
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
