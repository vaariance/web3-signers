#include "runner/platform_authenticator_impl.h"
#include "web3_signers/platform_authenticator_errors.h"

#include <windows.h>
#include <ncrypt.h>
#include <bcrypt.h>
#include <string>
#include <vector>
#include <sstream>

#pragma comment(lib, "ncrypt.lib")
#pragma comment(lib, "bcrypt.lib")

namespace web3_signers {

namespace {

// RAII wrappers
class ScopedNCryptHandle {
 public:
  explicit ScopedNCryptHandle(NCRYPT_HANDLE handle = 0) : handle_(handle) {}
  ~ScopedNCryptHandle() {
    if (handle_) NCryptFreeObject(handle_);
  }
  NCRYPT_HANDLE get() const { return handle_; }
  NCRYPT_HANDLE* receive() { 
    if (handle_) {
        NCryptFreeObject(handle_);
        handle_ = 0;
    }
    return &handle_; 
  }
  NCRYPT_HANDLE release() {
    NCRYPT_HANDLE temp = handle_;
    handle_ = 0;
    return temp;
  }
 private:
  NCRYPT_HANDLE handle_;
  ScopedNCryptHandle(const ScopedNCryptHandle&) = delete;
  ScopedNCryptHandle& operator=(const ScopedNCryptHandle&) = delete;
};

class ScopedBCryptAlgHandle {
 public:
  explicit ScopedBCryptAlgHandle(BCRYPT_ALG_HANDLE handle = 0) : handle_(handle) {}
  ~ScopedBCryptAlgHandle() {
    if (handle_) BCryptCloseAlgorithmProvider(handle_, 0);
  }
  BCRYPT_ALG_HANDLE* receive() { return &handle_; }
  BCRYPT_ALG_HANDLE get() const { return handle_; }
 private:
  BCRYPT_ALG_HANDLE handle_;
};

class ScopedBCryptHashHandle {
 public:
  explicit ScopedBCryptHashHandle(BCRYPT_HASH_HANDLE handle = 0) : handle_(handle) {}
  ~ScopedBCryptHashHandle() {
    if (handle_) BCryptDestroyHash(handle_);
  }
  BCRYPT_HASH_HANDLE* receive() { return &handle_; }
  BCRYPT_HASH_HANDLE get() const { return handle_; }
 private:
  BCRYPT_HASH_HANDLE handle_;
};

std::string HResultToString(SECURITY_STATUS status) {
    std::stringstream ss;
    ss << "CNG Error: 0x" << std::hex << status;
    return ss.str();
}

std::wstring StringToWString(const std::string& str) {
    if (str.empty()) return std::wstring();
    int size_needed = MultiByteToWideChar(CP_UTF8, 0, &str[0], (int)str.size(), NULL, 0);
    std::wstring wstrTo(size_needed, 0);
    MultiByteToWideChar(CP_UTF8, 0, &str[0], (int)str.size(), &wstrTo[0], size_needed);
    return wstrTo;
}

SECURITY_STATUS OpenStorageProvider(ScopedNCryptHandle& provider, bool use_tpm) {
  LPCWSTR provider_name = use_tpm ? MS_PLATFORM_CRYPTO_PROVIDER : MS_KEY_STORAGE_PROVIDER;
  return NCryptOpenStorageProvider(provider.receive(), provider_name, 0);
}

std::vector<uint8_t> RawSignatureToDer(const std::vector<uint8_t>& raw_signature) {
    if (raw_signature.size() != 64) return {};
    auto encode_integer = [](const uint8_t* data, size_t len) -> std::vector<uint8_t> {
        size_t start = 0;
        while (start < len - 1 && data[start] == 0) start++;
        std::vector<uint8_t> result;
        result.push_back(0x02); 
        size_t actual_len = len - start;
        if (data[start] & 0x80) {
            result.push_back((uint8_t)(actual_len + 1));
            result.push_back(0x00);
            result.insert(result.end(), data + start, data + len);
        } else {
            result.push_back((uint8_t)actual_len);
            result.insert(result.end(), data + start, data + len);
        }
        return result;
    };
    std::vector<uint8_t> r_der = encode_integer(raw_signature.data(), 32);
    std::vector<uint8_t> s_der = encode_integer(raw_signature.data() + 32, 32);
    std::vector<uint8_t> sequence;
    sequence.push_back(0x30);
    sequence.push_back((uint8_t)(r_der.size() + s_der.size()));
    sequence.insert(sequence.end(), r_der.begin(), r_der.end());
    sequence.insert(sequence.end(), s_der.begin(), s_der.end());
    return sequence;
}

} // namespace

PlatformAuthenticatorImpl::PlatformAuthenticatorImpl() {}
PlatformAuthenticatorImpl::~PlatformAuthenticatorImpl() {}

void PlatformAuthenticatorImpl::CreateKey(
    const std::string& key_tag,
    const WindowsOptions& options,
    std::function<void(ErrorOr<std::vector<uint8_t>>)> result) {

    ScopedNCryptHandle provider;
    SECURITY_STATUS status = OpenStorageProvider(provider, options.use_tpm());
    if (status != ERROR_SUCCESS) {
         result(FlutterError(kPlatformError, "Failed to open provider: " + HResultToString(status)));
         return;
    }

    ScopedNCryptHandle key;
    std::wstring key_name = StringToWString(key_tag);
    
    status = NCryptCreatePersistedKey(
        provider.get(),
        key.receive(),
        NCRYPT_ECDSA_P256_ALGORITHM,
        key_name.c_str(),
        0, 
        0
    );

    if (status != ERROR_SUCCESS) {
        if (status == NTE_EXISTS) {
             result(FlutterError(kKeyAlreadyExists, "Key with this tag already exists."));
        } else {
             result(FlutterError(kKeyCreationFails, HResultToString(status)));
        }
        return;
    }

    if (options.require_user_authentication()) {
        NCRYPT_UI_POLICY uiPolicy = { 0 };
        uiPolicy.dwVersion = 1;
        uiPolicy.dwFlags = NCRYPT_UI_FORCE_HIGH_PROTECTION_FLAG;
        
        std::wstring prompt;
        if (options.windows_hello_prompt() != nullptr) {
            prompt = StringToWString(*(options.windows_hello_prompt()));
            uiPolicy.pszDescription = prompt.c_str();
            uiPolicy.pszFriendlyName = prompt.c_str(); 
        }

        status = NCryptSetProperty(key.get(), NCRYPT_UI_POLICY_PROPERTY, (PBYTE)&uiPolicy, sizeof(uiPolicy), 0);
        if (status != ERROR_SUCCESS) {
            NCryptFinalizeKey(key.get(), 0); 
            NCryptDeleteKey(key.get(), 0);
            result(FlutterError(kKeyCreationFails, "Failed to set UI policy: " + HResultToString(status)));
            return;
        }
    }

    status = NCryptFinalizeKey(key.get(), 0);
    if (status != ERROR_SUCCESS) {
        result(FlutterError(kKeyCreationFails, "Failed to finalize key: " + HResultToString(status)));
        return;
    }

    DWORD output_size = 0;
    status = NCryptExportKey(key.get(), 0, BCRYPT_ECCPUBLIC_BLOB, NULL, NULL, 0, &output_size, 0);
    if (status != ERROR_SUCCESS) {
         result(FlutterError(kPublicKeyRetrievalFailed, HResultToString(status)));
         return;
    }

    std::vector<uint8_t> blob(output_size);
    status = NCryptExportKey(key.get(), 0, BCRYPT_ECCPUBLIC_BLOB, NULL, blob.data(), output_size, &output_size, 0);
    if (status != ERROR_SUCCESS) {
         result(FlutterError(kPublicKeyRetrievalFailed, HResultToString(status)));
         return;
    }

    if (blob.size() < sizeof(BCRYPT_ECCKEY_BLOB)) {
        result(FlutterError(kPublicKeyRetrievalFailed, "Invalid blob size"));
        return;
    }
    
    BCRYPT_ECCKEY_BLOB* header = (BCRYPT_ECCKEY_BLOB*)blob.data();
    size_t key_len = header->cbKey; 
    std::vector<uint8_t> public_key;
    public_key.reserve(1 + 2 * key_len);
    public_key.push_back(0x04); 
    const uint8_t* key_data = blob.data() + sizeof(BCRYPT_ECCKEY_BLOB);
    public_key.insert(public_key.end(), key_data, key_data + (2 * key_len));

    result(public_key);
}

void PlatformAuthenticatorImpl::DeleteKey(
    const std::string& key_tag,
    std::function<void(std::optional<FlutterError>)> result) {
    
    LPCWSTR providers[] = { MS_PLATFORM_CRYPTO_PROVIDER, MS_KEY_STORAGE_PROVIDER };
    std::wstring key_name = StringToWString(key_tag);

    for (auto provider_name : providers) {
        ScopedNCryptHandle provider;
        SECURITY_STATUS status = NCryptOpenStorageProvider(provider.receive(), provider_name, 0);
        if (status == ERROR_SUCCESS) {
            ScopedNCryptHandle key;
            status = NCryptOpenKey(provider.get(), key.receive(), key_name.c_str(), 0, 0);
            if (status == ERROR_SUCCESS) {
                status = NCryptDeleteKey(key.release(), 0);
                if (status != ERROR_SUCCESS) {
                    result(FlutterError(kPlatformError, "Failed to delete key: " + HResultToString(status)));
                    return;
                }
                break;
            }
        }
    }
    result(std::nullopt);
}

void PlatformAuthenticatorImpl::Sign(
    const std::string& key_tag,
    const std::vector<uint8_t>& data,
    const WindowsOptions& options,
    std::function<void(ErrorOr<std::vector<uint8_t>>)> result) {
    
    ScopedNCryptHandle provider;
    SECURITY_STATUS status = OpenStorageProvider(provider, options.use_tpm());
    if (status != ERROR_SUCCESS) {
         result(FlutterError(kPlatformError, HResultToString(status)));
         return;
    }

    ScopedNCryptHandle key;
    std::wstring key_name = StringToWString(key_tag);

    status = NCryptOpenKey(provider.get(), key.receive(), key_name.c_str(), 0, 0);
    if (status != ERROR_SUCCESS) {
         if (status == NTE_BAD_KEY) {
             result(FlutterError(kKeyNotFound, "Key not found"));
         } else {
             result(FlutterError(kPlatformError, HResultToString(status)));
         }
         return;
    }

    ScopedBCryptAlgHandle hash_alg;
    status = BCryptOpenAlgorithmProvider(hash_alg.receive(), BCRYPT_SHA256_ALGORITHM, NULL, 0);
    if (status != ERROR_SUCCESS) {
         result(FlutterError(kSigningFailed, "Failed to open SHA256 provider"));
         return;
    }

    ScopedBCryptHashHandle hash_handle;
    status = BCryptCreateHash(hash_alg.get(), hash_handle.receive(), NULL, 0, NULL, 0, 0);
    if (status != ERROR_SUCCESS) {
         result(FlutterError(kSigningFailed, "Failed to create hash"));
         return;
    }

    status = BCryptHashData(hash_handle.get(), (PUCHAR)data.data(), (ULONG)data.size(), 0);
    if (status != ERROR_SUCCESS) {
         result(FlutterError(kSigningFailed, "Failed to hash data"));
         return;
    }

    std::vector<uint8_t> hash(32); 
    status = BCryptFinishHash(hash_handle.get(), hash.data(), (ULONG)hash.size(), 0);
    if (status != ERROR_SUCCESS) {
         result(FlutterError(kSigningFailed, "Failed to finish hash"));
         return;
    }

    DWORD signature_len = 0;
    status = NCryptSignHash(key.get(), NULL, (PBYTE)hash.data(), (DWORD)hash.size(), NULL, 0, &signature_len, 0);
    if (status != ERROR_SUCCESS) {
         result(FlutterError(kSigningFailed, HResultToString(status)));
         return;
    }

    std::vector<uint8_t> signature(signature_len);
    status = NCryptSignHash(key.get(), NULL, (PBYTE)hash.data(), (DWORD)hash.size(), signature.data(), signature_len, &signature_len, 0);
    if (status != ERROR_SUCCESS) {
         result(FlutterError(kSigningFailed, HResultToString(status)));
         return;
    }

    std::vector<uint8_t> der_signature = RawSignatureToDer(signature);
    if (der_signature.empty()) {
        result(FlutterError(kSigningFailed, "Failed to encode signature to DER"));
        return;
    }

    result(der_signature);
}

void PlatformAuthenticatorImpl::GetPublicKey(
    const std::string& key_tag,
    std::function<void(ErrorOr<std::optional<std::vector<uint8_t>>>)> result) {
    
    LPCWSTR providers[] = { MS_PLATFORM_CRYPTO_PROVIDER, MS_KEY_STORAGE_PROVIDER };
    std::wstring key_name = StringToWString(key_tag);
    
    for (auto provider_name : providers) {
        ScopedNCryptHandle provider;
        SECURITY_STATUS status = NCryptOpenStorageProvider(provider.receive(), provider_name, 0);
        if (status == ERROR_SUCCESS) {
            ScopedNCryptHandle key;
            status = NCryptOpenKey(provider.get(), key.receive(), key_name.c_str(), 0, 0);
            if (status == ERROR_SUCCESS) {
                 DWORD output_size = 0;
                status = NCryptExportKey(key.get(), 0, BCRYPT_ECCPUBLIC_BLOB, NULL, NULL, 0, &output_size, 0);
                if (status == ERROR_SUCCESS) {
                    std::vector<uint8_t> blob(output_size);
                    status = NCryptExportKey(key.get(), 0, BCRYPT_ECCPUBLIC_BLOB, NULL, blob.data(), output_size, &output_size, 0);
                    if (status == ERROR_SUCCESS && blob.size() >= sizeof(BCRYPT_ECCKEY_BLOB)) {
                        BCRYPT_ECCKEY_BLOB* header = (BCRYPT_ECCKEY_BLOB*)blob.data();
                        size_t key_len = header->cbKey;
                        std::vector<uint8_t> public_key;
                        public_key.reserve(1 + 2 * key_len);
                        public_key.push_back(0x04); 
                        const uint8_t* key_data = blob.data() + sizeof(BCRYPT_ECCKEY_BLOB);
                        public_key.insert(public_key.end(), key_data, key_data + (2 * key_len));
                        
                        result(std::optional<std::vector<uint8_t>>(public_key));
                        return;
                    }
                }
            }
        }
    }
    result(std::optional<std::vector<uint8_t>>(std::nullopt));
}

} // namespace web3_signers
