//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <passkeys_windows/passkeys_windows_plugin.h>
#include <web3_signers/platform_authenticator_plugin_c_api.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  PasskeysWindowsPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("PasskeysWindowsPlugin"));
  PlatformAuthenticatorPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("PlatformAuthenticatorPluginCApi"));
}
