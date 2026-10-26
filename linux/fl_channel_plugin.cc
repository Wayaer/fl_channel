#include "include/fl_channel/fl_channel_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <glib-object.h>

#include <cstring>

#define FL_CHANNEL_PLUGIN(obj)                    \
  (G_TYPE_CHECK_INSTANCE_CAST((obj),              \
                              fl_channel_plugin_get_type(), FlChannelPlugin))

typedef struct {
  FlEventChannel* channel;
  gboolean listening;
} FlChannelEntry;

struct _FlChannelPlugin {
  GObject parent_instance;

  FlBinaryMessenger* messenger;
  GHashTable* channels;
};

G_DEFINE_TYPE(FlChannelPlugin, fl_channel_plugin, G_TYPE_OBJECT)

static void fl_channel_entry_free(gpointer data) {
  FlChannelEntry* entry = static_cast<FlChannelEntry*>(data);
  if (entry->channel != nullptr) {
    if (entry->listening) {
      fl_event_channel_send_end_of_stream(entry->channel, nullptr, nullptr);
    }
    fl_event_channel_set_stream_handlers(entry->channel, nullptr, nullptr,
                                         nullptr, nullptr);
    g_object_unref(entry->channel);
  }
  g_free(entry);
}

static FlMethodErrorResponse* fl_channel_listen_cb(FlEventChannel* /*channel*/,
                                                   FlValue* /*args*/,
                                                   gpointer user_data) {
  static_cast<FlChannelEntry*>(user_data)->listening = TRUE;
  return nullptr;
}

static FlMethodErrorResponse* fl_channel_cancel_cb(FlEventChannel* /*channel*/,
                                                   FlValue* /*args*/,
                                                   gpointer user_data) {
  static_cast<FlChannelEntry*>(user_data)->listening = FALSE;
  return nullptr;
}

static void fl_channel_plugin_dispose(GObject* object) {
  FlChannelPlugin* self = FL_CHANNEL_PLUGIN(object);

  if (self->channels != nullptr) {
    g_hash_table_destroy(self->channels);
    self->channels = nullptr;
  }
  g_clear_object(&self->messenger);

  G_OBJECT_CLASS(fl_channel_plugin_parent_class)->dispose(object);
}

static void fl_channel_plugin_class_init(FlChannelPluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = fl_channel_plugin_dispose;
}

static void fl_channel_plugin_init(FlChannelPlugin* self) {
  self->channels = g_hash_table_new_full(g_str_hash, g_str_equal, g_free,
                                         fl_channel_entry_free);
}

static FlMethodResponse* fl_channel_success_response(gboolean value) {
  g_autoptr(FlValue) result = fl_value_new_bool(value);
  return FL_METHOD_RESPONSE(fl_method_success_response_new(result));
}

static void fl_channel_plugin_handle_method_call(
    FlChannelPlugin* self,
    FlMethodCall* method_call) {
  const gchar* method = fl_method_call_get_name(method_call);
  FlValue* args = fl_method_call_get_args(method_call);
  g_autoptr(FlMethodResponse) response = nullptr;

  if (strcmp(method, "create") == 0) {
    const gchar* name = args != nullptr &&
                                fl_value_get_type(args) == FL_VALUE_TYPE_STRING
                            ? fl_value_get_string(args)
                            : nullptr;
    if (name == nullptr || self->messenger == nullptr) {
      response = fl_channel_success_response(FALSE);
    } else {
      if (!g_hash_table_contains(self->channels, name)) {
        g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
        FlEventChannel* event_channel = fl_event_channel_new(
            self->messenger, name, FL_METHOD_CODEC(codec));

        FlChannelEntry* entry = g_new0(FlChannelEntry, 1);
        entry->channel = event_channel;
        entry->listening = FALSE;
        fl_event_channel_set_stream_handlers(event_channel, fl_channel_listen_cb,
                                             fl_channel_cancel_cb, entry,
                                             nullptr);
        g_hash_table_insert(self->channels, g_strdup(name), entry);
      }
      response = fl_channel_success_response(TRUE);
    }
  } else if (strcmp(method, "sendEventFromNative") == 0) {
    gboolean success = FALSE;
    if (args != nullptr && fl_value_get_type(args) == FL_VALUE_TYPE_MAP) {
      FlValue* name_value = fl_value_lookup_string(args, "name");
      FlValue* data_value = fl_value_lookup_string(args, "data");
      if (name_value != nullptr && data_value != nullptr &&
          fl_value_get_type(name_value) == FL_VALUE_TYPE_STRING) {
        FlChannelEntry* entry = static_cast<FlChannelEntry*>(
            g_hash_table_lookup(self->channels,
                                fl_value_get_string(name_value)));
        if (entry != nullptr && entry->listening) {
          g_autoptr(GError) error = nullptr;
          success = fl_event_channel_send(entry->channel, data_value, nullptr,
                                          &error);
          if (!success && error != nullptr) {
            g_warning("Failed to send event on channel %s: %s",
                      fl_value_get_string(name_value), error->message);
          }
        }
      }
    }
    response = fl_channel_success_response(success);
  } else if (strcmp(method, "dispose") == 0) {
    if (args != nullptr && fl_value_get_type(args) == FL_VALUE_TYPE_STRING) {
      g_hash_table_remove(self->channels, fl_value_get_string(args));
    }
    response = fl_channel_success_response(TRUE);
  } else {
    response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
  }

  fl_method_call_respond(method_call, response, nullptr);
}

static void method_call_cb(FlMethodChannel* /*channel*/,
                           FlMethodCall* method_call,
                           gpointer user_data) {
  FlChannelPlugin* plugin = FL_CHANNEL_PLUGIN(user_data);
  fl_channel_plugin_handle_method_call(plugin, method_call);
}

void fl_channel_plugin_register_with_registrar(FlPluginRegistrar* registrar) {
  FlChannelPlugin* plugin = FL_CHANNEL_PLUGIN(
      g_object_new(fl_channel_plugin_get_type(), nullptr));
  plugin->messenger = FL_BINARY_MESSENGER(
      g_object_ref(fl_plugin_registrar_get_messenger(registrar)));

  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  g_autoptr(FlMethodChannel) channel = fl_method_channel_new(
      fl_plugin_registrar_get_messenger(registrar), "fl_channel",
      FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(channel, method_call_cb,
                                            g_object_ref(plugin),
                                            g_object_unref);

  g_object_unref(plugin);
}
