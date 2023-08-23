package fl.channel


import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** FlChannelPlugin */
class FlChannelPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var plugin: FlutterPlugin.FlutterPluginBinding

    companion object {
        var flEvent: FlEvent? = null
        var flBasicMessage: FlBasicMessage? = null
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        plugin = binding
        channel = MethodChannel(binding.binaryMessenger, "fl_channel")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "initFlEvent" -> {
                val name = call.argument<String>("name")!!
                flEvent?.dispose()
                flEvent = null
                flEvent = FlEvent(plugin.binaryMessenger, name)
                result.success(true)
            }

            "sendFlEventFromNative" -> {
                val value = flEvent?.send(call.arguments)
                result.success(value)
            }

            "disposeFlEvent" -> {
                flEvent?.dispose()
                flEvent = null
                result.success(true)
            }

            "initFlBasicMessage" -> {
                val name = call.argument<String>("name")!!
                flBasicMessage?.dispose()
                flBasicMessage = null
                flBasicMessage = FlBasicMessage(plugin.binaryMessenger, name)
                result.success(true)
            }

            "setFlBasicMessageHandler" -> {
                val value = flBasicMessage?.setMessageHandler { message, reply ->
                    println("Native Received FlBasicMessage：$message")
                    reply.reply("(Received message：$message),Reply from Native")
                }
                result.success(value)
            }

            "sendFlBasicMessageFromNative" -> {
                val value = flBasicMessage?.send(call.arguments) { reply ->
                    flBasicMessage?.send("Native Received reply：($reply),from Native")
                }
                result.success(value)
            }

            "setFlBasicMethodCallHandler" -> {
                val value = flBasicMessage?.setMethodCallHandler { call, result ->
                    println("Native Received FlBasicMethodCall：${call.method} = ${call.arguments}")
                    result.success("(Received methodCall：${call.arguments}),Reply from Native")
                }
                result.success(value)
            }

            "sendFlBasicMethodCallFromNative" -> {
                val name = call.argument<String>("name")!!
                val arguments = call.argument<Any?>("arguments")
                val value = flBasicMessage?.invokeMethod(name, arguments, object : Result {
                    override fun success(result: Any?) {
                        println("(Native invokeMethod result: $result )")
                    }

                    override fun error(
                        errorCode: String, errorMessage: String?, errorDetails: Any?
                    ) {
                        println("(Native invokeMethod result error : $errorCode $errorMessage $errorDetails )")
                    }

                    override fun notImplemented() {
                        println("(Native invokeMethod result notImplemented")
                    }
                })
                result.success(value)
            }


            "disposeFlBasicMessage" -> {
                flBasicMessage?.dispose()
                flBasicMessage = null
                result.success(true)
            }
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        flEvent?.dispose()
        flEvent = null
        flBasicMessage?.dispose()
        flBasicMessage = null
    }


}
