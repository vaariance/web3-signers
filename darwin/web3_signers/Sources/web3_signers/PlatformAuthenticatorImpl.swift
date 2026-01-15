import Foundation
import LocalAuthentication

#if os(iOS)
    import Flutter
#elseif os(macOS)
    import FlutterMacOS
#endif

class PlatformAuthenticatorImpl: PlatformAuthenticator {

    let domain = "PlatformAuthenticator"

    private let cryptoQueue = DispatchQueue(
        label: "platform.auth.crypto",
        qos: .userInitiated
    )

    func createKey(
        keyTag: String, options: DarwinOptions,
        completion: @escaping (Result<FlutterStandardTypedData, Error>) -> Void
    ) {
        cryptoQueue.async { [weak self] in
            guard let self = self else { return }

            if self.getSecKey(from: keyTag) != nil {
                DispatchQueue.main.async {
                    completion(.failure(KEY_ALREADY_EXISTS))
                }
                return
            }

            var attributes: [String: Any]
            switch self.createAccessControl(options: options) {
            case .success(let access):
                attributes = self.createKeyAttributes(
                    keyTag: keyTag, access: access, options: options)
            case .failure(let error):
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }

            var error: Unmanaged<CFError>?
            guard let key = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
                let err = error!.takeRetainedValue() as Error
                let details = err.localizedDescription
                DispatchQueue.main.async {
                    completion(.failure(KEY_GENERATION_FAILED(details: details)))
                }
                return
            }

            let result = self.extractPublicKey(from: key)
            DispatchQueue.main.async { completion(result) }
        }
    }

    func deleteKey(keyTag: String, completion: @escaping (Result<Void, Error>) -> Void) {
        cryptoQueue.async { [weak self] in
            guard let self = self else { return }

            let status = SecItemDelete(self.keyQuery(keyTag: keyTag))
            guard status == errSecSuccess || status == errSecItemNotFound else {
                let msg =
                    SecCopyErrorMessageString(status, nil) as String? ?? "Unknown Keychain Error"
                DispatchQueue.main.async {
                    completion(.failure(PLATFORM_ERROR(details: msg)))
                }
                return
            }
            DispatchQueue.main.async { completion(.success(())) }
        }
    }

    func sign(
        keyTag: String, data: FlutterStandardTypedData,
        completion: @escaping (Result<FlutterStandardTypedData, Error>) -> Void
    ) {
        cryptoQueue.async { [weak self] in
            guard let self = self else { return }

            let context = LAContext()
            context.localizedReason = "Sign Ethereum Data"

            guard let key = self.getSecKey(from: keyTag, context: context) else {
                DispatchQueue.main.async {
                    completion(.failure(KEY_NOT_FOUND))
                }
                return
            }

            let algorithm: SecKeyAlgorithm = .ecdsaSignatureMessageX962SHA256
            let dataBytes = data.data as Data
            var error: Unmanaged<CFError>?
            guard
                let signature = SecKeyCreateSignature(
                    key,
                    algorithm,
                    dataBytes as CFData,
                    &error) as Data?
            else {
                let err = error!.takeRetainedValue() as Error
                let details = err.localizedDescription
                DispatchQueue.main.async { completion(.failure(SIGNING_FAILED(details: details))) }
                return
            }

            let result = FlutterStandardTypedData(bytes: signature)
            DispatchQueue.main.async { completion(.success(result)) }
        }
    }

    func getPublicKey(
        keyTag: String, completion: @escaping (Result<FlutterStandardTypedData?, Error>) -> Void
    ) {
        cryptoQueue.async { [weak self] in
            guard let self = self else { return }

            guard let key = self.getSecKey(from: keyTag) else {
                DispatchQueue.main.async { completion(.success(nil)) }
                return
            }

            let result = self.extractPublicKey(from: key)
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    completion(.success(data))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }

    private func getSecKey(from keyTag: String, context: LAContext? = nil) -> SecKey? {
        var item: CFTypeRef?
        let status = SecItemCopyMatching(
            keyQuery(keyTag: keyTag, returnRef: true, context: context),
            &item
        )
        guard status == errSecSuccess else { return nil }
        let key = item as! SecKey
        return key
    }

    private func extractPublicKey(from privateKey: SecKey) -> Result<
        FlutterStandardTypedData, Error
    > {
        guard let publicKey = SecKeyCopyPublicKey(privateKey) else {
            return .failure(PUBLIC_KEY_RETRIEVAL_FAILED)
        }

        var error: Unmanaged<CFError>?
        if let keyData = SecKeyCopyExternalRepresentation(publicKey, &error) as Data? {
            return .success(FlutterStandardTypedData(bytes: keyData))
        } else {
            let err = error!.takeRetainedValue() as Error
            return .failure(PUBLIC_KEY_RETRIEVAL_FAILED)
        }
    }

    private func parseAccessiblity(options: DarwinOptions) -> CFString {
        let accessibility: CFString
        switch options.accessible {
        case .whenUnlocked:
            accessibility = kSecAttrAccessibleWhenUnlocked
        case .afterFirstUnlock:
            accessibility = kSecAttrAccessibleAfterFirstUnlock
        case .whenUnlockedThisDeviceOnly:
            accessibility = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        case .whenPasscodeSetThisDeviceOnly:
            accessibility = kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly
        case .afterFirstUnlockThisDeviceOnly:
            accessibility = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        }
        return accessibility
    }

    private func createAccessControl(options: DarwinOptions) -> Result<SecAccessControl, Error> {
        var error: Unmanaged<CFError>?

        var accessibility: CFString = parseAccessiblity(options: options)

        var flags: SecAccessControlCreateFlags = [.privateKeyUsage]

        if options.requireUserAuthentication {
            if options.allowFallbackAuthentication {
                flags.insert(.userPresence)
            } else {
                if options.invalidateOnBiometricChange {
                    flags.insert(.biometryCurrentSet)
                } else {
                    flags.insert(.biometryAny)
                }
            }
        }

        let access = SecAccessControlCreateWithFlags(
            kCFAllocatorDefault,
            accessibility,
            flags,
            &error)

        if let error = error {
            let err = error.takeRetainedValue() as Error
            let details = err.localizedDescription
            return .failure(PLATFORM_ERROR(details: details))
        }
        return .success(access!)
    }

    private func createKeyAttributes(
        keyTag: String, access: SecAccessControl, options: DarwinOptions
    ) -> [String: Any] {
        var privateKeyAttrs: [String: Any] = [
            kSecAttrIsPermanent as String: options.isPermanent,
            kSecAttrApplicationTag as String: keyTag.data(using: .utf8)!,
            kSecAttrCanSign as String: true,
        ]

        if let accessGroup = options.accessGroup {
            privateKeyAttrs[kSecAttrAccessGroup as String] = accessGroup
        }

        var attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeySizeInBits as String: 256,
        ]

        if options.useSecureEnclave {
            attributes[kSecAttrTokenID as String] = kSecAttrTokenIDSecureEnclave
            privateKeyAttrs[kSecAttrAccessControl as String] = access
        } else {
            privateKeyAttrs[kSecAttrAccessible as String] = parseAccessiblity(options: options)
        }

        attributes[kSecPrivateKeyAttrs as String] = privateKeyAttrs

        return attributes
    }

    private func keyQuery(
        keyTag: String,
        returnRef: Bool = false,
        context: LAContext? = nil
    ) -> CFDictionary {
        var query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: keyTag.data(using: .utf8)!,
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]

        if returnRef {
            query[kSecReturnRef as String] = true
        }

        if let context = context {
            query[kSecUseAuthenticationContext as String] = context
        }

        return query as CFDictionary
    }

}
