#ifndef FLUTTER_PLUGIN_FL_CHANNEL_PLUGIN_H_
#define FLUTTER_PLUGIN_FL_CHANNEL_PLUGIN_H_

#include <flutter/binary_messenger.h>
#include <flutter/encodable_value.h>
#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <map>
#include <memory>
#include <string>

namespace fl_channel {

class FlChannelPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows* registrar);

  explicit FlChannelPlugin(flutter::BinaryMessenger* messenger);

  ~FlChannelPlugin() override;

  // Disallow copy and assign.
  FlChannelPlugin(const FlChannelPlugin&) = delete;
  FlChannelPlugin& operator=(const FlChannelPlugin&) = delete;

  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue>& method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

 private:
  struct ChannelEntry;

  flutter::BinaryMessenger* messenger_;
  std::map<std::string, std::unique_ptr<ChannelEntry>> channels_;
};

}  // namespace fl_channel

#endif  // FLUTTER_PLUGIN_FL_CHANNEL_PLUGIN_H_
