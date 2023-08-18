import Flutter
import Foundation

public class FlEvent: NSObject, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?
    private var eventChannel: FlutterEventChannel?

    static let shared = FlEvent()

    func initialize(_ messenger: FlutterBinaryMessenger) {
        eventChannel = FlutterEventChannel(name: "fl_channel/event", binaryMessenger: messenger)
        eventChannel!.setStreamHandler(self)
    }

    func send(arguments: Any?) {
        DispatchQueue.main.async {
            self.eventSink?(arguments)
        }
    }

    func dispose() {
        eventSink = nil
        eventChannel?.setStreamHandler(nil)
        eventChannel = nil
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
