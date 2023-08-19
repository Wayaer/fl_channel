package fl.channel

import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel

object FlEvent {

    private var eventSink: EventChannel.EventSink? = null
    private var eventChannel: EventChannel? = null
    private val handler = Handler(Looper.getMainLooper())
    private lateinit var binaryMessenger: BinaryMessenger

    fun binding(binaryMessenger: BinaryMessenger) {
        this.binaryMessenger = binaryMessenger
    }

    fun initialize() {
        eventChannel = EventChannel(binaryMessenger, "fl_channel/event")
        eventChannel!!.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                eventSink = events
            }

            override fun onCancel(arguments: Any?) {
                dispose()
            }
        })
    }

    fun send(args: Any?) {
        eventSink.let {
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