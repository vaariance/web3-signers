# web3 signers

A flutter plugin that provides a uniform interface for signing EIP-1271 messages on dart.

supports:

    ✅ passkey signatures
    ✅ secure enclave/android keystore signatures
    ✅ EOA wallet (mnemonic backed)
    ✅ privateKey signatures

## Quick synopsis

```dart
import 'package:web3_signers/web3_signers.dart';
```

## Working with passkeys

passkeys signer conforms to the `multi-signer-interface` and allows you to sign payloads using your device passkeys. It falls under the secp256r1 category and can be verified on-chain using the [P256Verifier](https://p256.eth.limo/) precompile.

```dart
final PassKeySigner pkpSigner = PassKeySigner(
  "variance.space", // replace with your relying party Id (domain name)
  "variance", // replace with your relying party name
  "https://variance.space", // replace with your relying party origin
);

// register a new passkey
PassKeyPair pkp = await pkpSigner.register("user@variance.space", "test user"); 
// username is `user@variance.space` and is required
// diplay name is `test user` and is optional
```

If you already know the `credentialIds` created for the user, you can pass the `knownCredentials` as thus:

```dart
final PassKeySigner pkpSigner = PassKeySigner(
  "variance.space", // replace with your relying party Id (domain name)
  "variance", // replace with your relying party name
  "https://variance.space", // replace with your relying party origin
  knownCredentials: {"0xcredentialId1", "0xcredentialId2", "0xcredentialId3"}
);
```

This enables the authenticator to filter the passkeys presented to the user for signing operations.

### credential Id

In order to comform to `bytes32`, all credential id's are Hex encoded to emulate the `getAddress()` function of the multi-signer-interface. this makes the credential Id  stand in as the public address for a passkey signer.

> credential Id's are always converted to Hex before returned.

To convert a credentialId to and from hex format use the following:

```dart
final credentialHex = "0xbf34ed6a...32 bytes in length";
final Uint8List fromHex = pkpSigner.hexToCredentialId(credentialHex); 
final String toHex = pkpSigner.credentialIdToHex(fromHex);

final id = Base64url.encode(fromHex); // base 64 version of the credential id
```

### Passkey signatures

There are 3 methods of signing a payload using the paskey signer.

- method 1: using `personalSign`

personal sign returns a `Uint8List` which is an encoded representation of the [passkeySignature object](./lib/src/signers/passkey_signer.dart#L85) needed onchain.
in order to extract the individual values, you have to `abi.decode()` it.
The signed `challenge` is excluded from this object. It is assumed your relying party is aware of this challenge which should be `Base64Url` encoded.

```dart
final sig = await pkpSigner.personalSign(Uint8List(32));
```

- method 2: using `signToEc`

Similar to personalSign, it conforms to the multi-signer-interface and returns an instance of msgSignature containing the `r`, `s` and `v`  values of the signature. Effectively **v** is 0;

```dart
final sig = await pkpSigner.signToEc(Uint8List(32));
```

- method 3: using `signToPasskeySignature`

This is not part of the multi-signer-interface but is actually being called internally by `personalSign` and `signToEc` and returns the raw [passkeySignature object](./lib/src/signers/passkey_signer.dart#L85).

```dart
final PassKeySignature sig = await pkpSigner.signToPasskeySignature(Uint8List(32));
```

> For each of the method above you can pass in an index if you have knownCredentials. prompting the authenticator to specifically sign with a particular credential.
> e.g  `await pkpSigner.signToPasskeySignature(Uint8List(32), 2); // signing with knowwnCredential at index 2`

## Working with secure enclave/keystore

The hardware signers conform to the `multi-signer-interface` and enables your app to generate keypairs inside the security chip of your device. For iOS it is the secure enclave, while in android it is the android keystore. This allows you to sign payloads with your device hardware.

```dart
final HardwareSigner hwdSigner = HardwareSigner.withTag("my app tag");

// generates a new key pair for tag. if already existing, returns it.
final P256Credential credential = await hwdSigner.generateKeyPair();

// gets an existing publickey from the device.
// throws if publickey does not exist.
final publicKey = await hwdSigner.getPublicKey() // returns a tuple(x, y)

// checks if a public has been created for the app
final bool isCreated =  await hwdSigner.isKeyCreated()
```

The hardware signer provides a high level abstraction for the [SecureP256](./lib/src/utils/p256.dart) class in order to conform to the mult-signer-interface. However, you can access the `SecureP256` class directly which supports additional operations like `encrypt`, `decrypt` and `verify`.

### Signing a payload

The hardware signer surports both `personalSign` and `signToEc` as defined in the multi-signer-interface

- method 1: `personalSign`

```dart
final Uint8List payload = Uint8List(32); // bytes32(0)
final Uint8List derEncodedSignature = hwdSigner.personalSign(payload);
```

- method 2: `signToEc`

```dart
final Uint8List payload = Uint8List(32); // bytes32(0)
final signature = hwdSigner.signToEc(payload);// returns MsgSignature(r, s)

log("r: ${signature.r}") // bigint
log("s: ${signature.s}") // bigint
```

> To verify the payload on the blockchain successfully, you must verify against the SHA256 hash of the payload.

## Working with Privatey keys

The private key signer conform to the `multi-signer-interface` and is the most basic signer.

```dart
final PrivateKeySigner signer = PrivateKeySigner.createRandom("password");
```

You can manully instantiate the privateKey signer

```dart
final Random random = Random.secure();
final EthPrivateKey privKey = EthPrivateKey.createRandom(random);
final PrivateKeySigner signer = PrivateKeySigner.create(privKey, "password", random);
```

You can load from an encrypted backup

```dart
final PrivateKeySigner signer = PrivateKeySigner.fromJson("source", "password");
```

To sign transactions, use any of `personalSign` or `signToEc`

```dart
final Uint8List payload = Uint8List(32); // bytes32(0)
final signature = await signer.signToEc(payload);
log("r: ${signature.r}, s: ${signature.s}") // r and s are both bigint format
```

## Building an EOA wallet

Beyond [EIP-1271](https://eips.ethereum.org/EIPS/eip-1271) messages. the [web3-signers](https://pub.dev/packages/web3_signers) package can be relied upon for developing fully featured [Externally Owned Accounts](https://ethereum.org/developers/docs/accounts) like [Metamask](https://metamask.io) using the [EOAWallet](./lib/src/signers/eoa_wallet_signer.dart) class.
The EOA wallet conforms to the multi-signer-interface, hence it can be used to create signers that are backed with a seed phrase.

```dart
// creates a new EOA wallet
EOAWallet eoaWallet = EOAWallet.createWallet();

// by the default a 12 word phrase signer is created, in order to create a 24 word phrase you need to specify it
eoaWallet = EOAWallet.createWallet(WordLength.word_24); // returns 24 word phrase signer

// retrieve the account seed phrase
final mnemonic = eoaWallet.exportMnemonic();

// recover eoa wallet from seed phrase
eoaWallet = EOAWallet.recoverAccount(mnemonic);

// generate a new deterministic account
final accountOne = eoaWallet.addAccount(1);

// export the private key of an account
final accountZer0PrivKey = eoaWallet.exportPrivateKey(0);
final accountOnePrivKey = eoaWallet.exportPrivateKey(1);

// get account address
String accountZer0Address = eoaWallet.zerothAddress;
// or
accountZer0Address = eoaWallet.getAddress();
final accountOneAddress = eoaWallet.getAddress(index: 1);
```

The `signToEc` and `personalSign` methods are available for signing transactions. optionally, you can use the exportedPrivateKey to sign transactions DIY.

## Handling Der Encoded data

By default the data returned from hardware getPublicKey/sign methods are DerEncoded. also this package intrinsically handles the derDecoding of passkey signatures.

- convert a Der Encoded public key to `Tuple(x,y)`

```dart
final derDecoded = getPublicKeyFromBytes(derCodedData);
```

- convert a Der Encoded signature to `Tuple(r,s)`

```dart
final derDecoded = getMessagingSignature(derCodedSig);
```

## Multi Signer Interface

The Multi Signer Interface or (MSI), provides a uniform interface that must be implemented across different signer types.

Any class inheriting the MSI must adhere to the following:

```dart
abstract class MultiSignerInterface {
    /// You must specify a dummy signature that matches your transaction signature standard.
    String dummySignature = "0x";
    /// Generates a public address of the signer.
    String getAddress({int? index});
    /// Signs the provided [hash] using the personal sign method.
    Future<Uint8List> personalSign(Uint8List hash, {int? index});
    /// Signs the provided [hash] using elliptic curve algorithm and returns the r and s values.
    Future<MsgSignature> signToEc(Uint8List hash, {int? index});
}
```

## Features

| Feature                        | Android | iOS | Web |
| ------------------------------ | :-----: | :-: | :-: |
| generate passkeypair           | ✅      | ✅  | ✅  |
| sign with passkey              | ✅      | ✅  | ✅  |
| generate p256 keypair          | ✅      | ✅  |    |
| sign with secure enclave       | ✅      | ✅  |    |
| encrypt                        | ✅      | ✅  |    |
| decrypt                        | ✅      | ✅  |    |
| Generate EOA wallet            | ✅      | ✅  | ✅  |
| Sign For EOA account           | ✅      | ✅  | ✅  |
| Biometric Middleware           | ✅      | ✅  |    |
| Secure Storage middleware      | ✅      | ✅  | ✅  |
| Private key signer             | ✅      | ✅  | ✅  |

## Platform specific configuration

### iOS

- HardwareSignatures on iOS requires user prescence. update `info.plist` to enable face-id.

    ```plist
     <key>NSFaceIDUsageDescription</key>
     <string>Why is my app authenticating using face id?</string>
    ```

- Configuring passkeys for iOS

    1. Set up Universal Links. follow this [guide](https://docs.flutter.dev/cookbook/navigation/set-up-universal-links).

- Configuring ios secure enclave
    1. Set your `platform :ios` to be minimum of 12.4

### Android

- Set your `minSdkVersion` to 28

- Configuring android passkeys

  - Set up App Links. follow this [guide](https://docs.flutter.dev/cookbook/navigation/set-up-app-links).
  - Make sure your have `"delegate_permission/common.get_login_creds"` in your `assetlinks.json`. Refer to this [guide](https://developer.android.com/training/sign-in/passkeys).

- Use the following command to get you app SHA256 certificate required in your `assetlinks.json`:

    ```sh
    keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android/
    ```
