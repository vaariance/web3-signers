#include "include/web3_signers/platform_authenticator_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "platform_authenticator_plugin.h"

void PlatformAuthenticatorPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  web3_signers::PlatformAuthenticatorPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
