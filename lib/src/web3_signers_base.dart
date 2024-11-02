library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:eth_sig_util/eth_sig_util.dart';
import 'package:passkeys/authenticator.dart';
import 'package:passkeys/types.dart';
import 'package:web3_signers/src/vendor/vendor.dart'
    show Bytes, BytesExtension, TupleExtension, U8aExtension;
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

import 'interfaces/interfaces.dart';
import 'utils/utils.dart';

export 'package:web3dart/web3dart.dart' show EthereumAddress;
import 'package:eth_sig_util/eth_sig_util.dart'
    show TypedDataUtil, TypedDataVersion;

part 'signers/eoa_wallet.dart';
part 'signers/passkey_signer.dart';
part 'signers/private_key_signer.dart';
