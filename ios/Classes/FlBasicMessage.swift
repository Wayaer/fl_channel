import Flutter
import Foundation

public class FlBasicMessage: NSObject {
    private var basicMessage: FlutterBasicMessageChannel?

    private var binaryMessenger: FlutterBinaryMessenger
    public var name: String

    func getName() -> String {
        return name
    }

    init(_ name: String, _ binaryMessenger: FlutterBinaryMessenger) {
        self.name = name
        self.binaryMessenger = binaryMessenger
        basicMessage = FlutterBasicMessageChannel(name: name, binaryMessenger: binaryMessenger)
        super.init()
    }

    public func reset() {
        if basicMessage == nil {
            basicMessage = FlutterBasicMessageChannel(name: name, binaryMessenger: binaryMessenger)
        }
    }

    public func setMessageHandler(handler: FlutterMessageHandler?) -> Bool {
        basicMessage?.setMessageHandler(handler)
        return basicMessage != nil
    }

    public func send(_ args: Any?, reply: FlutterReply? = nil) -> Bool {
        if basicMessage != nil {
            DispatchQueue.main.async {
                self.basicMessage!.sendMessage(args, reply: reply)
            }
        }
        return basicMessage != nil
    }

    public func dispose() {
        basicMessage?.setMessageHandler(nil)
        basicMessage = nil
    }

    public func invokeMethod(
        _ method: String, arguments: Any? = nil, result: FlutterResult? = nil
    ) -> Bool {
        send([method: arguments], reply: {
            reply in
            result?(reply)
        })
    }

    public func setMethodCallHandler(handler: FlutterMethodCallHandler? = nil) -> Bool {
        setMessageHandler { message, reply in
            if message is [String: Any] {
                let map = message as! [String: Any]
                for (key, value) in map {
                    handler?(FlutterMethodCall(methodName: key, arguments: value), { result in
                        var state = 0
                        if result as? NSObject == FlutterMethodNotImplemented {
                            state = 2
                        } else if result is FlutterError {
                            state = 1
                        }
                        reply(["state": state, "result": result])
                    })
                }
            }
        }
    }
}
