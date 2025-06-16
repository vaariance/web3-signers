library;

import 'dart:typed_data';

import 'package:eip712/eip712.dart';
import 'package:passkeys/authenticator.dart' show PasskeyAuthenticator;
import 'package:passkeys/types.dart';
import 'package:wallet/wallet.dart' show EtherAmount, EthereumAddress;
import 'package:web3_signers/web3_signers.dart';
import 'package:web3dart/web3dart.dart';

part 'eoa_wallet_interface.dart';
part 'multi_signer_interface.dart';
part 'passkey_signer_interface.dart';
part 'signature_options.dart';
part 'uint256_interface.dart';
