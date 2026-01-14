import 'package:web3_signers/web3_signers.dart';

// this configurations are ideal for simulators.
// on real device please spec it out according to your needs
final Bytes attestationChallenge = Bytes(32);
final androidOptions = AndroidPlatformOptions(
    requireUserAuthentication: false,
    attestationChallenge: attestationChallenge);
// disable secure enclave for simulators
final darwinOptions = DarwinPlatformOptions(
    useSecureEnclave: false,
    accessible: DarwinAccessible.whenUnlockedThisDeviceOnly,
    requireUserAuthentication: true);
final windowsOptions = WindowsPlatformOptions();

const passkeyConfig = PassKeyConfig(
    rpId: "variance.space",
    rpName: "Variance",
    authenticatorAttachment: "platform");

final platformConfig = PlatformConfig(
    keyTag: "space.variance.web3_signers",
    androidOptions: androidOptions,
    darwinOptions: darwinOptions,
    windowsOptions: windowsOptions);
