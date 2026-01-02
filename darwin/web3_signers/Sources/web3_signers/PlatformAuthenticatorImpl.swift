import Foundation

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
        keyTag: String, completion: @escaping (Result<FlutterStandardTypedData, Error>) -> Void
    ) {
        cryptoQueue.async { [weak self] in
            guard let self = self else { return }

            if self.getSecKey(from: keyTag) != nil {
                let msg = "Key already exists"
                let err = NSError(
                    domain: self.domain, code: -1, userInfo: [NSLocalizedDescriptionKey: msg])
                DispatchQueue.main.async { completion(.failure(err)) }
                return
            }

            var attributes: [String: Any]
            switch self.createAccessControl() {
            case .success(let access):
                attributes = self.createKeyAttributes(keyTag: keyTag, access: access)
            case .failure(let error):
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }

            var error: Unmanaged<CFError>?
            guard let key = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
                let err = error!.takeRetainedValue() as Error
                DispatchQueue.main.async { completion(.failure(err)) }
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
                let msg = "Keychain Error"
                let err = NSError(
                    domain: self.domain, code: -1, userInfo: [NSLocalizedDescriptionKey: msg])
                DispatchQueue.main.async { completion(.failure(err)) }
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

            guard let key = self.getSecKey(from: keyTag) else {
                let msg = "Key not found"
                let err = NSError(
                    domain: self.domain, code: -1, userInfo: [NSLocalizedDescriptionKey: msg])
                DispatchQueue.main.async { completion(.failure(err)) }
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
                DispatchQueue.main.async {
                    completion(.failure(error!.takeRetainedValue() as Error))
                }
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

    private func getSecKey(from keyTag: String) -> SecKey? {
        var item: CFTypeRef?
        let status = SecItemCopyMatching(
            keyQuery(keyTag: keyTag, returnRef: true),
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
            let msg = "Failed to generate public key from private key"
            let err = NSError(domain: domain, code: -1, userInfo: [NSLocalizedDescriptionKey: msg])
            return .failure(err)
        }

        var error: Unmanaged<CFError>?
        if let keyData = SecKeyCopyExternalRepresentation(publicKey, &error) as Data? {
            return .success(FlutterStandardTypedData(bytes: keyData))
        } else {
            return .failure(error!.takeRetainedValue() as Error)
        }
    }

    private func createAccessControl() -> Result<SecAccessControl, Error> {
        var error: Unmanaged<CFError>?
        let flags: SecAccessControlCreateFlags = [.privateKeyUsage, .biometryAny]
        let access = SecAccessControlCreateWithFlags(
            kCFAllocatorDefault,
            kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            flags,
            &error)!

        if let error = error {
            return .failure(error.takeRetainedValue() as Error)
        }
        return .success(access)
    }

    private func createKeyAttributes(keyTag: String, access: SecAccessControl) -> [String: Any] {
        var privateKeyAttrs: [String: Any] = [
            kSecAttrIsPermanent as String: true,
            kSecAttrApplicationTag as String: keyTag.data(using: .utf8)!,
            kSecAttrAccessControl as String: access,
            kSecAttrCanSign as String: true,
        ]

        var attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeySizeInBits as String: 256,
            kSecPrivateKeyAttrs as String: privateKeyAttrs,
        ]

        #if !targetEnvironment(simulator)
            attributes[kSecAttrTokenID as String] = kSecAttrTokenIDSecureEnclave
        #endif

        return attributes
    }

    private func keyQuery(
        keyTag: String,
        returnRef: Bool = false
    ) -> CFDictionary {
        var query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: keyTag.data(using: .utf8)!,
            kSecAttrKeyType as String: kSecAttrKeyTypeEC,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]

        if returnRef {
            query[kSecReturnRef as String] = true
        }

        return query as CFDictionary
    }

}
