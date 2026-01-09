#ifndef FLUTTER_PLUGIN_PLATFORM_AUTHENTICATOR_PLUGIN_H_
#define FLUTTER_PLUGIN_PLATFORM_AUTHENTICATOR_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory> 

#include "runner/platform_authenticator.g.h"
#include "runner/platform_authenticator_impl.h"

namespace web3_signers {

class PlatformAuthenticatorPlugin : public flutter::Plugin, public PlatformAuthenticator {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  PlatformAuthenticatorPlugin();

  virtual ~PlatformAuthenticatorPlugin();

  // Disallow copy and assign.
  PlatformAuthenticatorPlugin(const PlatformAuthenticatorPlugin &) = delete;
  PlatformAuthenticatorPlugin &
  operator=(const PlatformAuthenticatorPlugin &) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

  // PlatformAuthenticator overrides
  void CreateKey(
    const std::string& key_tag,
    const WindowsOptions& options,
    std::function<void(ErrorOr<std::vector<uint8_t>> reply)> result) override;

  void DeleteKey(
    const std::string& key_tag,
    std::function<void(std::optional<FlutterError> reply)> result) override;

  void Sign(
    const std::string& key_tag,
    const std::vector<uint8_t>& data,
    const WindowsOptions& options,
    std::function<void(ErrorOr<std::vector<uint8_t>> reply)> result) override;

  void GetPublicKey(
    const std::string& key_tag,
    std::function<void(ErrorOr<std::optional<std::vector<uint8_t>>> reply)> result) override;

 private:
  std::unique_ptr<PlatformAuthenticatorImpl> authenticator_impl_;
};

} // namespace web3_signers

} // namespace web3_signers

#endif // FLUTTER_PLUGIN_PLATFORM_AUTHENTICATOR_PLUGIN_H_
