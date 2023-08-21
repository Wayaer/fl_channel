package fl.channel

import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel

class FlEvent(private val name: String, private val binaryMessenger: BinaryMessenger) {

    private var eventSink: EventChannel.EventSink? = null
    private var eventChannel: EventChannel?
    private val handler = Handler(Looper.getMainLooper())
    fun getName(): String {
        return name
    }

    private var streamHandler = object : EventChannel.StreamHandler {
        override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
            eventSink = events
        }

        override fun onCancel(arguments: Any?) {
            dispose()
        }
    }

    init {
        eventChannel = EventChannel(binaryMessenger, name)
        eventChannel!!.setStreamHandler(streamHandler)
    }


    fun reset() {
        if (eventChannel == null) {
            eventChannel = EventChannel(binaryMessenger, name)
            eventChannel!!.setStreamHandler(streamHandler)
        }
    }


    fun send(args: Any) {
        eventSink?.let {
            handler.post {
                eventSink!!.success(args)
            }
        }
    }

    fun dispose() {
        eventSink?.endOfStream()
        eventSink = null
        eventChannel?.setStreamHandler(null)
        eventChannel = null
    }

}