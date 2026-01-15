## [1.0.0](https://github.com/vaariance/web3-signers/compare/v0.2.1...v1.0.0) (2026-01-15)

### Features

* Add `Uint`, `Bytes`, and `AbiCoder` type tests, enhance Passkey signer with signature parsing, and update platform authenticator. ([fe21cbc](https://github.com/vaariance/web3-signers/commit/fe21cbc51bd7233f9f88a12d8a1e0c371b05b1c9))
* add core crypto utilities and BIP-39/BIP-32 implementations ([688e89c](https://github.com/vaariance/web3-signers/commit/688e89c5e9f18d7f523a7e7f91b4ed0883e5c331))
* add platform signer api and configuration files ([aba6f76](https://github.com/vaariance/web3-signers/commit/aba6f76b168ef8397fcab283e86b9b1a27a4224b))
* add Windows and Android platform support for the web3_signers plugin ([b80320a](https://github.com/vaariance/web3-signers/commit/b80320a1cde589a54af290ab5949c1ea8dd07357))
* add Windows desktop support and improve auth UI prompts ([09c7964](https://github.com/vaariance/web3-signers/commit/09c7964440e429ee7897800651e620fa8f6b58b2))
* Allow `getAbiItem` to parse raw JSON ABI definitions by adding an `AbiItem.fromJson` constructor. ([5e25dcb](https://github.com/vaariance/web3-signers/commit/5e25dcbd63d276651d4b4a17701737572a10225f))
* **macos:** add macos platform support with authentication ([1c6dceb](https://github.com/vaariance/web3-signers/commit/1c6dceba56eaf6653c9c089f294b19ee5fb0ca8e))
* **platform:** add platform-specific authentication options and implementations ([7cd7447](https://github.com/vaariance/web3-signers/commit/7cd74474f02095c4f4c72f42ad8a52c255951f26))
* **platform:** add PlatformSigner for iOS/macOS key management ([f583a63](https://github.com/vaariance/web3-signers/commit/f583a632c078a794a4158c9a72a443a8a4152b30))
* Refactor BIP39/BIP32 file org, update core key generation with new tests. ([95b5277](https://github.com/vaariance/web3-signers/commit/95b5277c4798642d3a81804b6c296b4539f26d95))
* refactor PlatformAuthenticator to use `Uint8List` for byte arrays. ([430b920](https://github.com/vaariance/web3-signers/commit/430b92067fdec62ad2fb7c38e376427b00d354fb))
* Refactor signing interfaces and enums, add migration doc on ERC-7739 compatibility ([830ebfa](https://github.com/vaariance/web3-signers/commit/830ebfa95eb181bec880988c3ee53bdc4651b7ac))
* Rework ABI encoding and parsing, remove EIP-7702 dependency, and update the Signer interface with sync and async methods. ([c51afbe](https://github.com/vaariance/web3-signers/commit/c51afbeb79f96c9934e351c1bb21d107f9233401))
* **signers:** implement core signer classes and EIP-1271 verification ([d7fa120](https://github.com/vaariance/web3-signers/commit/d7fa120fa8d7e469e49e52b7502b08fe5bbe9d70))
* **test:** add comprehensive test suite and refactor test structure ([63ca4c5](https://github.com/vaariance/web3-signers/commit/63ca4c5eec23bfbeec2a6473a945b2f38446b8ae))
* **ui:** web3signers usecase/example implementation ([8fe0608](https://github.com/vaariance/web3-signers/commit/8fe060850851983c793b89edac1655f915ac7448))
* **ui:** web3signers usecase/example implementation ([69a86b9](https://github.com/vaariance/web3-signers/commit/69a86b9182328dcad64fcec09e7ae1e5e771f37b))
* **windows:** implement platform authenticator for Windows ([8889b15](https://github.com/vaariance/web3-signers/commit/8889b15544aed488feec6997360e3349cf30df6f))

### Bug Fixes

* **passkey:** align WebAuthn signature with viem/ox for on-chain verification ([3790972](https://github.com/vaariance/web3-signers/commit/37909725641c16222bf6b68c29039d623f7f6352))
* **passkey:** align WebAuthn signature with viem/ox for on-chain verification ([de0c484](https://github.com/vaariance/web3-signers/commit/de0c484f2f496bb1b9577138ce0d8c93377c3466))

## [0.2.1](https://github.com/vaariance/web3-signers/compare/v0.2.0...v0.2.1) (2025-06-16)

### Bug Fixes

* **erc1271:** use bytesToUnsignedInt instead of bytesToInt for signature parsing ([1070067](https://github.com/vaariance/web3-signers/commit/10700678aa5f5207a57ca31fdbffe3060a497078))

## 0.2.0

* remove IOS platform specific userId generation.
* add signature normalization to guard against malleablility
* add `padTonNBytes` extension to pad a uint8list to a specific length
* update tests and dependencies
* fix typos

## 0.1.11

* add `typePosition` to `PasskeySignature` response
* switch to darts native record type instead of tuple

## 0.1.10

* fix: update dummy signature to a universal format

## 0.1.9

* Add support for SignTypedData for signers
* Add ERC-1271 - isValidSignature for signers
* fix incosistent b64 credential encoding in passkeypair and passkeysignature

## 0.1.8

* fix hardcoded auth attachment

## 0.1.7

* simplify attestation challenge
* temmporarily handle ios user id base64 encoding
* expose configuration options
* change crypto.getRandomValues to use QuickCrypto

## 0.1.6

* revert getMessaging signature implementation

## 0.1.5

* replace Random with web3Dart randomBridge
* fix SignatureOptions not applied in eo wallet create.

## 0.1.4

* export vendor files
* tests and code documentations

## 0.1.3

* seperate passkey build signature bytes
* use abi.encode instead instead of manual encoding
* Use Uint8list instead of strings

## 0.1.2

* optimize signature options
* globalize prefix
* passkey configurations now require user verification and resident key fields.

## 0.1.1

* add platform for web
* update readme and example app

## 0.1.0

* remove hardware signers
* update readme and documentations

## 0.0.14

* fix safe dummy sig
* add FCLSignature class
* update example code
* fix regex match in converting passkey signature to FCL compat uint8list
* last version that surpports hardware signers (pleasse use passkeys)

## 0.0.14-beta-01

* modify dummy signatures for passkey signers to surpport safe.
* add FCL compatible signature bytes from passkey signer personalSign
* add static function to handle safe signature encoding for passkeys
* upgrade dependencies

## 0.0.14-alpha-01

* Marked hardware signers are deprecated. will be removed in v0.1.0
* exported utility functions marked as private in passkey signer
* modified dummy signatures in MSI

## 0.0.13

* returned raw credential from Passkey Signature
* made random challenge generator public

## 0.0.12

* register function requires display name
* register function now needs to specify whether to use resident keys
* bumped dependencies
* returned raw credential from PKP

## 0.0.11

* Added optional challenge string to register function

## 0.0.10

* changed android api levels

## 0.0.9

* Fixed compileSdk not specified

## 0.0.8

* Changed compileSdk to default

## 0.0.7

* Fix TypeError in incorrect Cbor data Decoding

## 0.0.6

* Add hardware signer dummy signature
* Fix Signature conversion method in harware signer
* Add comparism operators for uint256 class

## 0.0.5

* Remove unnecessary dependencies

## 0.0.4

* Reduce external deps
* Introduce 24 word phrase EOA signer

## 0.0.3

* Simplify Storage middleware usage

## 0.0.2

* remove unused dependencies
* updated sha256 function to rely on cryptography package

## 0.0.1

* Initial release.
* secp256r1 signatures via secure enclave and android keystore
* private key signatures
* passkey signatures (also secp256r1)
