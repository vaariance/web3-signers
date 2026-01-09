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

namespace {

// ... existing helpers ...

} // namespace

// ... RegisterWithRegistrar ... 
// ... implementation ...

void PlatformAuthenticatorPlugin::Sign(
    const std::string& key_tag,
    const std::vector<uint8_t>& data,
    const WindowsOptions& options,
    std::function<void(ErrorOr<std::vector<uint8_t>> reply)> result) {
    
    ScopedNCryptHandle provider;
    SECURITY_STATUS status = OpenStorageProvider(provider, options.use_tpm());
    if (status != ERROR_SUCCESS) {
         result(FlutterError("PROVIDER_ERROR", HResultToString(status)));
         return;
    }

    ScopedNCryptHandle key;
    std::wstring key_name = StringToWString(key_tag);

    status = NCryptOpenKey(provider.get(), key.receive(), key_name.c_str(), 0, 0);
    if (status != ERROR_SUCCESS) {
         if (status == NTE_BAD_KEY) {
             result(FlutterError("KEY_NOT_FOUND", "Key not found"));
         } else {
             result(FlutterError("KEY_OPEN_FAILED", HResultToString(status)));
         }
         return;
    }

    // 1. Hash the data using SHA-256
    ScopedBCryptAlgHandle hash_alg;
    status = BCryptOpenAlgorithmProvider(hash_alg.receive(), BCRYPT_SHA256_ALGORITHM, NULL, 0);
    if (status != ERROR_SUCCESS) {
         result(FlutterError("HASH_ERROR", "Failed to open SHA256 provider"));
         return;
    }

    ScopedBCryptHashHandle hash_handle;
    status = BCryptCreateHash(hash_alg.get(), hash_handle.receive(), NULL, 0, NULL, 0, 0);
    if (status != ERROR_SUCCESS) {
         result(FlutterError("HASH_ERROR", "Failed to create hash"));
         return;
    }

    status = BCryptHashData(hash_handle.get(), (PUCHAR)data.data(), (ULONG)data.size(), 0);
    if (status != ERROR_SUCCESS) {
         result(FlutterError("HASH_ERROR", "Failed to hash data"));
         return;
    }

    std::vector<uint8_t> hash(32); // SHA-256 is 32 bytes
    status = BCryptFinishHash(hash_handle.get(), hash.data(), (ULONG)hash.size(), 0);
    if (status != ERROR_SUCCESS) {
         result(FlutterError("HASH_ERROR", "Failed to finish hash"));
         return;
    }

    // 2. Sign the hash
    DWORD signature_len = 0;
    status = NCryptSignHash(
        key.get(),
        NULL, 
        (PBYTE)hash.data(),
        (DWORD)hash.size(),
        NULL,
        0,
        &signature_len,
        0 
    );

    if (status != ERROR_SUCCESS) {
         result(FlutterError("SIGN_FAILED", HResultToString(status)));
         return;
    }

    std::vector<uint8_t> signature(signature_len);
    status = NCryptSignHash(
        key.get(),
        NULL,
        (PBYTE)hash.data(),
        (DWORD)hash.size(),
        signature.data(),
        signature_len,
        &signature_len,
        0
    );

    if (status != ERROR_SUCCESS) {
         result(FlutterError("SIGN_FAILED", HResultToString(status)));
         return;
    }

    // 3. Convert to ASN.1 DER (if needed)
    // NCryptSignHash returns P1363 (R|S). Swift/Android return ASN.1 DER.
    // We should normalize to DER.
    std::vector<uint8_t> der_signature = RawSignatureToDer(signature);
    if (der_signature.empty()) {
        result(FlutterError("SIGN_FAILED", "Failed to encode signature to DER"));
        return;
    }

    result(der_signature);
}

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
