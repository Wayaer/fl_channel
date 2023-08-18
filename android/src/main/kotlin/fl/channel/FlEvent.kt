package fl.channel

import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel

object FlEvent : EventChannel.StreamHandler {

    private var eventSink: EventChannel.EventSink? = null
    private var eventChannel: EventChannel? = null
    private val handler = Handler(Looper.getMainLooper())

    fun initialize(binaryMessenger: BinaryMessenger) {
        eventChannel = EventChannel(binaryMessenger, "fl_channel/event")
        eventChannel!!.setStreamHandler(this)
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

    override fun onListen(arguments: Any?, event: EventChannel.EventSink?) {
        eventSink = event
    }

    override fun onCancel(arguments: Any?) {
        dispose()
    }
}