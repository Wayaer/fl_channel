package fl.channel

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** FlChannelPlugin */
class FlChannelPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var binding: FlutterPlugin.FlutterPluginBinding

    companion object {
        private val eventChannels: MutableMap<String, FlEventChannel> = mutableMapOf()

        @JvmStatic
        fun getEventChannel(name: String): FlEventChannel? = eventChannels[name]
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        this.binding = binding
        channel = MethodChannel(binding.binaryMessenger, "fl_channel")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "create" -> {
                val name = call.arguments as? String
                if (name == null) {
                    result.error("invalid_argument", "Channel name must be a string.", null)
                    return
                }
                if (!eventChannels.containsKey(name)) {
                    eventChannels[name] = FlEventChannel(name, binding.binaryMessenger)
                }
                result.success(true)
            }

            "sendEventFromNative" -> {
                val args = call.arguments as? Map<*, *>
                val name = args?.get("name") as? String
                if (name == null) {
                    result.error("invalid_argument", "Channel name must be a string.", null)
                    return
                }
                result.success(getEventChannel(name)?.send(args["data"]) ?: false)
            }

            "dispose" -> {
                val name = call.arguments as? String
                if (name != null) {
                    getEventChannel(name)?.cancel()
                    eventChannels.remove(name)
                }
                result.success(true)
            }

            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        eventChannels.values.forEach { it.cancel() }
        eventChannels.clear()
    }
}
