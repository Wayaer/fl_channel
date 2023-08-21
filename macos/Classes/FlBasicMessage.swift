import FlutterMacOS
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

    public func setMessageHandler(handler: FlutterMessageHandler?) {
        basicMessage?.setMessageHandler(handler)
    }

    public func send(_ args: Any?, reply: FlutterReply? = nil) {
        if basicMessage != nil {
            DispatchQueue.main.async {
                self.basicMessage!.sendMessage(args, reply: reply)
            }
        }
    }

    public func dispose() {
        basicMessage?.setMessageHandler(nil)
        basicMessage = nil
    }
}
