package fl.channel

import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel

class FlEvent(
    messenger: BinaryMessenger, private val name: String
) {

    private var eventSink: EventChannel.EventSink? = null
    private var eventChannel: EventChannel = EventChannel(messenger, name)
    private val handler = Handler(Looper.getMainLooper())
    private var streamHandler = object : EventChannel.StreamHandler {
        override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
            eventSink = events
        }

        override fun onCancel(arguments: Any?) {
            eventSink?.endOfStream()
            eventSink = null
        }
    }

    fun getName(): String {
        return name
    }

    init {
        eventChannel.setStreamHandler(streamHandler)
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