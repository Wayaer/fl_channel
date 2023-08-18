import FlutterMacOS
import Foundation

public class FlEvent: NSObject, FlutterStreamHandler {

    private var eventSink: FlutterEventSink?
    private var channel: FlutterEventChannel?
    private var messenger: FlutterBinaryMessenger?

    static public let shared = FlEvent()

    func setBinaryMessenger(_ messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
    }

    public func initialize() {
        channel = FlutterEventChannel(name: "fl_channel/event", binaryMessenger: messenger!)
        channel!.setStreamHandler(self)
    }

    public func send(_ args: Any?) {
        DispatchQueue.main.async {
            self.eventSink?(args)
        }
    }

    public func dispose() {
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
