library interfaces;

import 'dart:typed_data';

import 'package:blockchain_utils/tuple/tuple.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

import '../utils/utils.dart' show Uint256;
import '../web3_signers_base.dart'
    show P256Credential, PassKeyPair, PassKeySignature, PassKeysOptions;

part 'eoa_wallet_interface.dart';
part 'multi_signer_interface.dart';
part 'passkey_signer_interface.dart';
part 'uint256_interface.dart';
part 'hardware_signer_interface.dart';
