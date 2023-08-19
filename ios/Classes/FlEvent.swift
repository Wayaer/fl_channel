import Flutter
import Foundation

public class FlEvent: NSObject, FlutterStreamHandler {
    
    private var eventSink: FlutterEventSink?
    private var eventChannel: FlutterEventChannel?
    private var messenger: FlutterBinaryMessenger?

    static public let shared = FlEvent()

    func binding(_ messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
    }

    public func initialize() {
        eventChannel = FlutterEventChannel(name: "fl_channel/event", binaryMessenger: messenger!)
        eventChannel!.setStreamHandler(self)
    }

    public func send(_ args: Any?) {
        DispatchQueue.main.async {
            self.eventSink?(args)
        }
    }

    public func dispose() {
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
