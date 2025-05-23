library;

import 'dart:typed_data';

import 'package:eth_sig_util/eth_sig_util.dart';
import 'package:passkeys/authenticator.dart' show PasskeyAuthenticator;
import 'package:passkeys/types.dart';
import 'package:web3_signers/src/vendor/vendor.dart' show U8aExtension;
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

import '../utils/utils.dart'
    show ERC1271IsValidSignatureResponse, Uint256, hexlify;
import '../web3_signers_base.dart' show PassKeyPair, PassKeySignature;

part 'eoa_wallet_interface.dart';
part 'multi_signer_interface.dart';
part 'passkey_signer_interface.dart';
part 'signature_options.dart';
part 'uint256_interface.dart';
