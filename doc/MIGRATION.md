# Migration Guide to v1.0.0

`web3_signers` v1.0.0 marks a significant milestone and a major architectural shift. This release strictly focuses on providing robust signer implementations for **Smart Accounts and EOAs** providing compatibility with **ERC-1271 and ERC-7739** signature verification.

> [!IMPORTANT]
> This package is now purpose-built for Smart Accounts, EOAs and ERC-1271/ERC-7739 verifications. It is **vendor-agnostic** and no longer aims to be a general-purpose HD wallet management library.

## Core Philosophy Changes

-   **Smart Account Focus**: The primary goal is to facilitate signing for smart accounts.
-   **Vendor Agnostic**: Specific integrations (like Alchemy Light Account prefixes or Safe-specific encodings) have been removed from the core package.
-   **No Native HD Wallet Logic**: The package no longer manages HD wallet hierarchies internally. `LocalKeySigner` is now a condensed implementation of the former `EOAWallet` and `PrivateKeySigner`, focused purely on signing with a single key. However, HD wallets construction is left to the user, with the help of `mnemonicToPrivateKey(mnemonic,drivationPath)`.

## Breaking Changes Summary

| Feature | Pre-v1.0.0 | v1.0.0 |
| :--- | :--- | :--- |
| **Interface** | `MultiSignerInterface` | `Signer` |
| **Local Key Class** | `PrivateKeySigner` | `LocalKeySigner` |
| **Wallet Class** | `EOAWallet` | Removed (Use `LocalKeySigner`) |
| **Hardware** | null | `PlatformKeySigner` |
| **Address Type** | `EthereumAddress` | `HexString` (String) |
| **Sign Return** | `Uint8List` (Bytes) | `Signature` (Object) |

## Migration Examples

### 1. Configuration

**Before (v0.x)**
```dart
final options = PassKeysOptions(
  name: "variance",
  namespace: "variance.space",
  ...
);
```

**After (v1.0.0)**
Renamed to `PassKeyConfig` for passkeys, and introduced `PlatformConfig` for platform keys.

```dart
final config = PassKeyConfig(
  rpName: "variance", 
  rpId: "variance.space",
  ...
);

// New: Platform Config
final platformConfig = PlatformConfig(
  keyTag: "com.example.app.key",
);
```

### 2. Key Generation

Key generation logic is now separated from the signer classes.

#### Private Keys
**Before**
```dart
final signer = PrivateKeySigner.createRandom("password");
// OR 
final signer = PrivateKeySigner.create(privKey, "password");
// OR
final signer = PrivateKeySigner.fromJson(json, "password");
```

**After**
```dart
// Generate or retrieve raw bytes
final privateKeyBytes = generatePrivateKey(); 

// Instantiate signer
final signer = LocalKeySigner.fromRawPrivateKey(privateKeyBytes);
```

#### Mnemonics / HD Wallets
**Before**
```dart
// EOAWallet handled generation and derivation
final wallet = EOAWallet.createWallet(); 
final wallet = EOAWallet.addAccount(index); 
final recovered = EOAWallet.recoverAccount(mnemonic);
```

**After**
```dart
// Generate a new mnemonic
final mnemonic = generateMnemonic(); // defaults to 24 words, but can take optional word length

// Or recover/use existing mnemonic to get the private key
final privateKeyBytes = mnemonicToPrivateKey(mnemonic); 
// Note: You can specify a custom path if needed:
// mnemonicToPrivateKey(mnemonic, "m/44'/60'/0'/0/1");

// Instantiate signer
final signer = LocalKeySigner.fromRawPrivateKey(privateKeyBytes);
// Or strictly from mnemonic (uses default path)
final signer = LocalKeySigner.fromMnemonic(mnemonic);
```

#### Passkeys
**Before**
```dart
final PassKeySigner pkpSigner = PassKeySigner(options: PassKeysOptions);

PassKeyPair pkp = await pkpSigner.register("user@variance.space", "test user"); 
```

**After**
```dart
// you now can pass a list of credentials to exclude from the registration process
// you can also pass your attestation level
final key = generatePassKey(
  config: PassKeyConfig,
  username: "user@variance.space",
  displayname: "test user",
  ... // optional params
);

final PassKeySigner passkeySigner = PassKeySigner.withConfig(
  PassKeyConfig,
  key,
);
```

#### (New) Platform Signer

```dart
final key = generatePlatformKey(
  config: PlatformConfig,
  checkExisting: false, // checks if an existing key exists and handles it graciously. if unspecified, it may throw an error if you try to create a new key with the same tag
);
final PlatformKeySigner platformSigner = PlatformKeySigner.withConfig(
  PlatformConfig,
  key,
);
```

### 3. Signing Methods

#### `personalSign`

**Before (v0.x)**
Returned `Uint8List` (raw bytes).
```dart
final Uint8List signature = await signer.personalSign(message);
```

**After (v1.0.0)**
Returns a `MsgSignature`/`EIP7702MsgSignature` object (specifically `Signature`).
```dart
final MsgSignature signature = await signer.personalSign(message);
// You must serialize the signature object (r, s, v) to bytes 
// according to your smart account implementation.
```

#### `signToEc` (Replaced) -> `sign` / `signAsync`

**Before (v0.x)**
```dart
final MsgSignature signature = await signer.signToEc(message);
```

**After (v1.0.0)**
Use `sign` for synchronous signers (LocalKey) and `signAsync` for async signers (Passkey/Platform).

```dart
// For LocalKeySigner (Synchronous)
final Signature sig = signer.sign(message); 

// For PassKeySigner / PlatformKeySigner (Asynchronous)
final Signature sig = await signer.signAsync(message);
```
if you try to call `sync` on `async` signer it will throw an exception. to check if a signer is synchronous you can use the `signer.supportsSyncSigning` property.

### 4. getAddress Method

**Before (v0.x)**
```dart
final address = signer.getAddress(); // does not return a valid ethereum address for p256 signers
```

**After (v1.0.0)**
```dart
final address = signer.getAddress(); // returns a valid ethereum address 
```

this is achieved using the tempo transaction format:
`address(uint160(uint256(keccak256(abi.encodePacked(pubKeyX, pubKeyY)))))`
- this creates compatibility with the tempo transaction format, whilst being negliglible for every other evm.
if the format of the address is not okay, get the key `signer.publicKey` and use it to your taste.

### 5. WebAuthn Signature Metadata

#### `typePos` → `getTypeLocation()`

**Before (v0.x)**
```dart
final PassKeySignature sig = await signer.signToPasskeySignature(hash);
final typePos = sig.typePos; // Returns position of 'webauthn.get' VALUE (index 9)
```

**After (v1.0.0)**
```dart
final Signature sig = await signer.signAsync(hash);
final typeIndex = sig.getTypeLocation(); // Returns position of '"type"' KEY (index 1)
```

> [!IMPORTANT]
> This change aligns with [viem/ox](https://github.com/wevm/ox) behavior. The Kernel WebAuthn validator and other on-chain verifiers expect `typeIndex` to point to the `"type"` field **key** in `clientDataJSON`, not the value.
>
> ```
> clientDataJSON: {"type":"webauthn.get","challenge":"..."}
>                  ↑
>                  typeIndex = 1 (position of opening quote)
> ```

### 6. Interface Changes

The core interface has been renamed to reflect the package's purpose.

**Before**
```dart
abstract class MultiSignerInterface { ... }
```

**After**
```dart
abstract class Signer { 
    // ...
    // personalSign now returns Future<Signature>
    // boolean properties: `supportsUserPresence` `supportsUserVerification` `isRecoverable` `supportsSyncSigning` 
}
```
