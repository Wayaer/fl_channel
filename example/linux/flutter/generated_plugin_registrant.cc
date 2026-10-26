//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <fl_channel/fl_channel_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) fl_channel_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "FlChannelPlugin");
  fl_channel_plugin_register_with_registrar(fl_channel_registrar);
}
