#if os(iOS)
import Flutter
#elseif os(macOS)
import FlutterMacOS
#endif
import Foundation

public class FlEventChannel: NSObject, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?
    private let eventChannel: FlutterEventChannel

    public init(_ name: String, _ messenger: FlutterBinaryMessenger) {
        eventChannel = FlutterEventChannel(name: name, binaryMessenger: messenger)
        super.init()
        setStreamHandler()
    }

    public func send(_ data: Any?) -> Bool {
        guard let sink = eventSink else { return false }
        DispatchQueue.main.async {
            sink(data)
        }
        return true
    }

    public func onListen(
        withArguments arguments: Any?,
        eventSink events: @escaping FlutterEventSink
    ) -> FlutterError? {
        eventSink = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }

    public func setStreamHandler() {
        eventChannel.setStreamHandler(self)
    }

    public func cancel() {
        eventSink?(FlutterEndOfEventStream)
        eventSink = nil
        eventChannel.setStreamHandler(nil)
    }
}
