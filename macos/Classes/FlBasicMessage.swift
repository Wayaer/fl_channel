import FlutterMacOS
import Foundation

public class FlBasicMessage: NSObject {

    private var basicMessage: FlutterBasicMessageChannel?
    private var messenger: FlutterBinaryMessenger?

    static public let shared = FlBasicMessage()


    func setBinaryMessenger(_ messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
    }

    public func initialize() {
        basicMessage = FlutterBasicMessageChannel(name: "fl_channel/basic_message", binaryMessenger: messenger!)
    }

    public func addListener(handler: FlutterMessageHandler?) {
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
