#include "platform_authenticator_plugin.h"

#include <windows.h>
#include <VersionHelpers.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <memory>
#include <sstream>
#include <vector>
#include <string>

namespace web3_signers {



// static
void PlatformAuthenticatorPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows *registrar) {
  auto channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), "web3_signers",
          &flutter::StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<PlatformAuthenticatorPlugin>();

  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto &call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });
  
  // Setup Pigeon API
  PlatformAuthenticator::SetUp(registrar->messenger(), plugin.get());

  registrar->AddPlugin(std::move(plugin));
}

PlatformAuthenticatorPlugin::PlatformAuthenticatorPlugin() 
    : authenticator_impl_(std::make_unique<PlatformAuthenticatorImpl>()) {}

PlatformAuthenticatorPlugin::~PlatformAuthenticatorPlugin() {}

void PlatformAuthenticatorPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  if (method_call.method_name().compare("getPlatformVersion") == 0) {
    std::ostringstream version_stream;
    version_stream << "Windows ";
    if (IsWindows10OrGreater()) {
      version_stream << "10+";
    } else if (IsWindows8OrGreater()) {
      version_stream << "8";
    } else if (IsWindows7OrGreater()) {
      version_stream << "7";
    }
    result->Success(flutter::EncodableValue(version_stream.str()));
  } else {
    result->NotImplemented();
  }
}

void PlatformAuthenticatorPlugin::CreateKey(
    const std::string& key_tag,
    const WindowsOptions& options,
    std::function<void(ErrorOr<std::vector<uint8_t>> reply)> result) {
    authenticator_impl_->CreateKey(key_tag, options, result);
}

void PlatformAuthenticatorPlugin::DeleteKey(
    const std::string& key_tag,
    std::function<void(std::optional<FlutterError> reply)> result) {
    authenticator_impl_->DeleteKey(key_tag, result);
}

void PlatformAuthenticatorPlugin::Sign(
    const std::string& key_tag,
    const std::vector<uint8_t>& data,
    const WindowsOptions& options,
    std::function<void(ErrorOr<std::vector<uint8_t>> reply)> result) {
    authenticator_impl_->Sign(key_tag, data, options, result);
}

void PlatformAuthenticatorPlugin::GetPublicKey(
    const std::string& key_tag,
    std::function<void(ErrorOr<std::optional<std::vector<uint8_t>>> reply)> result) {
    authenticator_impl_->GetPublicKey(key_tag, result);
}

} // namespace web3_signers
