#include "fl_channel_plugin.h"

#include <flutter/encodable_value.h>
#include <flutter/event_channel.h>
#include <flutter/event_sink.h>
#include <flutter/event_stream_handler.h>
#include <flutter/standard_method_codec.h>

#include <memory>
#include <string>
#include <utility>

namespace fl_channel {
namespace {

using FlEventChannel = flutter::EventChannel<flutter::EncodableValue>;
using FlEventSink = flutter::EventSink<flutter::EncodableValue>;
using FlStreamHandlerError = flutter::StreamHandlerError<flutter::EncodableValue>;

class FlEventChannelStreamHandler
    : public flutter::StreamHandler<flutter::EncodableValue> {
 public:
  FlEventChannelStreamHandler() = default;

  ~FlEventChannelStreamHandler() override = default;

  bool Send(const flutter::EncodableValue& data) {
    if (sink_ == nullptr) {
      return false;
    }
    sink_->Success(data);
    return true;
  }

 protected:
  std::unique_ptr<FlStreamHandlerError> OnListenInternal(
      const flutter::EncodableValue* arguments,
      std::unique_ptr<FlEventSink>&& events) override {
    sink_ = std::move(events);
    return nullptr;
  }

  std::unique_ptr<FlStreamHandlerError> OnCancelInternal(
      const flutter::EncodableValue* arguments) override {
    sink_.reset();
    return nullptr;
  }

 private:
  std::unique_ptr<FlEventSink> sink_;
};

}  // namespace

struct FlChannelPlugin::ChannelEntry {
  ~ChannelEntry() {
    if (channel != nullptr) {
      channel->SetStreamHandler(nullptr);
    }
  }

  std::unique_ptr<FlEventChannel> channel;
  FlEventChannelStreamHandler* handler = nullptr;
};

// static
void FlChannelPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows* registrar) {
  auto plugin = std::make_unique<FlChannelPlugin>(registrar->messenger());

  auto method_channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), "fl_channel",
          &flutter::StandardMethodCodec::GetInstance());

  method_channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto& call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  registrar->AddPlugin(std::move(plugin));
}

FlChannelPlugin::FlChannelPlugin(flutter::BinaryMessenger* messenger)
    : messenger_(messenger) {}

FlChannelPlugin::~FlChannelPlugin() = default;

void FlChannelPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  const std::string& method = method_call.method_name();

  if (method == "create") {
    const auto* name = std::get_if<std::string>(method_call.arguments());
    if (name == nullptr || messenger_ == nullptr) {
      result->Error("invalid_argument", "Channel name must be a string.");
      return;
    }
    if (channels_.find(*name) == channels_.end()) {
      auto handler = std::make_unique<FlEventChannelStreamHandler>();
      FlEventChannelStreamHandler* handler_pointer = handler.get();

      auto channel = std::make_unique<FlEventChannel>(
          messenger_, *name, &flutter::StandardMethodCodec::GetInstance());
      channel->SetStreamHandler(std::move(handler));

      auto entry = std::make_unique<ChannelEntry>();
      entry->channel = std::move(channel);
      entry->handler = handler_pointer;
      channels_[*name] = std::move(entry);
    }
    result->Success(flutter::EncodableValue(true));
    return;
  }

  if (method == "sendEventFromNative") {
    const auto* arguments =
        std::get_if<flutter::EncodableMap>(method_call.arguments());
    if (arguments == nullptr) {
      result->Success(flutter::EncodableValue(false));
      return;
    }

    const auto name_iterator =
        arguments->find(flutter::EncodableValue("name"));
    const auto data_iterator =
        arguments->find(flutter::EncodableValue("data"));
    if (name_iterator == arguments->end() ||
        data_iterator == arguments->end()) {
      result->Success(flutter::EncodableValue(false));
      return;
    }

    const auto* name = std::get_if<std::string>(&name_iterator->second);
    if (name == nullptr) {
      result->Success(flutter::EncodableValue(false));
      return;
    }

    const auto channel_iterator = channels_.find(*name);
    if (channel_iterator == channels_.end() ||
        channel_iterator->second->handler == nullptr) {
      result->Success(flutter::EncodableValue(false));
      return;
    }

    const bool sent = channel_iterator->second->handler->Send(
        data_iterator->second);
    result->Success(flutter::EncodableValue(sent));
    return;
  }

  if (method == "dispose") {
    const auto* name = std::get_if<std::string>(method_call.arguments());
    if (name != nullptr) {
      channels_.erase(*name);
    }
    result->Success(flutter::EncodableValue(true));
    return;
  }

  result->NotImplemented();
}

}  // namespace fl_channel
