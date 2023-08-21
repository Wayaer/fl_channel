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
                flEvent = FlEvent(name, plugin.binaryMessenger)
                result.success(true)
            }

            "sendFlEventFromNative" -> {
                flEvent?.send(call.arguments)
                result.success(flEvent != null)
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
                flBasicMessage = FlBasicMessage(name, plugin.binaryMessenger)
                result.success(true)
            }

            "addFlBasicMessageListenerForNative" -> {
                flBasicMessage?.setMessageHandler { message, reply ->
                    println("BasicMessageListener== Received message：$message")
                    reply.reply("(Received message：$message),Reply from Android")
                }
                result.success(true)
            }

            "sendFlBasicMessageFromNative" -> {
                flBasicMessage?.send(call.arguments) { reply ->
                    flBasicMessage?.send("Android Received reply：($reply),from Android")
                }
                result.success(true)
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
