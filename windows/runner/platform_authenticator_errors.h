#ifndef PLATFORM_AUTHENTICATOR_ERRORS_H_
#define PLATFORM_AUTHENTICATOR_ERRORS_H_

#include <string>

namespace web3_signers {

// Error Codes matching Kotlin/Swift definitions
const std::string kKeyAlreadyExists = "KEY_ALREADY_EXISTS";
const std::string kKeyNotFound = "KEY_NOT_FOUND";
const std::string kKeyCreationFails = "KEY_CREATION_FAILED";
const std::string kTagNotFound = "TAG_NOT_FOUND";
const std::string kSigningFailed = "SIGNING_FAILED";
const std::string kPublicKeyRetrievalFailed = "PUBLIC_KEY_RETRIEVAL_FAILED";
const std::string kPlatformError = "PLATFORM_ERROR";
const std::string kAlreadyExists = "ALREADY_EXISTS"; 

} // namespace web3_signers

#endif // PLATFORM_AUTHENTICATOR_ERRORS_H_
