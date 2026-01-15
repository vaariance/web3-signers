import 'dart:developer';

import 'package:example/signer_configs.dart';
import 'package:web3_signers/web3_signers.dart';

class Signers {
  Signer useLocalKey() {
    try {
      final mnemonic = generateMnemonic(WordLength.word_24);
      log("mnemonic: $mnemonic");
      final signer = LocalKeySigner.fromMnemonic(mnemonic);
      return signer;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<Signer> usePassKey() async {
    try {
      final pubKey = await generatePassKey(
          config: passkeyConfig,
          username: 'variance.space',
          displayname: 'demo@variance.space',
          excludedCredentials: [b64d("0ohsLBsE-Xs-QvGnLSWFe5Zx19Y")]);
      log('x: ${pubKey.x.toHex()}\ny: ${pubKey.y.toHex()}');
      final signer = PassKeySigner.withConfig(passkeyConfig, pubKey);
      log("credential ID: ${b64e(pubKey.credentialId)}");
      return signer;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<Signer> usePlatformKey() async {
    try {
      final pubKey = await generatePlatformKey(
          config: platformConfig, checkExisting: true);
      final platformSigner =
          PlatformKeySigner.withConfig(platformConfig, pubKey);
      log('x: ${pubKey.x.toHex()}\ny: ${pubKey.y.toHex()}');
      return platformSigner;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}
