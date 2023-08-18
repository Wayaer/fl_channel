import FlutterMacOS
import Foundation

public class FlEvent: NSObject, FlutterStreamHandler {
    static let shared = FlEvent()

    private var eventSink: FlutterEventSink?
    private var channel: FlutterEventChannel?
    private var messenger: FlutterBinaryMessenger?

    func setBinaryMessenger(_ messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
    }

    func initialize() {
        channel = FlutterEventChannel(name: "fl_channel/event", binaryMessenger: messenger!)
        channel!.setStreamHandler(self)
    }

    func send(_ args: Any?) {
        DispatchQueue.main.async {
            self.eventSink?(args)
        }
    }

    func dispose() {
        eventSink = nil
        channel?.setStreamHandler(nil)
        channel = nil
    }

    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        dispose()
        return nil
    }
}
