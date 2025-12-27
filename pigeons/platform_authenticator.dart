import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/api/platform_authenticator.g.dart',
    dartOptions: DartOptions(),

    cppOptions: CppOptions(namespace: 'web3_signers'),
    cppHeaderOut: 'windows/runner/platform_authenticator.g.h',
    cppSourceOut: 'windows/runner/platform_authenticator.g.cpp',

    kotlinOut:
        'android/src/main/kotlin/com/example/web3_signers/PlatformAuthenticator.g.kt',
    kotlinOptions: KotlinOptions(),

    swiftOut:
        'ios/web3_signers/Sources/web3_signers/PlatformAuthenticator.g.swift',
    swiftOptions: SwiftOptions(),
  ),
)
@HostApi()
abstract class PlatformAuthenticator {
  /// Generates a new key pair in the secure element/keystore.
  /// Returns the public key as a 65-byte uncompressed byte array (0x04 || X || Y).
  /// Throws if generation fails.
  @async
  List<int> createKey(String keyTag);

  /// Deletes the key associated with the given tag.
  @async
  void deleteKey(String keyTag);

  /// Signs the data using the key associated with the given tag.
  /// Returns the signature (R || S) bytes.
  @async
  List<int> sign(String keyTag, List<int> data);

  /// Retrieves the public key for the given tag.
  /// Returns 65-byte uncompressed public key.
  @async
  List<int>? getPublicKey(String keyTag);
}
