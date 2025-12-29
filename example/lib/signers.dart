import 'dart:developer';

import 'package:example/signer_configs.dart';
import 'package:web3_signers/web3_signers.dart';

class Signers {
  LocalKeySigner useLocalKey() {
    try {
      final mnemonic = generateMnemonic(WordLength.word_24);
      final signer = LocalKeySigner.fromMnemonic(mnemonic);
      log(mnemonic);
      return signer;
    } catch (e) {
      rethrow;
    }
  }

  Future<PassKeySigner> usePassKey() async {
    try {
      final passkeyGen = await generatePassKey(
          config: SignerConfigs.passkeyConfig,
          username: 'variance.space',
          displayname: 'demo@variance.space');

      final signer =
          PassKeySigner.withConfig(SignerConfigs.passkeyConfig, passkeyGen);

      return signer;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<PlatformKeySigner> usePlatformKey() async {
    try {
      final platformKey = await generatePlatformKey(
          config: SignerConfigs.platformConfig, checkExisting: true);
      final platformSigner = PlatformKeySigner.withConfig(
          SignerConfigs.platformConfig, platformKey);
      log('${platformKey.x} ${platformKey.y}');
      return platformSigner;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}
