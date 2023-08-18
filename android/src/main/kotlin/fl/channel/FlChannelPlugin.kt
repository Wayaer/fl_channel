package fl.channel


import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** FlChannelPlugin */
class FlChannelPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var pluginBinding: FlutterPlugin.FlutterPluginBinding

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        pluginBinding = binding
        channel = MethodChannel(binding.binaryMessenger, "fl_channel")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "startEvent" -> {
                FlEvent.initialize(pluginBinding.binaryMessenger)
                result.success(true)
            }

            "sendEvent" -> {
                FlEvent.send(call.arguments)
                result.success(true)
            }

            "stopEvent" -> {
                FlEvent.dispose()
                result.success(true)
            }

            "startBasicMessage" -> {
                FlBasicMessage.initialize(pluginBinding.binaryMessenger)
                result.success(true)
            }

            "basicMessageAddListener" -> {
                FlBasicMessage.addListener { message, reply ->
                    Log.d("BasicMessageListener==", "Received message：$message")
                    reply.reply("(Received message：$message),Reply from Android")
                }
                result.success(true)
            }

            "sendBasicMessage" -> {
                FlBasicMessage.send(call.arguments) { reply ->
                    FlBasicMessage.send("Received reply：($reply),from Android", null)
                }
                result.success(true)
            }

            "stopBasicMessage" -> {
                FlBasicMessage.dispose()
                result.success(true)
            }
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        FlEvent.dispose()
    }
}
