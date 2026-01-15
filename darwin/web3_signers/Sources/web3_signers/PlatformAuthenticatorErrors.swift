let KEY_ALREADY_EXISTS = PigeonError(
    code: "KEY_ALREADY_EXISTS", message: "Key already exists", details: nil)

let KEY_NOT_FOUND = PigeonError(code: "KEY_NOT_FOUND", message: "Key not found", details: nil)

let PUBLIC_KEY_RETRIEVAL_FAILED = PigeonError(
    code: "PUBLIC_KEY_RETRIEVAL_FAILED", message: "Failed to retrieve public key", details: nil)

let BIOMETRICS_NOT_AVAILABLE = PigeonError(
    code: "BIOMETRICS_NOT_AVAILABLE", message: "Biometrics not available", details: nil)

let USER_CANCELED = PigeonError(
    code: "USER_CANCELED", message: "User canceled authentication", details: nil)

let LOCKED_OUT = PigeonError(code: "LOCKED_OUT", message: "Biometrics locked out", details: nil)

let AUTH_ERROR = PigeonError(code: "AUTH_ERROR", message: "Authentication failed", details: nil)

func KEY_GENERATION_FAILED(details: String = "Failed to generate key pair") -> PigeonError {
    return PigeonError(code: "KEY_GENERATION_FAILED", message: details, details: nil)
}

func SIGNING_FAILED(details: String = "Failed to sign data") -> PigeonError {
    return PigeonError(code: "SIGNING_FAILED", message: details, details: nil)
}

func PLATFORM_ERROR(details: String = "Platform error") -> PigeonError {
    return PigeonError(code: "PLATFORM_ERROR", message: details, details: nil)
}
