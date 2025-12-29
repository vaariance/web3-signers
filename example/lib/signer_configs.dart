import 'package:web3_signers/web3_signers.dart';

///
class SignerConfigs {
  static const passkeyConfig = PassKeyConfig(
    rpId: "variance.space",
    rpName: "Web3 Signers Demo",
    userVerification: "required",
    authenticatorAttachment: "cross-platform",
    mediation: "optional",
    residentKey: "required",
    requireResidentKey: false,
  );

  static const platformConfig = PlatformConfig(
    keyTag: "web3-signers-demo-key",
  );
}
