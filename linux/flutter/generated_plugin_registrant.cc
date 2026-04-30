//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <dart_iztro/dart_iztro_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) dart_iztro_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "DartIztroPlugin");
  dart_iztro_plugin_register_with_registrar(dart_iztro_registrar);
}
