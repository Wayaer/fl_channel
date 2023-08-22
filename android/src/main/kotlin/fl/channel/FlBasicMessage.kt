package fl.channel

import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.BasicMessageChannel
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.FlutterException
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

    fun setMessageHandler(handler: BasicMessageChannel.MessageHandler<Any>? = null): Boolean {
        basicMessage?.setMessageHandler(handler)
        return basicMessage != null
    }

    fun reset() {
        if (basicMessage == null) {
            basicMessage = BasicMessageChannel(binaryMessenger, name, StandardMessageCodec.INSTANCE)
        }
    }

    fun send(args: Any, callback: BasicMessageChannel.Reply<Any>? = null): Boolean {
        if (basicMessage != null) {
            handler.post {
                basicMessage!!.send(args, callback)
            }
        }
        return basicMessage != null
    }

    fun dispose() {
        basicMessage?.setMessageHandler(null)
        basicMessage = null
    }


    fun invokeMethod(
        method: String, arguments: Any? = null, callback: MethodChannel.Result? = null
    ): Boolean {
        send(
            mapOf(method to arguments),
            if (callback == null) null else IncomingResultHandler(callback)
        )
        return basicMessage != null
    }

    private class IncomingResultHandler<T>(private val callback: MethodChannel.Result) :
        BasicMessageChannel.Reply<T> {
        override fun reply(reply: T?) {
            if (reply == null) {
                callback.notImplemented()
            } else {
                try {
                    callback.success(reply)
                } catch (e: FlutterException) {
                    callback.error(e.code, e.message, e.details)
                }
            }
        }
    }

    fun setMethodCallHandler(handler: MethodChannel.MethodCallHandler? = null): Boolean {
        basicMessage?.setMessageHandler { message, reply ->
            if (message !is MutableMap<*, *>) return@setMessageHandler
            message.keys.forEach {
                handler?.onMethodCall(MethodCall(it.toString(), message[it]),
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
        return basicMessage != null
    }

}

