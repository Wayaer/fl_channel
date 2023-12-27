package fl.channel

import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel

class FlEvent(
    name: String, messenger: BinaryMessenger,
) {
    private var eventSink: EventChannel.EventSink? = null
    private var eventChannel: EventChannel = EventChannel(messenger, name)
    private val handler = Handler(Looper.getMainLooper())
    private val streamHandler = object : EventChannel.StreamHandler {
        override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
            eventSink = events
        }

        override fun onCancel(arguments: Any?) {
            cancel()
        }
    }

    init {
        setStreamHandler()
    }

    fun setStreamHandler() {
        eventChannel.setStreamHandler(streamHandler)
    }

    fun cancel() {
        eventSink?.endOfStream()
        eventSink = null
        eventChannel.setStreamHandler(null)
    }


    fun send(args: Any): Boolean {
        if (eventSink != null) {
            handler.post {
                eventSink?.success(args)
            }
        }
        return eventSink != null
    }

}