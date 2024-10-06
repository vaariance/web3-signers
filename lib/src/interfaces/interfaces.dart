library interfaces;

import 'dart:typed_data';

import 'package:passkeys/types.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

import '../utils/utils.dart' show Uint256;
import '../web3_signers_base.dart'
    show PassKeyPair, PassKeySignature, PassKeysOptions;

part 'eoa_wallet_interface.dart';
part 'multi_signer_interface.dart';
part 'passkey_signer_interface.dart';
part 'uint256_interface.dart';
