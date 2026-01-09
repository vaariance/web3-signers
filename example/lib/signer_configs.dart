import 'package:web3_signers/web3_signers.dart';

final androidOptions = AndroidPlatformOptions();
// disable secure enclave for simulators
final darwinOptions = DarwinPlatformOptions(useSecureEnclave: false);
final windowsOptions = WindowsPlatformOptions();

const passkeyConfig = PassKeyConfig(rpId: "variance.space", rpName: "Variance");

final platformConfig = PlatformConfig(
    keyTag: "com.example.web3_signers",
    androidOptions: androidOptions,
    darwinOptions: darwinOptions,
    windowsOptions: windowsOptions);
