#ifndef PLATFORM_AUTHENTICATOR_IMPL_H_
#define PLATFORM_AUTHENTICATOR_IMPL_H_

#include "runner/platform_authenticator.g.h"
#include <vector>
#include <string>
#include <functional>
#include <optional>

namespace web3_signers {

class PlatformAuthenticatorImpl {
 public:
  PlatformAuthenticatorImpl();
  virtual ~PlatformAuthenticatorImpl();

  // Create a key pair
  void CreateKey(
      const std::string& key_tag,
      const WindowsOptions& options,
      std::function<void(ErrorOr<std::vector<uint8_t>>)> result);

  // Delete a key
  void DeleteKey(
      const std::string& key_tag,
      std::function<void(std::optional<FlutterError>)> result);

  // Sign data
  void Sign(
      const std::string& key_tag,
      const std::vector<uint8_t>& data,
      const WindowsOptions& options,
      std::function<void(ErrorOr<std::vector<uint8_t>>)> result);

  // Get Public Key
  void GetPublicKey(
      const std::string& key_tag,
      std::function<void(ErrorOr<std::optional<std::vector<uint8_t>>>)> result);
};

} // namespace web3_signers

#endif // PLATFORM_AUTHENTICATOR_IMPL_H_
