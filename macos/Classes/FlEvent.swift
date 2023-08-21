import FlutterMacOS
import Foundation

public class FlEvent: NSObject, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?
    private var eventChannel: FlutterEventChannel?

    private var binaryMessenger: FlutterBinaryMessenger
    public var name: String

    func getName() -> String {
        return name
    }

    init(_ name: String, _ binaryMessenger: FlutterBinaryMessenger) {
        self.name = name
        self.binaryMessenger = binaryMessenger
        eventChannel = FlutterEventChannel(name: name, binaryMessenger: binaryMessenger)
        super.init()
        eventChannel!.setStreamHandler(self)
    }

    public func reset() {
        if eventChannel == nil {
            eventChannel = FlutterEventChannel(name: name, binaryMessenger: binaryMessenger)
            eventChannel!.setStreamHandler(self)
        }
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
