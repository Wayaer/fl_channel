import FlutterMacOS
import Foundation

public class FlEvent: NSObject, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?
    private var channel: FlutterEventChannel?

    static let shared = FlEvent()

    func initialize(_ messenger: FlutterBinaryMessenger) {
        channel = FlutterEventChannel(name: "fl_channel/event", binaryMessenger: messenger)
        channel!.setStreamHandler(self)
    }

    func send(arguments: Any?) {
        DispatchQueue.main.async {
            self.eventSink?(arguments)
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
