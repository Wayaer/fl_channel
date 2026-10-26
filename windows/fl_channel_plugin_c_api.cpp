#include "include/fl_channel/fl_channel_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "fl_channel_plugin.h"

void FlChannelPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  fl_channel::FlChannelPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
