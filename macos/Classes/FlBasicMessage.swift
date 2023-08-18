import FlutterMacOS
import Foundation

public class FlBasicMessage: NSObject {
    static let shared = FlBasicMessage()

    private var basicMessage: FlutterBasicMessageChannel?
    private var messenger: FlutterBinaryMessenger?

    func setBinaryMessenger(_ messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
    }

    func initialize() {
        basicMessage = FlutterBasicMessageChannel(name: "fl_channel/basic_message", binaryMessenger: messenger!)
    }

    func addListener(handler: FlutterMessageHandler?) {
        basicMessage?.setMessageHandler(handler)
    }

    func send(_ args: Any?, reply: FlutterReply? = nil) {
        if basicMessage != nil {
            DispatchQueue.main.async {
                self.basicMessage!.sendMessage(args, reply: reply)
            }
        }
    }

    func dispose() {
        basicMessage?.setMessageHandler(nil)
        basicMessage = nil
    }
}
