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
        private var eventChannels: MutableMap<String, FlEventChannel> = mutableMapOf()
        fun getEventChannel(name: String): FlEventChannel? {
            return eventChannels[name]
        }
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        plugin = binding
        channel = MethodChannel(binding.binaryMessenger, "fl_channel")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "create" -> {
                val name = call.arguments as String
                if (!eventChannels.containsKey(name)) {
                    val eventChannel = FlEventChannel(name, plugin.binaryMessenger)
                    eventChannels[name] = eventChannel
                }
                result.success(true)
            }

            "sendEventFromNative" -> {
                val args = call.arguments as Map<*, *>
                val name = args["name"] as String;
                val data = args["data"] as Any;
                result.success(getEventChannel(name)?.send(data) ?: false)
            }

            "dispose" -> {
                val name = call.arguments as String
                if (eventChannels.containsKey(name)) {
                    getEventChannel(name)?.cancel()
                    eventChannels.remove(name)
                }
                result.success(true)
            }
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

}
