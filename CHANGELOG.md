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
