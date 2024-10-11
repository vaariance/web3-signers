## 0.1.6

- revert getMessaging signature implementation

## 0.1.5

- replace Random with web3Dart randomBridge
- fix SignatureOptions not applied in eo wallet create.

## 0.1.4

- export vendor files
- tests and code documentations

## 0.1.3

- seperate passkey build signature bytes
- use abi.encode instead instead of manual encoding
- Use Uint8list instead of strings

## 0.1.2

- optimize signature options
- globalize prefix
- passkey configurations now require user verification and resident key fields.

## 0.1.1

- add platform for web
- update readme and example app

## 0.1.0

- remove hardware signers
- update readme and documentations

## 0.0.14

- fix safe dummy sig
- add FCLSignature class
- update example code
- fix regex match in converting passkey signature to FCL compat uint8list
- last version that surpports hardware signers (pleasse use passkeys)

## 0.0.14-beta-01

- modify dummy signatures for passkey signers to surpport safe.
- add FCL compatible signature bytes from passkey signer personalSign
- add static function to handle safe signature encoding for passkeys
- upgrade dependencies

## 0.0.14-alpha-01

- Marked hardware signers are deprecated. will be removed in v0.1.0
- exported utility functions marked as private in passkey signer
- modified dummy signatures in MSI

## 0.0.13

- returned raw credential from Passkey Signature
- made random challenge generator public

## 0.0.12

- register function requires display name
- register function now needs to specify whether to use resident keys
- bumped dependencies
- returned raw credential from PKP

## 0.0.11

- Added optional challenge string to register function

## 0.0.10

- changed android api levels

## 0.0.9

- Fixed compileSdk not specified

## 0.0.8

- Changed compileSdk to default

## 0.0.7

- Fix TypeError in incorrect Cbor data Decoding

## 0.0.6

- Add hardware signer dummy signature
- Fix Signature conversion method in harware signer
- Add comparism operators for uint256 class

## 0.0.5

- Remove unnecessary dependencies

## 0.0.4

- Reduce external deps
- Introduce 24 word phrase EOA signer

## 0.0.3

- Simplify Storage middleware usage

## 0.0.2

- remove unused dependencies
- updated sha256 function to rely on cryptography package

## 0.0.1

- Initial release.
- secp256r1 signatures via secure enclave and android keystore
- private key signatures
- passkey signatures (also secp256r1)
