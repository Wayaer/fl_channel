import Flutter
import Foundation

public class FlEventChannel: NSObject, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?
    private var eventChannel: FlutterEventChannel?
    private var binaryMessenger: FlutterBinaryMessenger

    public init(_ name: String, _ binaryMessenger: FlutterBinaryMessenger) {
        self.binaryMessenger = binaryMessenger
        eventChannel = FlutterEventChannel(name: name, binaryMessenger: binaryMessenger)
        super.init()
        setStreamHandler()
    }

    public func send(_ args: Any?) -> Bool {
        if eventSink != nil {
            DispatchQueue.main.async {
                self.eventSink?(args)
            }
        }
        return eventSink != nil && eventChannel != nil
    }

    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        cancel()
        return nil
    }

    func setStreamHandler() {
        eventChannel?.setStreamHandler(self)
    }

    public func cancel() {
        eventSink = nil
        eventChannel?.setStreamHandler(nil)
    }
}
