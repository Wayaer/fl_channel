package fl.channel

import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.BasicMessageChannel
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec

class FlBasicMessage(private val name: String, private val binaryMessenger: BinaryMessenger) {
    private var basicMessage: BasicMessageChannel<Any>? = null
    private val handler = Handler(Looper.getMainLooper())

    fun getName(): String {
        return name
    }

    init {
        basicMessage = BasicMessageChannel(binaryMessenger, name, StandardMessageCodec.INSTANCE)
    }

    fun setMessageHandler(handler: BasicMessageChannel.MessageHandler<Any>? = null) {
        basicMessage?.setMessageHandler(handler)
    }

    fun reset() {
        if (basicMessage == null) {
            basicMessage = BasicMessageChannel(binaryMessenger, name, StandardMessageCodec.INSTANCE)
        }
    }

    fun send(args: Any, callback: BasicMessageChannel.Reply<Any>? = null) {
        if (basicMessage != null) {
            handler.post {
                basicMessage!!.send(args, callback)
            }
        }
    }

    fun dispose() {
        basicMessage?.setMessageHandler(null)
        basicMessage = null
    }

    fun setMethodCallHandler(handler: MethodChannel.MethodCallHandler? = null) {
        basicMessage?.setMessageHandler { message, reply ->
            if (message !is MutableMap<*, *>) return@setMessageHandler
            message.keys.forEach {
                handler?.onMethodCall(
                    MethodCall(it.toString(), message[it]),
                    object : MethodChannel.Result {
                        override fun success(result: Any?) {
                            reply.reply(mapOf("success" to result))
                        }

                        override fun error(
                            errorCode: String, errorMessage: String?, errorDetails: Any?
                        ) {
                            reply.reply(
                                mapOf(
                                    "error" to mapOf(
                                        "errorCode" to errorCode,
                                        "errorMessage" to errorMessage,
                                        "errorDetails" to errorDetails,
                                    )
                                )
                            )
                        }

                        override fun notImplemented() {
                            reply.reply(
                                mapOf("notImplemented" to null)
                            )
                        }
                    })
            }
        }
    }

}