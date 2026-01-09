package space.variance.web3_signers

val KEY_ALREADY_EXISTS = FlutterError("KEY_ALREADY_EXISTS", "Key already exists", null)

val KEY_NOT_FOUND = FlutterError("KEY_NOT_FOUND", "Key not found", null)

val BIOMETRICS_NOT_AVAILABLE = FlutterError("BIOMETRICS_NOT_AVAILABLE", "Biometrics not available", null)

val NO_ACTIVITY = FlutterError("NO_ACTIVITY", "No foreground activity available yet", null)

fun KEY_GENERATION_FAILED(details: String? = "Failed to generate key pair"): FlutterError {
    return FlutterError("KEY_GENERATION_FAILED", details, null)
}

fun PUBLIC_KEY_RETRIEVAL_FAILED(details: String? = "Failed to retrieve public key"): FlutterError {
    return FlutterError("PUBLIC_KEY_RETRIEVAL_FAILED", details, null)
}

fun SIGNING_FAILED(details: String? = "Failed to sign data"): FlutterError {
    return FlutterError("SIGNING_FAILED", details, null)
}

fun PLATFORM_ERROR(details: String? = "Platform error"): FlutterError {
    return FlutterError("PLATFORM_ERROR", details, null)
}

fun USER_CANCELED(details: String? = "User canceled authentication"): FlutterError {
    return FlutterError("USER_CANCELED", details, null)
}

fun LOCKED_OUT(details: String? = "Biometrics locked out"): FlutterError {
    return FlutterError("LOCKED_OUT", details, null)
}

fun AUTH_ERROR(details: String? = "Authentication failed"): FlutterError {
    return FlutterError("AUTH_ERROR", details, null)
}
