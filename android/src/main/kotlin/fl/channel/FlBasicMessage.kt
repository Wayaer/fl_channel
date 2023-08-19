package fl.channel

import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.BasicMessageChannel
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.StandardMessageCodec

object FlBasicMessage {
    private var basicMessage: BasicMessageChannel<Any>? = null
    private val handler = Handler(Looper.getMainLooper())
    private lateinit var binaryMessenger: BinaryMessenger

    fun binding(binaryMessenger: BinaryMessenger) {
        this.binaryMessenger = binaryMessenger
    }

    fun initialize() {
        basicMessage = BasicMessageChannel(
            binaryMessenger, "fl_channel/basic_message", StandardMessageCodec.INSTANCE
        )
    }

    fun addListener(handler: BasicMessageChannel.MessageHandler<Any>? = null) {
        basicMessage.let {
            basicMessage!!.setMessageHandler(handler)
        }
    }

    fun send(args: Any, callback: BasicMessageChannel.Reply<Any>? = null) {
        basicMessage.let {
            handler.post {
                basicMessage!!.send(args, callback)
            }
        }
    }

    fun dispose() {
        basicMessage?.setMessageHandler(null)
        basicMessage = null
    }
}