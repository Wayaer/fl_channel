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
                if (flEvent == null) {
                    flEvent = FlEvent(name, plugin.binaryMessenger)
                }
                result.success(true)
            }

            "sendFlEventFromNative" -> {
                val value = flEvent?.send(call.arguments)
                result.success(value)
            }

            "disposeFlEvent" -> {
                flEvent?.cancel()
                flEvent = null
                result.success(true)
            }
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        flEvent = null
    }

}
